import Foundation

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
            CatModel(id: UUID(uuidString: "E621E1F8-C36C-495A-93FC-0C247A3E6E5F")!, name: "クロ", isHungry: true, size: 5.0, typeID: 1),
            CatModel(id: UUID(uuidString: "F621E1F8-C36C-495A-93FC-0C247A3E6E5F")!, name: "ミケ", isHungry: false, size: 4.5, typeID: 2),
            CatModel(id: UUID(uuidString: "A621E1F8-C36C-495A-93FC-0C247A3E6E5F")!, name: "シロ", isHungry: true, size: 5.2, typeID: 3),
            CatModel(id: UUID(uuidString: "B621E1F8-C36C-495A-93FC-0C247A3E6E5F")!, name: "トラ", isHungry: false, size: 4.8, typeID: 2),
            CatModel(id: UUID(uuidString: "C621E1F8-C36C-495A-93FC-0C247A3E6E5F")!, name: "ハチワレ", isHungry: true, size: 5.5, typeID: 1)
        ]
    }
    
    static var defaultCatTypes: [CatTypeModel] {
        [
            CatTypeModel(id: 1, fileName: "cat.fill", catType: "黒猫"),
            CatTypeModel(id: 2, fileName: "cat.circle.fill", catType: "三毛猫"),
            CatTypeModel(id: 3, fileName: "pawprint.fill", catType: "白猫")
        ]
    }
    
    static var defaultSchedules: [CatSchedule] {
        [
            CatSchedule(id: 1, catID: UUID(uuidString: "E621E1F8-C36C-495A-93FC-0C247A3E6E5F")!, locationID: 1, date: Calendar.current.date(byAdding: .day, value: 2, to: Date())!, startTime: "14:00", endTime: "17:00"),
            CatSchedule(id: 2, catID: UUID(uuidString: "F621E1F8-C36C-495A-93FC-0C247A3E6E5F")!, locationID: 2, date: Calendar.current.date(byAdding: .day, value: 2, to: Date())!, startTime: "14:00", endTime: "17:00"),
            CatSchedule(id: 3, catID: UUID(uuidString: "A621E1F8-C36C-495A-93FC-0C247A3E6E5F")!, locationID: 3, date: Calendar.current.date(byAdding: .day, value: 2, to: Date())!, startTime: "14:00", endTime: "17:00"),
            CatSchedule(id: 4, catID: UUID(uuidString: "B621E1F8-C36C-495A-93FC-0C247A3E6E5F")!, locationID: 54, date: Calendar.current.date(byAdding: .day, value: 2, to: Date())!, startTime: "14:00", endTime: "17:00"),
            CatSchedule(id: 5, catID: UUID(uuidString: "C621E1F8-C36C-495A-93FC-0C247A3E6E5F")!, locationID: 5, date: Calendar.current.date(byAdding: .day, value: 2, to: Date())!, startTime: "14:00", endTime: "17:00")
        ]
    }
    
    static var defaultLocations: [CatLocation] {
        [
            CatLocation(id: 1, locationName: "中央公園", locationAddress: "東京都中央区公園1-1", lolgitude: 139.767125, latitude: 35.681236),
            CatLocation(id: 2, locationName: "図書館裏", locationAddress: "東京都新宿区図書館2-2", lolgitude: 139.700000, latitude: 35.690000),
            CatLocation(id: 3, locationName: "商店街の角", locationAddress: "東京都渋谷区商店街3-3", lolgitude: 139.691700, latitude: 35.658000),
            CatLocation(id: 4, locationName: "川沿いの道", locationAddress: "東京都世田谷区川沿い4-4", lolgitude: 139.660000, latitude: 35.640000),
            CatLocation(id: 5, locationName: "駅前広場", locationAddress: "東京都港区駅前5-5", lolgitude: 139.750000, latitude: 35.660000)
        ]
    }
}
