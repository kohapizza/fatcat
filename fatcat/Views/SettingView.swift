//
// SettingView.swift
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
    
    @State private var addNewCat: Bool = false
    @State private var newCatName: String = "" // 新しい猫の名前入力用
    @State private var selectedCatType: CatTypeModel? // 新しい猫のタイプ選択用
    @State private var selectedExistingCat: CatModel? // 既存の猫選択用

    // MARK: - isDisabled 計算プロパティ
    private var isDisabled: Bool {
        // 場所が選択されていない場合
        if selectedLocation == nil {
            return true
        }
        
        // 新しい猫を配置する場合のバリデーション
        if addNewCat {
            if newCatName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || selectedCatType == nil {
                return true
            }
        } else {
            // 既存の猫を配置する場合のバリデーション
            if selectedExistingCat == nil {
                return true
            }
        }
        
        return false // 全ての条件をクリアした場合
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
                            VStack(alignment: .leading, spacing: 4) {
                                Text("選択された位置情報: \(location.name)")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Text("住所: \(location.address ?? "なし")")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        } else {
                            Text("位置情報が選択されていません。")
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
                    
                    // --- 猫の選択/新規作成セクション ---
                    VStack(alignment: .leading, spacing: 12) {
                        Toggle(isOn: $addNewCat) {
                            Text("新しい猫を配置する")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        .padding(.vertical, 5)
                        
                        if addNewCat {
                            // 新しい猫を配置する場合
                            VStack(alignment: .leading, spacing: 8) {
                                Text("猫の名前")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                TextField("新しい猫の名前を入力", text: $newCatName)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .padding(.horizontal, 4)
                                
                                Text("猫の種類")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Picker("猫の種類", selection: $selectedCatType) {
                                    Text("選択してください").tag(nil as CatTypeModel?) // 未選択の状態
                                    ForEach(dataStore.allCatTypes) { catType in
                                        Text(catType.catType).tag(catType as CatTypeModel?)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle()) // または .wheelPickerStyle() など
                                .padding(.horizontal, 4)
                                .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 0.5))
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        } else {
                            // 既存の猫を配置する場合
                            VStack(alignment: .leading, spacing: 8) {
                                Text("既存の猫を選択")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Picker("既存の猫の名前", selection: $selectedExistingCat) {
                                    Text("選択してください").tag(nil as CatModel?) // 未選択の状態
                                    ForEach(dataStore.allCats) { cat in
                                        Text(cat.name).tag(cat as CatModel?)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle()) // または .wheelPickerStyle() など
                                .padding(.horizontal, 4)
                                .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 0.5))
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                    }
                    // --- 猫の選択/新規作成セクション終わり ---
                    
                    Spacer(minLength: 20)
                    
                    // 設定ボタン
                    Button(action: saveCatSchedule) {
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
                        .shadow(color: .blue.opacity(0.3), radius: 5, x: 0, y: 2)
                    }
                    .disabled(isDisabled) // isDisabled 計算プロパティを使用
                    .opacity(isDisabled ? 0.6 : 1.0)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .navigationBarHidden(true)
            .alert("エラー", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
            .onChange(of: selectedLocation) { newLocation in
                // 選択された場所に基づいてマップの位置を更新
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
    
    // 猫のスケジュール保存処理を別メソッドに分離
    private func saveCatSchedule() {
        // 場所が選択されているかチェック
        guard let selectedLocation = selectedLocation else {
            alertMessage = "猫を配置する場所が選択されていません。場所を選択してください。"
            showAlert = true
            return
        }
        
        // 時間の妥当性チェック
        if startTime >= endTime {
            alertMessage = "開始時間は終了時間より前に設定してください。"
            showAlert = true
            return
        }
        
        var catIdToUse: UUID
        
        if addNewCat {
            // 新しい猫を配置する場合
            guard !newCatName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                alertMessage = "新しい猫の名前を入力してください。"
                showAlert = true
                return
            }
            guard let selectedCatType = selectedCatType else {
                alertMessage = "新しい猫の種類を選択してください。"
                showAlert = true
                return
            }
            
            // 新しいCatModelを作成し、dataStoreに追加
            let newCat = CatModel(id: UUID(), name: newCatName, isHungry: true, size: 0.01, typeId: selectedCatType.id)
            dataStore.allCats.append(newCat)
            catIdToUse = newCat.id
            print("新しい猫を追加しました: \(newCat.name) (Type: \(selectedCatType.catType))")
            
        } else {
            // 既存の猫を配置する場合
            guard let existingCat = selectedExistingCat else {
                alertMessage = "配置する猫を選択してください。"
                showAlert = true
                return
            }
            catIdToUse = existingCat.id
            print("既存の猫を配置します: \(existingCat.name)")
        }
        
        // 時間を文字列にフォーマット
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let startTimeString = dateFormatter.string(from: startTime)
        let endTimeString = dateFormatter.string(from: endTime)
        
        // 新しいCatScheduleオブジェクトを作成
        let newSchedule = CatSchedule(
            id: UUID(),
            catId: catIdToUse,
            locationId: selectedLocation.id,
            date: selectedDate,
            startTime: startTimeString,
            endTime: endTimeString
        )
        
        // 場所が既に存在しない場合は追加
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
        
        // CatDataStoreに新しいスケジュールを追加
        dataStore.allSchedules.append(newSchedule)
        
        print("猫のスケジュールを保存しました: \(newSchedule)")
        print("新しい猫を配置する: \(addNewCat)")
        
        // モーダルを閉じる
        showingLocationSearch = false
        dismiss()
    }
}

struct MapPin: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

// 既存のCatScheduleManager.swiftのデータモデルとCatDataStoreクラスもそのまま利用します。
// CatScheduleManager.swiftの内容は変更する必要はありません。
