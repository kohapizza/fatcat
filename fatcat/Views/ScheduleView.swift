//
// ScheduleView.swift
//

import SwiftUI
import MapKit
import CoreLocation

// MARK: - ScheduleRow
struct ScheduleRow: View {
    let schedule: CatSchedule
    let allCats: [CatModel]
    let allCatTypes: [CatTypeModel]
    let allLocations: [CatLocation]
    
    // Closure to be called when a schedule needs to be deleted
    let onDelete: (UUID) -> Void
    // Closure to be called when the map detail view should be shown (receives CatLocation)
    let onMapTapped: (CatLocation) -> Void
    
    // State to control the visibility of the delete button
    @State private var showDeleteButton: Bool = false
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter
    }()
    
    private var catName: String {
        return allCats.first(where: { $0.id == schedule.catId })?.name ?? "Unknown Cat"
    }
    
    private var catIconName: String {
        if let cat = allCats.first(where: { $0.id == schedule.catId }),
           let catType = allCatTypes.first(where: { $0.id == cat.typeId }) {
            return catType.emoji // Assuming fileName is still used for icon names, as per CatTypeModel.fileName property in original ScheduleRow
        }
        return "🐱"
    }
    
    private var location: CatLocation? {
        return allLocations.first(where: { $0.id == schedule.locationId })
    }
    
    private var locationName: String {
        return location?.name ?? "Unknown Place"
    }
    
    var body: some View {
        // ZStack to overlay the delete button on the row content
        ZStack(alignment: .topTrailing) {
            // Schedule display part
            HStack(spacing: 16) {
                // Left side information (Date, Time, Cat Name, Location)
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(Self.dateFormatter.string(from: schedule.date))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("\(schedule.startTime) - \(schedule.endTime)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Text("**\(catName)** - \(locationName)")
                        .font(.callout)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                }
                Spacer()
                
                // Right side cat icon
                Text(catIconName)
                    .font(.system(size: 30)) // Adjust size as needed
                    
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
            .contentShape(Rectangle()) // Extend tap area to the whole row
            // MARK: - Gesture Changes: Long press for delete, tap for map
            // Use a specific minimumDuration for long press to avoid conflicting with taps.
            .onLongPressGesture(minimumDuration: 0.5) { // Add minimumDuration
                withAnimation { // Animate showing/hiding
                    showDeleteButton.toggle()
                }
            }
            // For simultaneous gestures, explicitly define the order or use .simultaneousGesture if needed.
            // In this case, by setting a minimumDuration for long press, normal taps will now fire reliably.
            .onTapGesture {
                // Hide the delete button on tap (in case it was already shown)
                withAnimation {
                    showDeleteButton = false
                }
                
                // Call the map display closure if location is available
                if let loc = location {
                    onMapTapped(loc)
                }
            }
            
            // Delete button (only visible when showDeleteButton is true)
            if showDeleteButton {
                Button(action: {
                    onDelete(schedule.id) // Call delete closure with schedule ID
                    withAnimation {
                        showDeleteButton = false // Hide button after deletion
                    }
                }) {
                    Image(systemName: "xmark.circle.fill") // 'X' mark icon
                        .font(.title2) // Adjust icon size
                        .foregroundColor(.white) // White icon color
                        .background(Circle().fill(Color.gray.opacity(0.7))) // Semi-transparent gray circular background
                        .clipShape(Circle()) // Clip to a circle shape
                }
                .buttonStyle(PlainButtonStyle()) // Reset default button style
                .offset(x: 10, y: -10) // Offset to position at top-right corner
                .transition(.opacity) // Fade animation for appearance/disappearance
            }
        }
        .padding(.horizontal, 5) // Horizontal padding from List edges
        .padding(.vertical, 3)   // Vertical padding between rows
    }
}

// MARK: - ScheduleView
struct ScheduleView: View {
    @EnvironmentObject var dataStore: CatDataStore
    
    // State variables for map display
    @State private var showingLocationDetailSheet: Bool = false
    @State private var selectedLocationForMap: CatLocation?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Today's schedule summary
                    VStack(spacing: 12) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Today's Cats")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                Text("\(todaySchedules.count) cats are waiting")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Image(systemName: "cat.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.orange)
                        }
                        .padding(20)
                        .background(
                            LinearGradient(
                                colors: [.orange.opacity(0.1), .pink.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(16)
                        .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 20)
                    .padding(.top, 15)
                    
                    // Schedule list
                    List {
                        ForEach(groupedSchedules.keys.sorted(), id: \.self) { date in
                            Section(header: Text(formatDate(date)).font(.headline)) {
                                ForEach(groupedSchedules[date] ?? []) { schedule in
                                    ScheduleRow(
                                        schedule: schedule,
                                        allCats: dataStore.allCats,
                                        allCatTypes: dataStore.allCatTypes,
                                        allLocations: dataStore.allLocations,
                                        onDelete: { scheduleId in
                                            dataStore.allSchedules.removeAll { $0.id == scheduleId }
                                        },
                                        onMapTapped: { locationFromRow in // Receive CatLocation directly from ScheduleRow
                                            selectedLocationForMap = locationFromRow
                                            showingLocationDetailSheet = true
                                        }
                                    )
                                    .listRowBackground(Color.clear)
                                    .listRowSeparator(.hidden)
                                }
                                // Keep swipe-to-delete functionality as well
                                .onDelete { indexSet in
                                    deleteSchedule(at: indexSet, for: date)
                                }
                            }
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                    .scrollContentBackground(.hidden)
                    .background(Color.white)
                }
            }
            .navigationTitle("Schedules")
            .navigationBarTitleDisplayMode(.inline)
            // Map display sheet
            .sheet(isPresented: $showingLocationDetailSheet) {
                if let location = selectedLocationForMap {
                    ScheduleLocationMapDetailView(location: location)
                } else {
                    Text("Location information not found.")
                }
            }
        }
    }
    
    private var todaySchedules: [CatSchedule] {
        let today = Calendar.current.startOfDay(for: Date())
        return dataStore.allSchedules.filter { Calendar.current.isDate($0.date, inSameDayAs: today) }
    }
    
    private var groupedSchedules: [Date: [CatSchedule]] {
        Dictionary(grouping: dataStore.allSchedules) { schedule in
            Calendar.current.startOfDay(for: schedule.date)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
    
    private func deleteSchedule(at offsets: IndexSet, for date: Date) {
        let schedulesForDate = groupedSchedules[date] ?? []
        for index in offsets {
            if let scheduleToDelete = schedulesForDate[safe: index] {
                dataStore.allSchedules.removeAll { $0.id == scheduleToDelete.id }
            }
        }
    }
}

// Safe array subscript extension (no changes)
extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
