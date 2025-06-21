//
//  test.swift
//  fatcat
//
//  Created by 佐伯小遥 on 2025/06/21.
//

import Foundation
import SwiftUI
import MapKit

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
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "cat.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.orange)
                        
                        Text("猫の出現設定")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("憂鬱な場所に可愛い猫を配置しましょう")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    
                    // 日付選択
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(.blue)
                            Text("日付")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        
                        DatePicker("", selection: $selectedDate, displayedComponents: .date)
                            .datePickerStyle(GraphicalDatePickerStyle())
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                    }
                    
                    // 時間設定
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "clock")
                                .foregroundColor(.blue)
                            Text("出現時間")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        
                        VStack(spacing: 16) {
                            HStack {
                                Text("開始時間")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Spacer()
                                DatePicker("", selection: $startTime, displayedComponents: .hourAndMinute)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            
                            HStack {
                                Text("終了時間")
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
                    
                    // 場所設定
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "location")
                                .foregroundColor(.blue)
                            Text("出現場所")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        
                        if let location = selectedLocation {
                            Text("選択された位置情報: \(location.name)")
                                .font(.headline)
                            Text("住所: \(location.address ?? "なし")")
                                .font(.subheadline)
                        } else {
                            Text("位置情報が選択されていません。")
                                .font(.headline)
                                .padding()
                        }
                        
                        
                        Button("位置情報を設定する") {
                            showingMyLocationSearch = true
                        }
                        .buttonStyle(ShopButtonStyle()) // ShopButtonStyleは別途定義されているものとします
                        .sheet(isPresented: $showingMyLocationSearch) {
                            // 位置検索ビュー
                            LocationSearchSwiftUI(selectedLocation: $selectedLocation)
                        }
                        
                        
                        VStack(spacing: 12) {
                            
                            // ミニマップ表示
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
                    
                    Spacer(minLength: 20)
                    
                    // 設定ボタン
                    Button(action: {
                        // 設定を保存する処理
                        print("設定を保存: \(selectedDate), \(startTime)-\(endTime), \(selectedLocation)")
                        // 時間を文字列にフォーマット
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "HH:mm"
                            let startTimeString = dateFormatter.string(from: startTime)
                            let endTimeString = dateFormatter.string(from: endTime)

                            // 新しいCatScheduleオブジェクトを作成
                            if let selectedLocation = selectedLocation {
                                let newSchedule = CatSchedule(
                                    id: UUID(),
                                    catId: UUID(),
                                    locationId: selectedLocation.id,
                                    date: selectedDate,
                                    startTime: startTimeString,
                                    endTime: endTimeString
                                )
                                let newLocation = CatLocation(
                                    id: selectedLocation.id,
                                    name: selectedLocation.name,
                                    address: selectedLocation.address,
                                    latitude: selectedLocation.latitude,
                                    longitude: selectedLocation.longitude
                                )

                                // CatDataStoreに新しいスケジュールを追加
                                // todo: ここで猫を配置する処理を実装
                                dataStore.allSchedules.append(newSchedule)
                                dataStore.allLocations.append(newLocation)
                                print("予定を追加: \(newSchedule)")
                                dismiss() // 画面を閉じる
                            }
                        else {
                            alertMessage = "猫を配置する場所が選択されていません。場所を選択してください。"
                            showAlert = true
                        }
                            showingLocationSearch = false
                    }) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("猫を配置する")
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
                        .shadow(color: .orange.opacity(0.3), radius: 5, x: 0, y: 2)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .navigationBarHidden(true)
        }
    }
    
}

struct MapPin: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}
