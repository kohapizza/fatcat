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
    @Binding var niboshiCount: Int
    @Binding var isCatPlaced: Bool
    @Binding var showFeedButton: Bool
    @Binding var statusMessage: String
    
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
        showFeedButton = false
    }
}
