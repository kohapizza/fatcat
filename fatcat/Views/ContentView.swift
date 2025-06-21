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
    
    // 煮干しの個数
    @State private var niboshiCount = 5
    
    // AR関連の状態
    @State private var isCatPlaced = false
    @State private var showFeedButton = false
    @State private var statusMessage = "画面をタップして猫を配置してください"
    
    var body: some View {
        ZStack {
            // AR画面（背景）
            ARViewContainer(
                cat: $cat,
                isCatPlaced: $isCatPlaced,
                showFeedButton: $showFeedButton,
                statusMessage: $statusMessage
            )
            .ignoresSafeArea()
            
            // UI部分（前面）
            VStack {
                // 上部の情報表示
                topInfoBar
                
                Spacer()
                
                // 状況メッセージ
                statusMessageView
                
                // ボタン類
                actionButtons
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
            if showFeedButton && cat.isHungry {
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
            if isCatPlaced && !cat.isHungry {
                cat.isHungry = true
                showFeedButton = true
                statusMessage = "猫がお腹を空かせています"
            }
        }
    }
}

// 餌やりボタンのスタイル
struct FeedButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.orange)
            .foregroundColor(.white)
            .cornerRadius(15)
            .shadow(radius: 5)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .padding(.horizontal)
    }
}

// ショップボタンのスタイル
struct ShopButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(Color.green.opacity(0.8))
            .foregroundColor(.white)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .padding(.horizontal)
    }
}

#Preview {
    ContentView()
}
