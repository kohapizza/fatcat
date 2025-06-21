//
//  MainTabView.swift
//  fatcat
//
//  Created by 佐伯小遥 on 2025/06/21.
//

import Foundation
import SwiftUI

struct MainTabView: View {
    @Binding var cat: Cat
    @Binding var fish: Fish
    @Binding var isFishPlaced: Bool
    @Binding var showFeedButton: Bool
    @Binding var statusMessage: String
    @Binding var niboshiCount: Int
    
    var body: some View {
        ZStack {
            // AR画面（背景）
            ARViewContainer(
                cat: $cat,
                fish: $fish,
                isFishPlaced: $isFishPlaced,
                showFeedButton: $showFeedButton,
                statusMessage: $statusMessage,
                niboshiCount: $niboshiCount
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
                ActionButtons(showFeedButton: $showFeedButton, catIsHungry: cat.isHungry, feedCat: feedCat, niboshiCount: $niboshiCount, statusMessage: $statusMessage)
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
        // ARViewContainerのhandleTapでshowFeedButtonをtrueにしているので、ここではfalseにする必要はありません。
        // showFeedButton = false
    }
}
