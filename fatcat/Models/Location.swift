//
//  Location.swift
//  fatcat
//
//  Created by 佐伯小遥 on 2025/06/21.
//

import Foundation // UUIDのために必要

// LocationSearchRepresentable.swiftでも同じ定義がされているが、
// 独立したファイルにすることで再利用しやすくなる。
// Identifiableに準拠させることで、SwiftUIのリストなどでの識別が可能になる。
struct Location: Identifiable {
    let id = UUID() // 各位置情報を一意に識別するためのID
    let name: String
    let distance: Double // km単位（ダミーデータ用。実際は現在地からの計算）
    let address: String?
    let latitude: Double?
    let longitude: Double?
}
