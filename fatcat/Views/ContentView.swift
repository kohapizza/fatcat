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
    // 魚の状態
    @State private var fish = Fish()
    @State private var showingLocationSearch = false // モーダル表示の状態を管理
    @State private var selectedLocation: Location? // 選択された位置情報を保持
    
    // 煮干しの個数
    @State private var niboshiCount = 5
    
    // AR関連の状態
    @State private var isFishPlaced = false
    @State private var showFeedButton = false
    @State private var statusMessage = "画面をタップしてぬいぐるみを置いてみよう！"
    
    var body: some View {
        TabView {
            MainTabView(
                cat: $cat,
                fish: $fish, // fish を渡すように変更
                isFishPlaced: $isFishPlaced, // isCatPlaced から isFishPlaced に変更
                showFeedButton: $showFeedButton,
                statusMessage: $statusMessage,
                niboshiCount: $niboshiCount
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
    
    // 上部の情報バー
    private var topInfoBar: some View {
        HStack {
            // 猫の情報
            VStack(alignment: .leading) {
                Text("🐱 \(cat.name)")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            
            Spacer()
            
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
        .padding()
        .background(Color.black.opacity(0.3))
    }
    
    // 状況メッセージ
    private var statusMessageView: some View {
        Text(statusMessage)
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(.white)
            .padding()
            .background(Color.black.opacity(0.7))
            .cornerRadius(10)
            .padding()
    }
    
    // 餌やり処理
    private func feedCat() {
        // 煮干しがない場合
        guard niboshiCount > 0 else {
            statusMessage = "煮干しが足りないよ！補充しよう。"
            return
        }
        
        // 餌やり実行
        niboshiCount -= 1
        cat.feed()
        statusMessage = "にゃーん！猫が大きくなったよ！"
        showFeedButton = false
    }
    
    // お腹を空かせるタイマー
    private func startHungerTimer() {
        Timer.scheduledTimer(withTimeInterval: 15.0, repeats: true) { _ in
            // isFishPlaced に変更
            if isFishPlaced && !cat.isHungry {
                cat.isHungry = true
                showFeedButton = true
                statusMessage = "猫がお腹を空かせているみたい"
            }
        }
    }
    
    // データリセット
    private func resetData() {
        cat = Cat()
        niboshiCount = 5
        statusMessage = "データをリセットしました"
        selectedLocation = nil // 位置情報もリセット
    }
}
