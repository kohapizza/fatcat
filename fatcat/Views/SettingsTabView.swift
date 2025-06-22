import SwiftUI

struct SettingsTabView: View {
    @State private var showingLocationTimeSetting = false
    @State private var notificationEnabled = true
    @State private var soundEnabled = true
    @Binding var cat: Cat
    @Binding var selectedLocation: CatLocation?
    @Binding var showingLocationSearch: Bool // このStateをトリガーにモーダルを表示
    @State private var date = Date()
    var resetData: () -> Void

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // ヘッダー
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "cat.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.orange)
                            
                            Text("Fat Cat")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                        }
                        
                        Text("憂鬱な場所を猫で癒そう")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 10)
                    
                    // クイック設定ボタン
                    VStack(spacing: 16) {
                        SettingButton(
                            title: "新しい猫を配置",
                            subtitle: "場所と時間を設定して猫を配置",
                            icon: "plus.circle.fill",
                            color: .orange
                        ) {
                            showingLocationTimeSetting = true
                        }
                        
                        SettingButton(
                            title: "餌の種類",
                            subtitle: "煮干し、かつお節など",
                            icon: "fish.fill",
                            color: .blue
                        ) {
                            // 餌の種類設定
                        }
                    }
                    
                    // 設定項目
                    VStack(spacing: 0) {
                        SettingToggleRow(
                            title: "通知",
                            subtitle: "猫の出現時間をお知らせ",
                            icon: "bell.fill",
                            isOn: $notificationEnabled
                        )
                        
                        SettingToggleRow(
                            title: "サウンド",
                            subtitle: "猫の鳴き声や効果音",
                            icon: "speaker.wave.2.fill",
                            isOn: $soundEnabled
                        )
                    }
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
                    
                }
                .padding(.horizontal, 20)
                
            }
            .navigationTitle("設定")
            .navigationBarTitleDisplayMode(.inline)
            
        }
        .sheet(isPresented: $showingLocationTimeSetting) {
            LocationTimeSettingView(showingLocationSearch: $showingLocationSearch, selectedLocation: $selectedLocation)
        }
    }
}



struct SettingToggleRow: View {
    let title: String
    let subtitle: String
    let icon: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 25)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.medium)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
}


struct SettingButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(20)
            .background(Color(.systemGray6))
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
