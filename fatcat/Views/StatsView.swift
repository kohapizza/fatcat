//
//  StatsView.swift
//  fatcat
//
//  Created by 佐伯小遥 on 2025/06/22.
//

import Foundation
import SwiftUI

// MARK: - 統計画面
struct StatsView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // 統計サマリー
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        StatCard(title: "総猫数", value: "12匹", icon: "cat.fill", color: .orange)
                        StatCard(title: "餌やり回数", value: "89回", icon: "fish.fill", color: .blue)
                        StatCard(title: "連続日数", value: "7日", icon: "flame.fill", color: .red)
                        StatCard(title: "お気に入り", value: "研究室", icon: "heart.fill", color: .pink)
                    }
                    .padding(.horizontal, 20)
                    
                    // 活動履歴
                    VStack(alignment: .leading, spacing: 16) {
                        Text("最近の活動")
                            .font(.headline)
                            .fontWeight(.bold)
                            .padding(.horizontal, 20)
                        
                        VStack(spacing: 12) {
                            ActivityRow(icon: "fish.fill", text: "研究室の白猫に煮干をあげました", time: "2分前")
                            ActivityRow(icon: "cat.fill", text: "新しい茶トラが研究室に現れました", time: "1時間前")
                            ActivityRow(icon: "heart.fill", text: "黒猫があなたを覚えました", time: "3時間前")
                            ActivityRow(icon: "star.fill", text: "7日連続記録を達成しました", time: "昨日")
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.vertical, 20)
            }
            .navigationTitle("統計")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct ActivityRow: View {
    let icon: String
    let text: String
    let time: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.orange)
                .frame(width: 25)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(text)
                    .font(.subheadline)
                
                Text(time)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(height: 100)
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}



struct StatsView_Previews: PreviewProvider {
    static var previews: some View {
        StatsView()
    }
}

