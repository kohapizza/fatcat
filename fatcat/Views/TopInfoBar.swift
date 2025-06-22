//
//  TopInfoBar.swift
//  fatcat
//
//  Created by 佐伯小遥 on 2025/06/21.
//

import Foundation
import SwiftUI

struct TopInfoBar: View {
    @Binding var cat: Cat
    @Binding var niboshiCount: Int
    
    var body: some View {
        HStack {
            Spacer()
            
            HStack {
                
                // 猫の情報
                VStack(alignment: .leading) {
                    Text("🐱 \(cat.name)")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                
                
                // 煮干しの個数
                HStack {
                    Text("🐟")
                    Text("\(niboshiCount)")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.blue.opacity(0.8))
                .cornerRadius(20)
            }
        }
        .padding()
        .background(Color.black.opacity(0.3))
    }
}
