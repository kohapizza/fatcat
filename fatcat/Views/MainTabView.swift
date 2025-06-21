//
//  MainTabView.swift
//  fatcat
//
//  Created by 佐伯小遥 on 2025/06/21.
//

import Foundation
import SwiftUI
import AVFoundation

struct MainTabView: View {
    @Binding var cat: Cat
    @Binding var fish: Fish
    @Binding var isFishPlaced: Bool
    @Binding var showFeedButton: Bool
    @Binding var statusMessage: String
    @Binding var niboshiCount: Int
    @State private var isCatPlaced: Bool = false

    @State private var audioPlayer: AVAudioPlayer?
    
    // ★追加: ハートのエフェクト表示を制御するプロパティ
    @State private var showHeartEffect: Bool = false
    @State private var heartEffectPosition: CGPoint = .zero
    @State private var heartEffectId: UUID = UUID() // エフェクトを再トリガーするためのID

    var body: some View {
        ZStack {
            // AR画面（背景）
            ARViewContainer(
                cat: $cat,
                fish: $fish,
                isFishPlaced: $isFishPlaced,
                showFeedButton: $showFeedButton,
                statusMessage: $statusMessage,
                niboshiCount: $niboshiCount,
                isCatPlaced: $isCatPlaced
            )
            .ignoresSafeArea()
            
            // UI部分（前面）
            VStack {
                // 上部の情報表示
                TopInfoBar(cat: $cat, niboshiCount: $niboshiCount)
                
                Spacer()
                
                // 状況メッセージ
                StatusMessageView(statusMessage: $statusMessage)
                
                // ボタン類
                if isCatPlaced {
                    ActionButtons(showFeedButton: $showFeedButton, catIsHungry: cat.isHungry, feedCat: feedCat, niboshiCount: $niboshiCount, statusMessage: $statusMessage)
                }
            }

            // ★追加: ハートのエフェクトをARViewの上にオーバーレイ
            if showHeartEffect {
                HeartEffectView(position: heartEffectPosition)
                    .id(heartEffectId) // IDを変更することでViewを再生成し、アニメーションを再実行
                    .transition(.opacity) // フェードイン・アウトのトランジション
                    .animation(.easeOut(duration: 1.5), value: showHeartEffect) // アニメーションの継続時間
            }
        }
    }
    
    // 餌やり処理
    private func feedCat() {
        guard niboshiCount > 0 else {
            statusMessage = "煮干しがありません！補充してください"
            return
        }
        
        niboshiCount -= 1
        cat.feed()
        statusMessage = "にゃーん！猫が大きくなりました！"
        
        playCatSound()
        
        // ★追加: ハートのエフェクトをトリガー
        triggerHeartEffect()
    }

    private func playCatSound() {
        guard let url = Bundle.main.url(forResource: "female_cat1", withExtension: "mp3") else {
            print("Error: female_cat1.mp3 not found")
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Error playing sound: \(error.localizedDescription)")
        }
    }

    // ★追加: ハートのエフェクトをトリガーする関数
    private func triggerHeartEffect() {
        // ハートのエフェクトを表示する位置を猫のモデルがあるあたりに設定（画面中央付近など）
        // 実際の猫のAR空間での位置と合わせる場合は、ARViewContainerから座標をBindingで受け取る必要がありますが、
        // ここでは簡単に画面中央に表示されるように仮置きします。
        // 例: 画面中央
        heartEffectPosition = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2 - 50)
        
        showHeartEffect = true
        heartEffectId = UUID() // 新しいIDを生成してアニメーションをリセット

        // 一定時間後にエフェクトを非表示にする
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { // アニメーション時間に合わせて調整
            showHeartEffect = false
        }
    }
}
