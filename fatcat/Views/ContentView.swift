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
    
    // tabbarの選択状態を管理
    @State private var selectedTab = 0
    
    @State private var showFullScreenModal = false
    
    // AR関連の状態
    // isFishPlaced に変更
    @State private var isFishPlaced = false
    @State private var showFeedButton = false
    @State private var statusMessage = "画面をタップして魚のぬいぐるみを配置してください"
    
    // 現在地を取得するためのバインディング
    @State private var locationManager = LocationManager()
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                SettingsTabView(
                    cat: $cat,
                    selectedLocation: $selectedLocation,
                    showingLocationSearch: $showingLocationSearch,
                    resetData: resetData
                )
                .tag(0)
                
                ScheduleView()
                    .tag(2)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            // カスタムタブバー
            VStack(alignment: .leading) {
                Spacer()
                HStack {
                    // Item 1
                    TabButton(title: "設定", isSelected: selectedTab == 0) {
                        selectedTab = 0
                    }
                    
                    
                    // 中央の目立つボタン
                    Button(action: {
                        showFullScreenModal = true
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 70, height: 70)
                                .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
                            
                            Image(systemName: "camera.fill")
                                .foregroundColor(.white)
                                .font(.system(size: 28))
                        }
                    }
                    .offset(y: -15) // 少し上に配置
                    
                    // Item 0
                    TabButton(title: "予定", isSelected: selectedTab == 2) {
                        selectedTab = 2
                    }
                    
                    
                }
                .background(Color(.systemGray6))
            }
        }
        .onAppear {
            startHungerTimer()
            locationManager.requestLocationAuthorization()
            locationManager.startUpdatingLocation()
        }
        .fullScreenCover(isPresented: $showFullScreenModal) {
            // ここにMainTabViewを配置
            MainTabView(
                cat: $cat,
                fish: $fish,
                isFishPlaced: $isFishPlaced,
                showFeedButton: $showFeedButton,
                statusMessage: $statusMessage,
                niboshiCount: $niboshiCount
            )
            .overlay(
                // 左上にクローズボタンを追加
                VStack {
                        HStack {
                            Button(action: {
                                showFullScreenModal = false
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(Color.white.opacity(0.2))
                                        .frame(width: 44, height: 44)
                                    
                                    Image(systemName: "xmark")
                                        .foregroundColor(.white)
                                        .font(.system(size: 18, weight: .medium))
                                }
                            }
                            .padding(.top, 10)
                            .padding(.leading, 20)  // trailing から leading に変更
                            
                            Spacer()  // Spacer を右側に移動
                        }
                        Spacer()
                    }
            )
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

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                HStack(spacing: 2) {
                    ForEach(0..<3) { _ in
                        RoundedRectangle(cornerRadius: 1)
                            .fill(isSelected ? Color.blue : Color.gray)
                            .frame(width: 8, height: 2)
                    }
                }
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(isSelected ? .blue : .gray)
            }
        }
        .frame(maxWidth: .infinity)
    }
}


struct ContentView_Preview: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
