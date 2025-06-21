import SwiftUI

struct ScheduleRow: View {
    let schedule: CatSchedule
    let allCats: [CatModel]
    let allCatTypes: [CatTypeModel]
    let allLocations: [CatLocation]
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter
    }()
    
    private var catName: String {
        return allCats.first(where: { $0.id == schedule.catId })?.name ?? "不明な猫"
    }
    
    
    private var catIconName: String {
        if let cat = allCats.first(where: { $0.id == schedule.catId }),
           let catType = allCatTypes.first(where: { $0.id == cat.typeId }) {
            return catType.fileName
        }
        return "questionmark.circle.fill"
    }
    
    private var locationName: String {
        return allLocations.first(where: { $0.id == schedule.locationId })?.name ?? "不明な場所"
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // 左側の情報（日付、時間、猫の名前、場所）
            VStack(spacing: 4) {
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
                
                Spacer()
            }
            Spacer() // 左側の内容とアイコンを左右に広げる
            
            // 右側の猫アイコン
            Image(systemName: catIconName)
                .font(.system(size: 30))
                .foregroundColor(.orange)
        }
        .padding() // 内側のパディングを増やす
        // MARK: - 各行の背景色と角丸、影を設定して見やすくする
        .background(Color.white) // 行の背景を白に
        .cornerRadius(10)       // 角を丸くする
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2) // 控えめな影
        .padding(.horizontal, 5) // Listの端からの間隔
        .padding(.vertical, 3)   // 各行間の間隔を少し広げる
    }
}


// MARK: - 予定表示画面
struct ScheduleView: View {
    @EnvironmentObject var dataStore: CatDataStore
    
    var body: some View {
        NavigationView {
            // MARK: - 全体の背景を白にする
            // ZStackを使って、全体の背景色を確実に設定
            ZStack {
                Color.white.ignoresSafeArea() // 背景色を白に設定し、セーフエリアを無視して全体に適用
                
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
                                    ScheduleRow(schedule: schedule, allCats: dataStore.allCats, allCatTypes: dataStore.allCatTypes, allLocations: dataStore.allLocations)
                                        // MARK: - 各ListRowのデフォルト背景をクリアにし、ScheduleRow内で背景を設定するため
                                        .listRowBackground(Color.clear)
                                        // MARK: - Listの区切り線を非表示にして、ScheduleRowの背景と影が綺麗に見えるようにする
                                        .listRowSeparator(.hidden)
                                }
                                // MARK: - 行削除の機能 (変更なし)
                                .onDelete { indexSet in
                                    deleteSchedule(at: indexSet, for: date)
                                }
                            }
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                    // MARK: - List自体の背景色を白にする重要な設定
                    // iOS 15以降でListの背景をカスタムする推奨方法
                    .scrollContentBackground(.hidden) // スクロールコンテンツの背景を非表示
                    .background(Color.white)         // その下に白を適用
                }
            }
            .navigationTitle("予定")
            .navigationBarTitleDisplayMode(.inline)
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

// Safe array subscript extension (変更なし)
extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
