//
//  CatScheduleManager.swift
//  fatcat
//
//  Created by 佐伯小遥 on 2025/06/21.
//

import Foundation
import SwiftUI

// MARK: - データモデル
struct CatModel: Identifiable, Codable {
    let id: UUID
    let name: String
    let isHungry: Bool
    let size: Double
    let typeID: Int // ADDED: Link to CatTypeModel
}

struct CatTypeModel: Identifiable, Codable {
    let id: Int
    let fileName: String
    let catType: String // ADDED: "黒猫", "三毛猫", "白猫"などの種類
}

struct CatSchedule: Identifiable, Codable {
    let id: Int
    let catID: UUID // ADDED: To link a schedule to a specific cat
    let locationID: Int
    let date: Date
    let startTime: String
    let endTime: String
}

struct CatLocation: Identifiable, Codable {
    let id: Int
    let locationName: String
    let locationAddress: String
    let lolgitude: Double
    let latitude: Double
}
