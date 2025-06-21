//
//  MainTabView.swift
//  fatcat
//
//  Created by 佐伯小遥 on 2025/06/21.
//

import Foundation
import SwiftUI
import AVFoundation // ★追加: AVFoundationをインポート

struct MainTabView: View {
    @Binding var cat: Cat
    @Binding var fish: Fish
    @Binding var isFishPlaced: Bool
    @Binding var showFeedButton: Bool
    @Binding var statusMessage: String
    @Binding var niboshiCount: Int
    @State private var isCatPlaced: Bool = false // ★追加: 猫が配置されているかどうかのフラグ

    @State private var audioPlayer: AVAudioPlayer? // ★追加: オーディオプレイヤーを保持するプロパティ

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
                isCatPlaced: $isCatPlaced // ★追加: ARViewContainerにフラグを渡す
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
                // isCatPlacedがtrueの場合のみActionButtonsを表示
                if isCatPlaced { // ★変更: 猫が配置されている場合のみボタンを表示
                    ActionButtons(showFeedButton: $showFeedButton, catIsHungry: cat.isHungry, feedCat: feedCat, niboshiCount: $niboshiCount, statusMessage: $statusMessage)
                }
            }
        }
    }
    
    // 餌やり処理 (MainTabView内で管理する場合)
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
        
        // ★追加: 猫の鳴き声を再生
        playCatSound()
    }

    // ★追加: 猫の鳴き声を再生する関数
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
}
