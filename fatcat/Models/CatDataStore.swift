// CatDataStore.swift

import Foundation
import CoreLocation

// MARK: - UserDefaultsキーの定義
enum UserDefaultsKeys {
    static let cats = "cats"
    static let catTypes = "catTypes"
    static let schedules = "schedules"
    static let locations = "locations"
}

// MARK: - データストアクラス
class CatDataStore: ObservableObject {
    @Published var allCats: [CatModel] {
        didSet {
            // allCatsが変更されたらUserDefaultsに保存
            CatDataStore.save(allCats, forKey: UserDefaultsKeys.cats) // STATIC CALL
        }
    }

    @Published var allCatTypes: [CatTypeModel] {
        didSet {
            CatDataStore.save(allCatTypes, forKey: UserDefaultsKeys.catTypes) // STATIC CALL
        }
    }

    @Published var allSchedules: [CatSchedule] {
        didSet {
            CatDataStore.save(allSchedules, forKey: UserDefaultsKeys.schedules) // STATIC CALL
        }
    }

    @Published var allLocations: [CatLocation] {
        didSet {
            CatDataStore.save(allLocations, forKey: UserDefaultsKeys.locations) // STATIC CALL
        }
    }

    // 初期化時にUserDefaultsからデータを読み込む
    init() {
        // STATIC CALL
        self.allCats = CatDataStore.load([CatModel].self, forKey: UserDefaultsKeys.cats) ?? CatDataStore.defaultCats
        self.allCatTypes = CatDataStore.load([CatTypeModel].self, forKey: UserDefaultsKeys.catTypes) ?? CatDataStore.defaultCatTypes
        self.allSchedules = CatDataStore.load([CatSchedule].self, forKey: UserDefaultsKeys.schedules) ?? CatDataStore.defaultSchedules
        self.allLocations = CatDataStore.load([CatLocation].self, forKey: UserDefaultsKeys.locations) ?? CatDataStore.defaultLocations
    }

    // MARK: - Generic 保存/読み込みメソッド (STATIC に変更)
    private static func save<T: Encodable>(_ object: T, forKey key: String) { // STATIC
        if let encoded = try? JSONEncoder().encode(object) {
            UserDefaults.standard.set(encoded, forKey: key)
        } else {
            print("Failed to encode \(key) data.")
        }
    }

    private static func load<T: Decodable>(_ type: T.Type, forKey key: String) -> T? { // STATIC
        if let savedData = UserDefaults.standard.data(forKey: key) {
            if let decoded = try? JSONDecoder().decode(type, from: savedData) {
                return decoded
            } else {
                print("Failed to decode \(key) data.")
            }
        }
        return nil
    }

    // MARK: - 初回起動時のデフォルトデータ (サンプル)
    // UserDefaultsにデータがない場合にロードされる初期値
    static var defaultCats: [CatModel] {
        [
            CatModel(id: UUID(uuidString: "E621E1F8-C36C-495A-93FC-0C247A3E6E5F")!, name: "クロ", isHungry: true, size: 5.0, typeId: 1),
            CatModel(id: UUID(uuidString: "F621E1F8-C36C-495A-93FC-0C247A3E6E5F")!, name: "ミケ", isHungry: false, size: 4.5, typeId: 2),
            CatModel(id: UUID(uuidString: "A621E1F8-C36C-495A-93FC-0C247A3E6E5F")!, name: "シロ", isHungry: true, size: 5.2, typeId: 3),
            CatModel(id: UUID(uuidString: "B621E1F8-C36C-495A-93FC-0C247A3E6E5F")!, name: "トラ", isHungry: false, size: 4.8, typeId: 2),
            CatModel(id: UUID(uuidString: "C621E1F8-C36C-495A-93FC-0C247A3E6E5F")!, name: "ハチワレ", isHungry: true, size: 5.5, typeId: 1)
        ]
    }

    static var defaultCatTypes: [CatTypeModel] {
        [
            CatTypeModel(id: 1, fileName: "cat.fill", catType: "黒猫"),
            CatTypeModel(id: 2, fileName: "cat.circle.fill", catType: "三毛猫"),
            CatTypeModel(id: 3, fileName: "pawprint.fill", catType: "白猫")
        ]
    }

    // MARK: - defaultSchedulesのidとlocationIDをUUID型に修正
    static var defaultSchedules: [CatSchedule] {
        [
            CatSchedule(id: UUID(uuidString: "A621E1F8-C36C-495A-93FC-0C247A3E6E51")!, catId: UUID(uuidString: "E621E1F8-C36C-495A-93FC-0C247A3E6E5F")!, locationId: UUID(uuidString: "E621E1F8-C36C-495A-93FC-0C247A3E6E61")!, date: Calendar.current.date(byAdding: .day, value: 2, to: Date())!, startTime: "14:00", endTime: "17:00"),
            CatSchedule(id: UUID(uuidString: "B621E1F8-C36C-495A-93FC-0C247A3E6E52")!, catId: UUID(uuidString: "F621E1F8-C36C-495A-93FC-0C247A3E6E5F")!, locationId: UUID(uuidString: "F621E1F8-C36C-495A-93FC-0C247A3E6E62")!, date: Calendar.current.date(byAdding: .day, value: 2, to: Date())!, startTime: "14:00", endTime: "17:00"),
            CatSchedule(id: UUID(uuidString: "C621E1F8-C36C-495A-93FC-0C247A3E6E53")!, catId: UUID(uuidString: "A621E1F8-C36C-495A-93FC-0C247A3E6E5F")!, locationId: UUID(uuidString: "A621E1F8-C36C-495A-93FC-0C247A3E6E63")!, date: Calendar.current.date(byAdding: .day, value: 2, to: Date())!, startTime: "14:00", endTime: "17:00"),
            CatSchedule(id: UUID(uuidString: "D621E1F8-C36C-495A-93FC-0C247A3E6E54")!, catId: UUID(uuidString: "B621E1F8-C36C-495A-93FC-0C247A3E6E5F")!, locationId: UUID(uuidString: "B621E1F8-C36C-495A-93FC-0C247A3E6E64")!, date: Calendar.current.date(byAdding: .day, value: 2, to: Date())!, startTime: "14:00", endTime: "17:00"),
            CatSchedule(id: UUID(uuidString: "E621E1F8-C36C-495A-93FC-0C247A3E6E55")!, catId: UUID(uuidString: "C621E1F8-C36C-495A-93FC-0C247A3E6E5F")!, locationId: UUID(uuidString: "C621E1F8-C36C-495A-93FC-0C247A3E6E65")!, date: Calendar.current.date(byAdding: .day, value: 2, to: Date())!, startTime: "14:00", endTime: "17:00")
        ]
    }

    static var defaultLocations: [CatLocation] {
        [
            CatLocation(id: UUID(uuidString: "E621E1F8-C36C-495A-93FC-0C247A3E6E61")!, name: "中央公園", address: "東京都中央区公園1-1", latitude: 35.681236, longitude: 139.767125),
            CatLocation(id: UUID(uuidString: "F621E1F8-C36C-495A-93FC-0C247A3E6E62")!, name: "図書館裏", address: "東京都新宿区図書館2-2", latitude: 35.690000, longitude: 139.700000),
            CatLocation(id: UUID(uuidString: "A621E1F8-C36C-495A-93FC-0C247A3E6E63")!, name: "商店街の角", address: "東京都渋谷区商店街3-3", latitude: 35.658000, longitude: 139.691700),
            CatLocation(id: UUID(uuidString: "B621E1F8-C36C-495A-93FC-0C247A3E6E64")!, name: "川沿いの道", address: "東京都世田谷区川沿い4-4", latitude: 35.640000, longitude: 139.660000),
            CatLocation(id: UUID(uuidString: "C621E1F8-C36C-495A-93FC-0C247A3E6E65")!, name: "駅前広場", address: "東京都港区駅前5-5", latitude: 35.660000, longitude: 139.750000)
        ]
    }

    // MARK: - printSchedulesのID出力形式をUUIDに修正
    public func printSchedules() {
        print("\n--- allSchedules ---")
        for schedule in allSchedules {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .none
            dateFormatter.locale = Locale(identifier: "ja_JP")
            let formattedDate = dateFormatter.string(from: schedule.date)

            // UUIDを文字列として出力し、Optionalではないため安全にunwrapできる
            print("ID: \(schedule.id.uuidString.prefix(8))..., CatId: \(schedule.catId.uuidString.prefix(8))..., LocationId: \(schedule.locationId.uuidString.prefix(8))..., Date: \(formattedDate), Time: \(schedule.startTime) - \(schedule.endTime)")
        }
        print("-------------------------------------------\n")
    }

    // MARK: - 現在の場所と時間に基づいてスケジュールを評価する関数
    func ifInLocation(currentLocation: CLLocation?) -> Bool {
        guard let currentLocation = currentLocation else {
            print("現在の位置情報が利用できません。")
            return false // 現在位置が不明な場合はfalseを返す
        }

        let currentDate = Date()
        let calendar = Calendar.current
        
        // 現在の時刻が含まれるスケジュールをフィルタリング
        let relevantSchedules = allSchedules.filter { schedule in
            let scheduleDate = calendar.startOfDay(for: schedule.date) // スケジュールの日の0時0分
            let today = calendar.startOfDay(for: currentDate)

            // スケジュールのstartTimeとendTimeをDateオブジェクトに変換
            let startTimeDate = dateAndTime(from: schedule.startTime, on: scheduleDate)
            let endTimeDate = dateAndTime(from: schedule.endTime, on: scheduleDate)

            // startTimeDateとendTimeDateが両方ともnilでないことを確認
            guard let startTime = startTimeDate, let endTime = endTimeDate else {
                print("スケジュールの時間の解析に失敗しました。")
                return false
            }

            // 現在の時刻がスケジュールの時間範囲内であるか確認
            let isInTimeRange = (startTime ... endTime).contains(currentDate)

            // スケジュールの日付が今日であるか確認
            let isToday = scheduleDate == today

            return isToday && isInTimeRange
        }

        // 関連するスケジュールがない場合はfalseを返す
        guard let schedule = relevantSchedules.first else {
            print("現在の時間に含まれるスケジュールはありません。")
            return false
        }

        // スケジュールに関連付けられた場所を取得
        guard let scheduleLocation = allLocations.first(where: { $0.id == schedule.locationId }) else {
            print("スケジュールに関連付けられた場所が見つかりません。")
            return false
        }

        // 場所の座標を作成
        let scheduleLocationCLLocation = CLLocation(latitude: scheduleLocation.latitude, longitude: scheduleLocation.longitude)

        // 距離を計算 (メートル単位)
        let distanceInMeters = currentLocation.distance(from: scheduleLocationCLLocation)

        // 1km以内かどうかを返す
        return distanceInMeters <= 1000
    }

    // startTimeまたはendTime文字列と日付からDateオブジェクトを作成するヘルパー関数
    private func dateAndTime(from timeString: String, on date: Date) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm" // 時間の形式を "HH:mm" に設定
        dateFormatter.locale = Locale(identifier: "ja_JP") // 必要に応じてロケールを設定

        // 時間文字列をDateオブジェクトに変換
        guard let time = dateFormatter.date(from: timeString) else {
            return nil // 時間文字列が不正な場合はnilを返す
        }

        let calendar = Calendar.current

        // スケジュールの日付の年、月、日を取得
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)

        // 時間のDateオブジェクトから時間と分を取得
        let timeComponents = calendar.dateComponents([.hour, .minute], from: time)

        // 日付と時間を組み合わせたDateオブジェクトを作成
        var components = DateComponents()
        components.year = dateComponents.year
        components.month = dateComponents.month
        components.day = dateComponents.day
        components.hour = timeComponents.hour
        components.minute = timeComponents.minute

        return calendar.date(from: components)
    }
}

extension CatDataStore {
    // MARK: - 現在の時間と位置情報がスケジュールに含まれるなら、そのスケジュールにいる猫の「名前」を返す関数
    func getCatNameInCurrentSchedule(currentLocation: CLLocation?) -> String? {
        guard let currentLocation = currentLocation else {
            print("現在の位置情報が利用できません。")
            return nil
        }

        let currentDate = Date()
        let calendar = Calendar.current

        // 現在の時刻が含まれるスケジュールをフィルタリング
        let relevantSchedules = allSchedules.filter { schedule in
            let scheduleDate = calendar.startOfDay(for: schedule.date)
            let today = calendar.startOfDay(for: currentDate)

            let startTimeDate = dateAndTime(from: schedule.startTime, on: scheduleDate)
            let endTimeDate = dateAndTime(from: schedule.endTime, on: scheduleDate)

            guard let startTime = startTimeDate, let endTime = endTimeDate else {
                print("スケジュールの時間の解析に失敗しました。")
                return false
            }

            let isInTimeRange = (startTime ... endTime).contains(currentDate)
            let isToday = scheduleDate == today

            return isToday && isInTimeRange
        }

        // 関連するスケジュールがない場合はNULLを返す
        guard let schedule = relevantSchedules.first else {
            print("現在の時間に含まれるスケジュールはありません。")
            return nil
        }

        // スケジュールに関連付けられた場所を取得
        guard let scheduleLocation = allLocations.first(where: { $0.id == schedule.locationId }) else {
            print("スケジュールに関連付けられた場所が見つかりません。")
            return nil
        }

        // 場所の座標を作成
        let scheduleLocationCLLocation = CLLocation(latitude: scheduleLocation.latitude, longitude: scheduleLocation.longitude)

        // 距離を計算 (メートル単位)
        let distanceInMeters = currentLocation.distance(from: scheduleLocationCLLocation)

        // 1km以内ではない場合はNULLを返す
        guard distanceInMeters <= 1000 else {
            print("スケジュールされている地点が1km圏内にありません。")
            return nil
        }

        // スケジュールに紐づく猫の名前を返す
        guard let cat = allCats.first(where: { $0.id == schedule.catId }) else {
            print("スケジュールに関連付けられた猫が見つかりません。")
            return nil
        }

        return cat.name
    }
}
