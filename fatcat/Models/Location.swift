import Foundation
import CoreLocation

// LocationSearchSwiftUIからのデータを保持する構造体
struct Location: Identifiable, Hashable { // Hashableを追加することでListのid: \.selfで使える
    let id = UUID()
    let name: String
    let address: String?
    let latitude: CLLocationDegrees
    let longitude: CLLocationDegrees
    var distance: Double // km単位の距離
}
