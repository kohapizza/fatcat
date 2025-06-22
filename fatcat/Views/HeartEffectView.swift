//
//  HeartEffectView.swift
//  fatcat
//
//  Created by 喜多陽花 on 2025/06/22.
//

import SwiftUI

struct HeartEffectView: View {
    let position: CGPoint
    @State private var opacity: Double = 1.0
    @State private var scale: CGFloat = 0.5
    @State private var offset: CGSize = .zero

    var body: some View {
        Image(systemName: "heart.fill") // ハートのSF Symbolを使用
            .font(.system(size: 80)) // ハートのサイズ
            .foregroundColor(.pink) // ハートの色
            .opacity(opacity)
            .scaleEffect(scale)
            .offset(offset)
            .position(position)
            .onAppear {
                // アニメーション設定
                withAnimation(.easeOut(duration: 1.5)) { // アニメーションの継続時間
                    opacity = 0.0 // フェードアウト
                    scale = 1.5 // 大きくなる
                    offset.height = -100 // 上に移動
                }
            }
    }
}
