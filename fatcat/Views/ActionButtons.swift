//
//  ActionButtons.swift
//  fatcat
//
//  Created by 佐伯小遥 on 2025/06/21.
//

import Foundation
import SwiftUI

struct ActionButtons: View {
    @Binding var showFeedButton: Bool
    var catIsHungry: Bool // `cat.isHungry` の状態を直接受け取る
    var feedCat: () -> Void // 餌やりアクションをクロージャとして受け取る
    @Binding var niboshiCount: Int // 煮干しのカウントをバインディングで受け取る
    @Binding var statusMessage: String // ステータスメッセージをバインディングで受け取る

    var body: some View {
        VStack(spacing: 12) {
            // 餌やりボタン
            if showFeedButton && catIsHungry {
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
}

struct StatusMessageView: View {
    @Binding var statusMessage: String
    
    var body: some View {
        Text(statusMessage)
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(.white)
            .padding()
            .background(Color.black.opacity(0.7))
            .cornerRadius(10)
            .padding()
    }
}
