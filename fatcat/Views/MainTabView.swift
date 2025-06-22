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
    @Binding var niboshiCount: Int
    @State private var isCatPlaced: Bool = false
    @State private var isTakingScreenshot: Bool = false // Add state for screenshot

    @State private var audioPlayer: AVAudioPlayer?
    @State private var bgmPlayer: AVAudioPlayer? // Add bgmPlayer
    
    // ★追加: ハートのエフェクト表示を制御するプロパティ
    @State private var showHeartEffect: Bool = false
    @State private var heartEffectPosition: CGPoint = .zero
    @State private var heartEffectId: UUID = UUID() // エフェクトを再トリガーするためのID

    @State private var isInLocation: Bool = false // ifInLocationの結果を保持する新しいState

    // MARK: - ここから変更
    @State var statusMessage: String = "" // 初期値を空文字列に変更
    // MARK: - ここまで変更

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
                isTakingScreenshot: $isTakingScreenshot, // Pass the new binding
                isInLocation: $isInLocation // 新しいバインディングを渡す
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
        .onAppear {
            // MARK: - ここから変更
            // ARViewContainerからのisInLocationの値がtrueの場合のみBGMを再生
            if isInLocation {
                playBackgroundMusic()
                statusMessage = "画面をタップしてぬいぐるみを置いてみよう！" // 初期メッセージを設定
            } else {
                print("Not in location, BGM will not play.")
                statusMessage = "ここには猫はいないみたい…" // 位置情報がfalseの場合のメッセージ
            }
            // MARK: - ここまで変更
        }
        .onDisappear {
            bgmPlayer?.stop() // Stop BGM when the view disappears
            bgmPlayer = nil // Release the player
        }
        .onChange(of: isInLocation) { newValue in
            if newValue {
                playBackgroundMusic()
                statusMessage = "画面をタップしてぬいぐるみを置いてみよう！" // 位置情報がtrueになった場合のメッセージ
            } else {
                bgmPlayer?.stop()
                bgmPlayer = nil
                print("Location changed, stopping BGM.")
                statusMessage = "ここには猫はいないみたい…" // 位置情報がfalseになった場合のメッセージ
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

    // MARK: - Background Music
    private func playBackgroundMusic() {
        // BGMがすでに再生中の場合は何もしない
        if bgmPlayer?.isPlaying == true {
            return
        }
        
        guard let url = Bundle.main.url(forResource: "bgm", withExtension: "mp3") else {
            print("Error: bgm.mp3 not found")
            return
        }

        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers]) // Allow mixing with other sounds
            try session.setActive(true)

            bgmPlayer = try AVAudioPlayer(contentsOf: url)
            bgmPlayer?.numberOfLoops = -1 // Loop indefinitely
            bgmPlayer?.volume = 0.5 // Adjust volume as needed
            bgmPlayer?.prepareToPlay()
            bgmPlayer?.play()

            if bgmPlayer?.isPlaying == true {
                print("BGM playing successfully.")
            } else {
                print("Problem: BGM not playing after play() call.")
            }
        } catch {
            print("Error playing BGM: \(error.localizedDescription)")
        }
    }
}
