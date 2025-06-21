//
//  ContentView.swift
//  fatcat
//
//  Created by 佐伯小遥 on 2025/06/16.
//

import SwiftUI

struct ContentView: View {
    // 猫の状態
    @State private var cat = Cat()
    
    @State private var showingLocationSearch = false // モーダル表示の状態を管理
    @State private var selectedLocation: Location? // 選択された位置情報を保持
    
    // 煮干しの個数
    @State private var niboshiCount = 5
    
    // AR関連の状態
    @State private var isCatPlaced = false
    @State private var showFeedButton = false
    @State private var statusMessage = "画面をタップして猫を配置してください"
    
    var body: some View {
        TabView {
            MainTabView(
                cat: $cat,
                niboshiCount: $niboshiCount,
                isCatPlaced: $isCatPlaced,
                showFeedButton: $showFeedButton,
                statusMessage: $statusMessage
            )
            .tabItem {
                Label("猫を探す", systemImage: "pawprint")
            }
            
            SettingsTabView(
                cat: $cat,
                selectedLocation: $selectedLocation,
                showingLocationSearch: $showingLocationSearch,
                resetData: resetData
            )
            .tabItem {
                Label("設定", systemImage: "gear")
            }
        }
        .onAppear {
            startHungerTimer()
        }
    }
    
    // 餌やり処理
    private func feedCat() {
        // 煮干しがない場合
        guard niboshiCount > 0 else {
            statusMessage = "煮干しがありません！補充してください"
            return
        }
        
        // 餌やり実行
        niboshiCount -= 1
        cat.feed()
        statusMessage = "にゃーん！猫が大きくなりました！"
        showFeedButton = false
    }
    
    // お腹を空かせるタイマー
    private func startHungerTimer() {
        Timer.scheduledTimer(withTimeInterval: 15.0, repeats: true) { _ in
            if isCatPlaced && !cat.isHungry {
                cat.isHungry = true
                showFeedButton = true
                statusMessage = "猫がお腹を空かせています"
            }
        }
    }
    
    // データリセット
    private func resetData() {
        cat = Cat()
        niboshiCount = 5
        statusMessage = "データをリセットしました"
        selectedLocation = nil // 追加：位置情報もリセット
    }
}
