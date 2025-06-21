import SwiftUI

struct SettingsTabView: View {
    @Binding var cat: Cat
    @Binding var selectedLocation: Location?
    @Binding var showingLocationSearch: Bool // このStateをトリガーにモーダルを表示
    var resetData: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("設定")
                .font(.title)

            if let location = selectedLocation {
                Text("選択された位置情報: \(location.name)")
                    .font(.headline)
                Text("住所: \(location.address ?? "なし")")
                    .font(.subheadline)
                Text("初期設定距離: \(String(format: "%.1fkm", location.distance))")
                    .font(.subheadline)
            } else {
                Text("位置情報が選択されていません。")
                    .font(.headline)
                    .padding()
            }

            TextField("猫の名前を入力", text: $cat.name)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Button("位置情報を設定する") {
                showingLocationSearch = true // モーダルを表示する状態をtrueにする
            }
            .buttonStyle(ShopButtonStyle()) // ShopButtonStyleは別途定義されているものとします

            Button("🔄 リセット") {
                resetData()
            }
            .buttonStyle(ShopButtonStyle())

            Spacer()
        }
        .sheet(isPresented: $showingLocationSearch) { // sheetモディファイアを使用
            // モーダルとして表示するビューを指定
            LocationSearchSwiftUI(selectedLocation: $selectedLocation)
        }
        .padding()
    }
}
