//
//  MainTabView.swift
//  fatcat
//
//  Created by 佐伯小遥 on 2025/06/21.
//

import Foundation
import SwiftUI
import AVFoundation
import UIKit // Import UIKit for screenshot functionality

struct MainTabView: View {
    @Binding var cat: Cat
    @Binding var fish: Fish
    @Binding var isFishPlaced: Bool
    @Binding var showFeedButton: Bool
    @Binding var statusMessage: String
    @Binding var niboshiCount: Int
    @State private var isCatPlaced: Bool = false
    @State private var isTakingScreenshot: Bool = false // Add state for screenshot

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
                isCatPlaced: $isCatPlaced,
                isTakingScreenshot: $isTakingScreenshot // Pass the new binding
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
                    
                    // MARK: - Photo Button
                    Button(action: {
                        self.isTakingScreenshot = true // Trigger screenshot
                    }) {
                        Image(systemName: "camera.fill")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                    }
                    .padding(.bottom, 20)
                }
            }

            // ハートのエフェクトをARViewの上にオーバーレイ
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
            statusMessage = "煮干しがないよ！補充しよう。"
            return
        }
        
        niboshiCount -= 1
        cat.feed()
        statusMessage = "にゃーん！猫が大きくなったよ！"
        
        playCatSound()
        
        // ハートのエフェクトをトリガー
        triggerHeartEffect()
    }

    private func playCatSound() {
        guard let url = Bundle.main.url(forResource: "female_cat1", withExtension: "mp3") else {
            print("Error: female_cat1.mp3 not found")
            return
        }

        do {
            // AVAudioSessionの設定を追加
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)

            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay() // これを追加することで再生の準備を確実にする
            audioPlayer?.play()
            
            if audioPlayer?.isPlaying == true { // 再生が開始されたか確認
                print("Sound playing successfully.")
            } else {
                print("Problem: Sound not playing after play() call.")
            }

        } catch {
            print("Error playing sound: \(error.localizedDescription)")
        }
    }

    // ハートのエフェクトをトリガーする関数
    private func triggerHeartEffect() {
        // ハートのエフェクトを表示する位置を設定
        // 画面中央に表示
        heartEffectPosition = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2 - 50)
        
        showHeartEffect = true
        heartEffectId = UUID() // 新しいIDを生成してアニメーションをリセット

        // 一定時間後にエフェクトを非表示にする
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { // アニメーション時間に合わせて調整
            showHeartEffect = false
        }
    }
}
