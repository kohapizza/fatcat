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
    // 魚の状態 (新しく追加)
    @State private var fish = Fish()
    
    @State private var showingLocationSearch = false // モーダル表示の状態を管理
    @State private var selectedLocation: Location? // 選択された位置情報を保持
    
    // 煮干しの個数
    @State private var niboshiCount = 5
    
    // AR関連の状態
    // isFishPlaced に変更
    @State private var isFishPlaced = false
    @State private var showFeedButton = false
    @State private var statusMessage = "画面をタップして魚のぬいぐるみを配置してください"
    
    @State private var locationManager = LocationManager()
    
    var body: some View {
        TabView {
            SettingsTabView(
                cat: $cat,
                selectedLocation: $selectedLocation,
                showingLocationSearch: $showingLocationSearch,
                resetData: resetData,
                locationManager: $locationManager // LocationManager を渡す
            )
            .tabItem {
                Label("設定", systemImage: "gear")
            }
            
            
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
        }
        .onAppear {
            startHungerTimer()
            locationManager.requestLocationAuthorization()
            locationManager.startUpdatingLocation()
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
                Text("サイズ: \(String(format: "%.1f", cat.size))倍")
                    .font(.caption)
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
    
    // アクションボタン
    private var actionButtons: some View {
        VStack(spacing: 12) {
            // 餌やりボタン
            // isFishPlaced かつ cat.isHungry の場合に表示
            if isFishPlaced && cat.isHungry {
                Button("🐟 餌をあげる") {
                    feedCat()
                }
                .buttonStyle(FeedButtonStyle())
            }
            
            // 煮干し補充ボタン
            Button("🛒 煮干しを補充 (+3個)") {
                niboshiCount += 3
                statusMessage = "煮干しを補充しました！"
            }
            .buttonStyle(ShopButtonStyle())
        }
        .padding(.bottom, 30)
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
            // isFishPlaced に変更
            if isFishPlaced && !cat.isHungry {
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
