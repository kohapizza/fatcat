//
//  CatScheduleManager.swift
//  fatcat
//
//  Created by 佐伯小遥 on 2025/06/21.
//

import Foundation
import SwiftUI
import CoreLocation

// MARK: - データモデル
struct CatModel: Identifiable, Codable {
    let id: UUID // catID
    let name: String
    let isHungry: Bool
    let size: Double
    let typeId: Int // ADDED: Link to CatTypeModel.typeId
}

struct CatTypeModel: Identifiable, Codable {
    let id: Int // typeId
    let fileName: String
    let catType: String // ADDED: "黒猫", "三毛猫", "白猫"などの種類
}

struct CatSchedule: Identifiable, Codable {
    let id: UUID // scheduleId
    let catId: UUID // ADDED: To link a schedule to a specific cat
    let locationId: UUID
    let date: Date
    let startTime: String
    let endTime: String
}

struct CatLocation: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let address: String?
    let latitude: CLLocationDegrees
    let longitude: CLLocationDegrees
}

