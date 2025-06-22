//
//  CatSelectionView.swift
//  fatcat
//
//  Created by 佐伯小遥 on 2025/06/22.
//

import Foundation
import SwiftUI

// MARK: - 猫選択画面
struct CatSelectionView: View {
    @EnvironmentObject var dataStore: CatDataStore
    @State private var selectedCatType = "白猫"
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
//                    // 現在選択中の猫
//                    VStack(spacing: 16) {
//                        Text("現在の相棒")
//                            .font(.headline)
//                            .fontWeight(.bold)
//                        
//                        if let currentCat = dataStore.allCatTypes.first(where: { $0.name == selectedCatType }) {
//                            VStack(spacing: 12) {
//                                Text(currentCat.emoji)
//                                    .font(.system(size: 80))
//                                    .scaleEffect(1.0)
//                                    
//                                Text(currentCat.name)
//                                    .font(.title2)
//                                    .fontWeight(.bold)
//                                
//                                Text(currentCat.description)
//                                    .font(.subheadline)
//                                    .foregroundColor(.secondary)
//                                    .multilineTextAlignment(.center)
//                            }
//                            .padding(24)
//                            .background(
//                                RoundedRectangle(cornerRadius: 20)
//                                    .fill(LinearGradient(
//                                        colors: [.orange.opacity(0.1), .pink.opacity(0.1)],
//                                        startPoint: .topLeading,
//                                        endPoint: .bottomTrailing
//                                    ))
//                            )
//                        }
//                    }
//                    .padding(.horizontal, 20)
                    
                    // 猫の種類選択
//                    VStack(alignment: .leading, spacing: 16) {
//                        Text("猫を選ぶ")
//                            .font(.headline)
//                            .fontWeight(.bold)
//                            .padding(.horizontal, 20)
//                        
//                        LazyVGrid(columns: [
//                            GridItem(.flexible()),
//                            GridItem(.flexible())
//                        ], spacing: 16) {
//                            ForEach(dataStore.allCatTypes, id: \.name) { catType in
//                                CatSelectionCard(
//                                    catType: catType,
//                                    isSelected: selectedCatType == catType.name
//                                ) {
//                                    if catType.unlocked {
//                                        selectedCatType = catType.name
//                                    }
//                                }
//                            }
//                        }
//                        .padding(.horizontal, 20)
//                    }
                }
                .padding(.vertical, 20)
            }
            .navigationTitle("猫図鑑")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct UnlockConditionRow: View {
    let icon: String
    let condition: String
    let progress: Double
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 25)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(condition)
                    .font(.subheadline)
                
                ProgressView(value: progress)
                    .tint(.orange)
            }
            
            Text("\(Int(progress * 100))%")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct CatSelectionCard: View {
    let catType: CatType
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 12) {
                Text(catType.emoji)
                    .font(.system(size: 40))
                    .opacity(catType.unlocked ? 1.0 : 0.3)
                
                Text(catType.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(catType.unlocked ? .primary : .secondary)
                
                if !catType.unlocked {
                    Image(systemName: "lock.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(height: 120)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.orange.opacity(0.2) : Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? Color.orange : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!catType.unlocked)
    }
}



struct CatSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        CatSelectionView()
    }
}
