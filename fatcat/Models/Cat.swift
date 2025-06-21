//
//  Cat.Swift
//  fatcat
//
//  Created by 佐伯小遥 on 2025/06/21.
//

import Foundation

// 猫の情報を管理する構造体
struct Cat {
    var name: String = "にゃんこ"
    var size: Float = 0.01        // 猫のサイズ
    var feedCount: Int = 0       // 餌をあげた回数
    var isHungry: Bool = true    // お腹が空いているか
    
    // 餌をあげる処理
    mutating func feed() {
        feedCount += 1
        size += 0.01  // 少し大きくなる
        isHungry = false
    }
}

struct CatType {
    let name: String
    let emoji: String
    let description: String
    let unlocked: Bool
}

struct Fish {
    var size: Float = 0.1
}
