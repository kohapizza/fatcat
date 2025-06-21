import SwiftUI

// MARK: - 予定表示画面
struct ScheduleView: View {
    // MARK: - CatModel (サンプルデータ)
    @State private var allCats: [CatModel] = [
        CatModel(id: UUID(uuidString: "E621E1F8-C36C-495A-93FC-0C247A3E6E5F")!, name: "クロ", isHungry: true, size: 5.0, typeID: 1), // 黒猫
        CatModel(id: UUID(uuidString: "F621E1F8-C36C-495A-93FC-0C247A3E6E5F")!, name: "ミケ", isHungry: false, size: 4.5, typeID: 2), // 三毛猫
        // Corrected UUID strings for "シロ", "トラ", "ハチワレ"
        CatModel(id: UUID(uuidString: "A621E1F8-C36C-495A-93FC-0C247A3E6E5F")!, name: "シロ", isHungry: true, size: 5.2, typeID: 3), // 白猫
        CatModel(id: UUID(uuidString: "B621E1F8-C36C-495A-93FC-0C247A3E6E5F")!, name: "トラ", isHungry: false, size: 4.8, typeID: 2), // 三毛猫
        CatModel(id: UUID(uuidString: "C621E1F8-C36C-495A-93FC-0C247A3E6E5F")!, name: "ハチワレ", isHungry: true, size: 5.5, typeID: 1) // 黒猫
    ]

    // MARK: - CatTypeModel (サンプルデータ - SF Symbolsを使用)
    @State private var allCatTypes: [CatTypeModel] = [
        CatTypeModel(id: 1, fileName: "cat.fill", catType: "黒猫"), // 黒猫 (デフォルトのcat.fill)
        CatTypeModel(id: 2, fileName: "cat.circle.fill", catType: "三毛猫"), // 三毛猫
        CatTypeModel(id: 3, fileName: "pawprint.fill", catType: "白猫") // 白猫 (足跡のアイコン)
    ]

    @State private var schedules = [
        CatSchedule(id: 1, catID: UUID(uuidString: "E621E1F8-C36C-495A-93FC-0C247A3E6E5F")!, locationID: 1, date: Calendar.current.date(byAdding: .day, value: 2, to: Date())!, startTime: "14:00", endTime: "17:00"),
        CatSchedule(id: 2, catID: UUID(uuidString: "F621E1F8-C36C-495A-93FC-0C247A3E6E5F")!, locationID: 2, date: Calendar.current.date(byAdding: .day, value: 2, to: Date())!, startTime: "14:00", endTime: "17:00"),
        // Corrected catID UUID strings for schedules
        CatSchedule(id: 3, catID: UUID(uuidString: "A621E1F8-C36C-495A-93FC-0C247A3E6E5F")!, locationID: 3, date: Calendar.current.date(byAdding: .day, value: 2, to: Date())!, startTime: "14:00", endTime: "17:00"),
        CatSchedule(id: 4, catID: UUID(uuidString: "B621E1F8-C36C-495A-93FC-0C247A3E6E5F")!, locationID: 54, date: Calendar.current.date(byAdding: .day, value: 2, to: Date())!, startTime: "14:00", endTime: "17:00"), // Location 54 will be "不明な場所"
        CatSchedule(id: 5, catID: UUID(uuidString: "C621E1F8-C36C-495A-93FC-0C247A3E6E5F")!, locationID: 5, date: Calendar.current.date(byAdding: .day, value: 2, to: Date())!, startTime: "14:00", endTime: "17:00")
    ]
    
    // MARK: - 猫の場所データ (サンプル)
    @State private var catLocations: [CatLocation] = [
        CatLocation(id: 1, locationName: "中央公園", locationAddress: "東京都中央区公園1-1", lolgitude: 139.767125, latitude: 35.681236),
        CatLocation(id: 2, locationName: "図書館裏", locationAddress: "東京都新宿区図書館2-2", lolgitude: 139.700000, latitude: 35.690000),
        CatLocation(id: 3, locationName: "商店街の角", locationAddress: "東京都渋谷区商店街3-3", lolgitude: 139.691700, latitude: 35.658000),
        CatLocation(id: 4, locationName: "川沿いの道", locationAddress: "東京都世田谷区川沿い4-4", lolgitude: 139.660000, latitude: 35.640000),
        CatLocation(id: 5, locationName: "駅前広場", locationAddress: "東京都港区駅前5-5", lolgitude: 139.750000, latitude: 35.660000)
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 今日の予定サマリー
                VStack(spacing: 12) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("今日の猫")
                                .font(.headline)
                                .fontWeight(.bold)
                            Text("\(todaySchedules.count)匹が待っています")
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
                
                // 予定リスト
                List {
                    ForEach(groupedSchedules.keys.sorted(), id: \.self) { date in
                        Section(header: Text(formatDate(date)).font(.headline)) {
                            ForEach(groupedSchedules[date] ?? []) { schedule in
                                // ScheduleRowに全ての猫、猫のタイプ、場所データを渡す
                                ScheduleRow(schedule: schedule, allCats: allCats, allCatTypes: allCatTypes, allLocations: catLocations)
                            }
                            .onDelete { indexSet in
                                deleteSchedule(at: indexSet, for: date)
                            }
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }
            .navigationTitle("予定")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private var todaySchedules: [CatSchedule] {
        let today = Calendar.current.startOfDay(for: Date())
        return schedules.filter { Calendar.current.isDate($0.date, inSameDayAs: today) }
    }
    
    private var groupedSchedules: [Date: [CatSchedule]] {
        Dictionary(grouping: schedules) { schedule in
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
                schedules.removeAll { $0.id == scheduleToDelete.id }
            }
        }
    }
}

// Safe array subscript extension
extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}


struct ScheduleRow: View {
    let schedule: CatSchedule
    let allCats: [CatModel] // 新しく追加
    let allCatTypes: [CatTypeModel] // 新しく追加
    let allLocations: [CatLocation]
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter
    }()
    
    // MARK: - 猫の名前を取得する計算プロパティ
    private var catName: String {
        return allCats.first(where: { $0.id == schedule.catID })?.name ?? "不明な猫"
    }
    
    // MARK: - 猫のタイプに応じたアイコン名を取得する計算プロパティ
    private var catIconName: String {
        if let cat = allCats.first(where: { $0.id == schedule.catID }),
           let catType = allCatTypes.first(where: { $0.id == cat.typeID }) {
            return catType.fileName
        }
        return "questionmark.circle.fill" // デフォルトアイコン
    }
    
    // MARK: - 場所の名前を取得する計算プロパティ
    private var locationName: String {
        return allLocations.first(where: { $0.id == schedule.locationID })?.locationName ?? "不明な場所"
    }
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(Self.dateFormatter.string(from: schedule.date))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("\(schedule.startTime) - \(schedule.endTime)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text("**\(catName)** - \(locationName)") // 猫の名前と場所を強調
                    .font(.callout)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            Spacer() // This Spacer pushes the icon to the right
            
            // MARK: - 猫のタイプに応じたアイコンを表示
            Image(systemName: catIconName)
                .font(.system(size: 30))
                .foregroundColor(.orange) // アイコンの色は引き続きオレンジ
        }
        .padding(.vertical, 4)
    }
}
