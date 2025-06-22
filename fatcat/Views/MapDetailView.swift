//
// ScheduleLocationMapDetailView.swift
// fatcat
//
// Created by Konami Shu on 2025/06/22.
//

import SwiftUI
import MapKit
import CoreLocation // CLLocationDegrees を使用するため

// MARK: - Dedicated View for Map Display
// Created based on SettingView.swift's map display
struct ScheduleLocationMapDetailView: View {
    @Environment(\.dismiss) var dismiss
    let location: CatLocation
    @State private var region: MKCoordinateRegion
    @State private var annotationCoordinate: CLLocationCoordinate2D

    init(location: CatLocation) {
        self.location = location
        _annotationCoordinate = State(initialValue: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude))
        _region = State(initialValue: MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01) // Use MKMapSpan for modern SwiftUI Map
        ))
    }

    var body: some View {
        NavigationView {
            VStack {
                Text(location.name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.bottom, 5)
                Text(location.address ?? "Address unknown")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 20)

                Map(coordinateRegion: $region, annotationItems: [MapPin(coordinate: annotationCoordinate)]) { mapPin in
                    MapAnnotation(coordinate: mapPin.coordinate) {
                        VStack {
                            Image(systemName: "cat.fill")
                                .font(.title)
                                .foregroundColor(.orange)
                                .background(Circle().fill(Color.white).frame(width: 40, height: 40))
                                .shadow(radius: 5)
                        }
                    }
                }
                .cornerRadius(15)
                .shadow(radius: 5)
                .padding()
                
                Spacer()
            }
            .navigationTitle("Location Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - MapPin (Copied from SettingView.swift and placed here for self-containment)
// Identifiable struct for use with MapAnnotation
struct MapPin: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}
