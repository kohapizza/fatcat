//
//  ScheduleLocationMapDetailView.swift
//  fatcat
//
//  Created by Konami Shu on 2025/06/22.
//


// ScheduleView.swift の最下部、または別の新しいSwiftファイルに配置

import SwiftUI
import MapKit

// スケジュールから地図を表示するための専用ビュー
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
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
    }

    var body: some View {
        NavigationView {
            VStack {
                Text(location.name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.bottom, 5)
                Text(location.address ?? "住所不明")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 20)

                Map(coordinateRegion: $region, annotationItems: [MapPin(coordinate: annotationCoordinate)]) { pin in
                    MapAnnotation(coordinate: pin.coordinate) {
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
            .navigationTitle("場所の詳細")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("閉じる") {
                        dismiss()
                    }
                }
            }
        }
    }
}
