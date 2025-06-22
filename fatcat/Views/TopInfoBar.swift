//
//  TopInfoBar.swift
//  fatcat
//
//  Created by 佐伯小遥 on 2025/06/21.
//

import Foundation
import SwiftUI
import CoreLocation // CoreLocationをインポート

struct TopInfoBar: View {
    @ObservedObject var catDataStore: CatDataStore // CatDataStoreのインスタンスを監視
    @Binding var niboshiCount: Int
    @State private var currentCatName: String? = nil // 現在の猫の名前を保持するState

    // 現在地のダミーデータ (実際のアプリではCLLocationManagerから取得)
    let dummyCurrentLocation = CLLocation(latitude: 35.681236, longitude: 139.767125) // 例: 中央公園の緯度経度

    var body: some View {
        HStack {
            Spacer()

            HStack {
                // 猫の名前
                VStack(alignment: .leading) {
                    if let catName = currentCatName {
                        Text("🐱 \(catName)")
                            .font(.headline)
                            .foregroundColor(.white)
                    } else {
                        // nilの場合は非表示、または空のTextでスペースを確保
                        Text("")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                }

                // 煮干しの個数
                HStack {
                    Text("🐟")
                    Text("\(niboshiCount)")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.blue.opacity(0.8))
                .cornerRadius(20)
            }
        }
        .padding()
        .background(Color.black.opacity(0.3))
        .onAppear {
            // ビューが表示されたときに猫の名前を取得
            self.currentCatName = catDataStore.getCatNameInCurrentSchedule(currentLocation: dummyCurrentLocation)
        }
        // 必要に応じて、位置情報が更新されたり、時間が経過したりしたときに
        // currentCatNameを再評価するトリガーを追加できます。
        // 例: Timer.publishやCLLocationManagerDelegateの更新
    }
}
