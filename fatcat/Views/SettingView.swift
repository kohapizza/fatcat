//
// SettingView.swift
//

import Foundation
import SwiftUI
import MapKit

// MARK: - CatTypeSelectionView (New Component)
struct CatTypeSelectionView: View {
    @EnvironmentObject var dataStore: CatDataStore
    @Binding var selectedCatType: CatTypeModel?

    // Custom grid layout for cat types
    let columns = [
        GridItem(.adaptive(minimum: 80), spacing: 10) // Adjust minimum size as needed
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Cat Type")
                .font(.subheadline)
                .foregroundColor(.secondary)

            ScrollView(.horizontal, showsIndicators: false) { // Horizontal scroll for types
                LazyHGrid(rows: [GridItem(.fixed(100))], spacing: 15) { // Single row with fixed height
                    ForEach(dataStore.allCatTypes) { catType in
                        Button(action: {
                            selectedCatType = catType
                        }) {
                            VStack {
                                Text(catType.emoji) // Use emoji for icon
                                    .font(.largeTitle)
                                    .scaleEffect(selectedCatType?.id == catType.id ? 1.2 : 1.0) // Scale selected
                                Text(catType.name) // Use name for text
                                    .font(.caption)
                                    .foregroundColor(.primary)
                            }
                            .padding(8)
                            .background(selectedCatType?.id == catType.id ? Color.orange.opacity(0.2) : Color.clear)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(selectedCatType?.id == catType.id ? Color.orange : Color.gray.opacity(0.3), lineWidth: 2)
                            )
                        }
                        .buttonStyle(PlainButtonStyle()) // Remove default button styling
                    }
                }
                .padding(.horizontal, 4)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}


// MARK: - SettingView
struct LocationTimeSettingView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataStore: CatDataStore
    
    @State private var showingMyLocationSearch = false
    @Binding var showingLocationSearch: Bool
    @State private var showingLocationTimeSetting = false
    @State private var selectedDate = Date()
    @State private var startTime = Date()
    @State private var endTime = Date()
    @Binding var selectedLocation: CatLocation?
    @State private var locationCoordinate = CLLocationCoordinate2D(latitude: 35.6762, longitude: 139.6503)
    @State private var showingLocationPicker = false
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 35.6762, longitude: 139.6503),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    @State private var addNewCat: Bool = false
    @State private var newCatName: String = "" // For new cat name input
    @State private var selectedCatType: CatTypeModel? // For new cat type selection
    @State private var selectedExistingCat: CatModel? // For existing cat selection

    // MARK: - isDisabled Computed Property
    private var isDisabled: Bool {
        // Location must be selected
        if selectedLocation == nil {
            return true
        }
        
        // Validation for adding a new cat
        if addNewCat {
            if newCatName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || selectedCatType == nil {
                return true
            }
        } else {
            // Validation for selecting an existing cat
            if selectedExistingCat == nil {
                return true
            }
        }
        
        return false // All conditions met
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "cat.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.orange)
                        
                        Text("Cat Appearance Settings")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("Place cute cats in gloomy places")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    
                    // Date Selection
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(.blue)
                            Text("Date")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        
                        DatePicker("", selection: $selectedDate, displayedComponents: .date)
                            .datePickerStyle(GraphicalDatePickerStyle())
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                    }
                    
                    // Time Setting
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "clock")
                                .foregroundColor(.blue)
                            Text("Appearance Time")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        
                        VStack(spacing: 16) {
                            HStack {
                                Text("Start Time")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Spacer()
                                DatePicker("", selection: $startTime, displayedComponents: .hourAndMinute)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            
                            HStack {
                                Text("End Time")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Spacer()
                                DatePicker("", selection: $endTime, displayedComponents: .hourAndMinute)
                                    .labelsHidden()
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                    }
                    
                    // Location Setting
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "location")
                                .foregroundColor(.blue)
                            Text("Appearance Location")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        
                        if let location = selectedLocation {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Selected Location: \(location.name)")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Text("Address: \(location.address ?? "N/A")")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        } else {
                            Text("No location selected.")
                                .font(.headline)
                                .foregroundColor(.secondary)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                        }
                        
                        Button("位置情報を設定する") {
                            showingMyLocationSearch = true
                        }
                        .buttonStyle(ShopButtonStyle())
                        .sheet(isPresented: $showingMyLocationSearch) {
                            LocationSearchSwiftUI(selectedLocation: $selectedLocation)
                        }
                        
                        VStack(spacing: 12) {
                            // Mini map display
                            Map(coordinateRegion: $region, annotationItems: [MapPin(coordinate: locationCoordinate)]) { pin in
                                MapAnnotation(coordinate: pin.coordinate) {
                                    VStack {
                                        Image(systemName: "cat.fill")
                                            .font(.title2)
                                            .foregroundColor(.orange)
                                            .background(Circle().fill(Color.white).frame(width: 30, height: 30))
                                            .shadow(radius: 3)
                                    }
                                }
                            }
                            .frame(height: 120)
                            .cornerRadius(12)
                            .disabled(true)
                        }
                    }
                    
                    // --- Cat Selection/New Cat Section ---
                    VStack(alignment: .leading, spacing: 12) {
                        Toggle(isOn: $addNewCat) {
                            Text("Place a New Cat")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        .padding(.vertical, 5)
                        
                        if addNewCat {
                            // If placing a new cat
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Cat Name")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                TextField("Enter new cat's name", text: $newCatName)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .padding(.horizontal, 4)
                                
                                // Replaced Picker with CatTypeSelectionView
                                CatTypeSelectionView(selectedCatType: $selectedCatType)
                                    .environmentObject(dataStore) // Pass environment object
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        } else {
                            // If placing an existing cat
                            HStack(spacing: 12) {
                                Text("Select Existing Cat")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Picker("Existing Cat Name", selection: $selectedExistingCat) {
                                    Text("Please select").tag(nil as CatModel?) // Unselected state
                                    ForEach(dataStore.allCats) { cat in
                                        Text(cat.name).tag(cat as CatModel?)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 0.5))
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                    }
                    // --- End Cat Selection/New Cat Section ---
                    
                    Spacer(minLength: 20)
                    
                    // Set Button
                    Button(action: saveCatSchedule) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Place Cat")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [.orange, .pink]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                        .shadow(color: .blue.opacity(0.3), radius: 5, x: 0, y: 2)
                    }
                    .disabled(isDisabled) // Use isDisabled computed property
                    .opacity(isDisabled ? 0.6 : 1.0)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .navigationBarHidden(true)
            .alert("Error", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
            .onChange(of: selectedLocation) { newLocation in
                // Update map location based on selected place
                if let location = newLocation {
                    locationCoordinate = CLLocationCoordinate2D(
                        latitude: location.latitude,
                        longitude: location.longitude
                    )
                    region = MKCoordinateRegion(
                        center: locationCoordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    )
                }
            }
        }
    }
    
    // Separated method for saving cat schedule
    private func saveCatSchedule() {
        // Check if location is selected
        guard let selectedLocation = selectedLocation else {
            alertMessage = "No location selected to place the cat. Please select a location."
            showAlert = true
            return
        }
        
        // Validate time
        if startTime >= endTime {
            alertMessage = "Start time must be before end time."
            showAlert = true
            return
        }
        
        var catIdToUse: UUID
        
        if addNewCat {
            // If placing a new cat
            guard !newCatName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                alertMessage = "Please enter a name for the new cat."
                showAlert = true
                return
            }
            guard let selectedCatType = selectedCatType else {
                alertMessage = "Please select a type for the new cat."
                showAlert = true
                return
            }
            
            // Create new CatModel and add to dataStore
            let newCat = CatModel(id: UUID(), name: newCatName, isHungry: true, size: 0.01, typeId: selectedCatType.id)
            dataStore.allCats.append(newCat)
            catIdToUse = newCat.id
            print("Added new cat: \(newCat.name) (Type: \(selectedCatType.name))")
            
        } else {
            // If placing an existing cat
            guard let existingCat = selectedExistingCat else {
                alertMessage = "Please select a cat to place."
                showAlert = true
                return
            }
            catIdToUse = existingCat.id
            print("Placing existing cat: \(existingCat.name)")
        }
        
        // Format time to string
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let startTimeString = dateFormatter.string(from: startTime)
        let endTimeString = dateFormatter.string(from: endTime)
        
        // Create new CatSchedule object
        let newSchedule = CatSchedule(
            id: UUID(),
            catId: catIdToUse,
            locationId: selectedLocation.id,
            date: selectedDate,
            startTime: startTimeString,
            endTime: endTimeString
        )
        
        // Add location if it doesn't already exist
        let locationExists = dataStore.allLocations.contains { $0.id == selectedLocation.id }
        if !locationExists {
            let newLocation = CatLocation(
                id: selectedLocation.id,
                name: selectedLocation.name,
                address: selectedLocation.address,
                latitude: selectedLocation.latitude,
                longitude: selectedLocation.longitude
            )
            dataStore.allLocations.append(newLocation)
        }
        
        // Add new schedule to CatDataStore
        dataStore.allSchedules.append(newSchedule)
        
        print("Cat schedule saved: \(newSchedule)")
        print("Placing new cat: \(addNewCat)")
        
        // Dismiss modal
        showingLocationSearch = false
        dismiss()
    }
}
