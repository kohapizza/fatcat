//
//  ContentView.swift
//  fatcat
//
//  Created by 佐伯小遥 on 2025/06/16.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var locationManager: LocationManager
    // 猫の状態
    @State private var cat = Cat()
    // 魚の状態
    @State private var fish = Fish()
    @State private var showingLocationSearch = false // モーダル表示の状態を管理
    @State private var selectedLocation: CatLocation? // 選択された位置情報を保持
    
    // 煮干しの個数
    @State private var niboshiCount = 5
    
    // tabbarの選択状態を管理
    @State private var selectedTab = 0
    
    @State private var showFullScreenModal = false
    
    // AR関連の状態
    @State private var isFishPlaced = false
    @State private var showFeedButton = false
    // MARK: - ここから変更
    // MainTabViewが自身のロジックでstatusMessageを管理するため、ここでは初期値を設定しない
    // @State private var statusMessage = "画面をタップしてぬいぐるみを置いてみよう！"
    // MARK: - ここまで変更
    
    
    var body: some View {
        ZStack {
            // TabViewの代わりに条件分岐を使用
            Group {
                if selectedTab == 0 {
                    SettingsTabView(
                        cat: $cat,
                        selectedLocation: $selectedLocation,
                        showingLocationSearch: $showingLocationSearch,
                        resetData: resetData
                    )
                } else if selectedTab == 2 {
                    ScheduleView()
                }
            }
            
            // カスタムタブバー
            VStack(alignment: .leading) {
                Spacer()
                HStack {
                    // 設定タブ
                    TabButton(
                        title: "設定",
                        iconName: "gearshape.fill",
                        isSelected: selectedTab == 0
                    ) {
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
                    
                    // 予定タブ
                    TabButton(
                        title: "予定",
                        iconName: "calendar.circle.fill",
                        isSelected: selectedTab == 2
                    ) {
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
                // MARK: - ここから変更
                // MainTabViewで管理されるため、statusMessageは渡さない
                // statusMessage: $statusMessage,
                // MARK: - ここまで変更
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
    
    // 状況メッセージ (ContentViewからは削除される)
    /*
    private var statusMessageView: some View {
        Text(statusMessage)
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(.white)
            .padding()
            .background(Color.black.opacity(0.7))
            .cornerRadius(10)
            .padding()
    }
    */
    
    // 餌やり処理
    private func feedCat() {
        // 煮干しがない場合
        guard niboshiCount > 0 else {
            // MARK: - ここから変更
            // statusMessageはMainTabViewのプロパティなので、直接アクセスできない
            // MainTabViewのfeedCat関数がstatusMessageを更新するため、ここは削除
            // statusMessage = "煮干しが足りないよ！補充しよう"
            // MARK: - ここまで変更
            return
        }
        
        // 餌やり実行
        niboshiCount -= 1
        cat.feed()
        // MARK: - ここから変更
        // statusMessageはMainTabViewのプロパティなので、直接アクセスできない
        // MainTabViewのfeedCat関数がstatusMessageを更新するため、ここは削除
        // statusMessage = "にゃーん！猫が大きくなったよ！"
        // MARK: - ここまで変更
        showFeedButton = false
    }
    
    // お腹を空かせるタイマー
    private func startHungerTimer() {
        Timer.scheduledTimer(withTimeInterval: 15.0, repeats: true) { _ in
            // isFishPlaced に変更
            if isFishPlaced && !cat.isHungry {
                cat.isHungry = true
                showFeedButton = true
                // MARK: - ここから変更
                // statusMessageはMainTabViewのプロパティなので、直接アクセスできない
                // MainTabViewのfeedCat関数がstatusMessageを更新するため、ここは削除
                // statusMessage = "猫がお腹を空かせているみたい"
                // MARK: - ここまで変更
            }
        }
    }
    
    // データリセット
    private func resetData() {
        cat = Cat()
        niboshiCount = 5
        // MARK: - ここから変更
        // statusMessageはMainTabViewのプロパティなので、直接アクセスできない
        // MainTabViewのonAppear/onChangeでメッセージが設定されるため、ここでの設定は不要
        // statusMessage = "データをリセットしました"
        // MARK: - ここまで変更
        selectedLocation = nil // 位置情報もリセット
    }
}

struct TabButton: View {
    let title: String
    let iconName: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: iconName)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(isSelected ? .blue : .gray)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(isSelected ? .blue : .gray)
            }
            .padding(.vertical, 8)
        }
        .frame(maxWidth: .infinity)
    }
}

struct ContentView_Preview: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
