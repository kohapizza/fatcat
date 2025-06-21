//
//  LocationSearchSwiftUI.swift
//  fatcat
//
//  Created by 佐伯小遥 on 2025/06/21.
//

import SwiftUI
import MapKit
import CoreLocation // CLLocationCoordinate2Dのために必要

// MARK: - MKLocalSearchCompleterのラッパー（ObservableObject）

class LocationSearchCompleter: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    @Published var queryFragment: String = "" {
        didSet {
            // queryFragmentが変更されたら、サジェストを更新
            if queryFragment.isEmpty {
                // クエリが空の場合は結果をクリア
                results = []
            } else {
                completer.queryFragment = queryFragment
            }
        }
    }

    @Published var results: [MKLocalSearchCompletion] = []
    @Published var isLoading: Bool = false // ロード状態を管理するプロパティ

    private let completer = MKLocalSearchCompleter()

    override init() {
        super.init()
        completer.delegate = self
        // オプション: 検索範囲を設定（例: 東京周辺に限定）
        // 現在地がMinato City, Tokyo, Japanなので、それに合わせた範囲を設定できます。
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 35.664035, longitude: 139.730302), latitudinalMeters: 50000, longitudinalMeters: 50000) // 例: 港区中心
        completer.region = region
        // オプション: 結果タイプをフィルタリング (例: 地点と住所のみ)
        completer.resultTypes = [.pointOfInterest, .address]
    }

    // MARK: - MKLocalSearchCompleterDelegate

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        self.results = completer.results
        self.isLoading = false // ロード完了
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Error fetching completer results: \(error.localizedDescription)")
        self.isLoading = false // ロード完了（エラー時）
        // エラー表示などの処理を追加することも可能
    }
}

// MARK: - 場所のサジェストビュー（SwiftUI）

struct LocationSearchSwiftUI: View {
    @Environment(\.presentationMode) var presentationMode // モーダルを閉じるために必要
    @Binding var selectedLocation: Location? // 選択された場所をバインディングで受け取る

    @StateObject private var completer = LocationSearchCompleter() // @StateObjectでライフサイクルを管理
    @State private var searchText: String = ""

    var body: some View {
        NavigationView { // モーダル内でナビゲーションバーを表示するためにNavigationViewを追加
            VStack {
                HStack {
                    // 検索バー
                    TextField("場所を検索", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                        .onChange(of: searchText) { newValue in
                            completer.queryFragment = newValue // TextFieldの入力とCompleterをバインド
                            completer.isLoading = true // ロード開始
                        }
                    
                    // キャンセルボタン（任意）
                    if !searchText.isEmpty {
                        Button("キャンセル") {
                            searchText = ""
                            completer.queryFragment = ""
                            // キーボードを閉じる
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }
                        .padding(.trailing)
                    }
                }
                .padding(.top, 8)

                // ロード中のインジケーター
                if completer.isLoading && !searchText.isEmpty {
                    ProgressView()
                        .padding()
                } else if completer.results.isEmpty && !searchText.isEmpty {
                    Text("検索結果が見つかりませんでした")
                        .foregroundColor(.gray)
                        .padding()
                }

                // サジェスト結果リスト
                List(completer.results, id: \.self) { suggestion in
                    // 各サジェストをタップしたときの動作
                    Button {
                        // ここで選択されたサジェストの詳細情報を取得し、次の画面へ渡すなどします。
                        // 例: MKLocalSearch を使って詳細情報を取得
                        let searchRequest = MKLocalSearch.Request(completion: suggestion)
                        let search = MKLocalSearch(request: searchRequest)

                        search.start { (response, error) in
                            guard let response = response, error == nil else {
                                print("Error getting search details: \(error?.localizedDescription ?? "Unknown error")")
                                return
                            }

                            if let mapItem = response.mapItems.first {
                                print("選択された場所: \(mapItem.name ?? ""), 座標: \(mapItem.placemark.coordinate.latitude), \(mapItem.placemark.coordinate.longitude)")
                                
                                // 現在地からの距離を計算（ここでは固定値を使用、実際にはCLLocationManagerで現在地を取得）
                                // 現在の場所: Minato City, Tokyo, Japan
                                let currentLocation = CLLocation(latitude: 35.664035, longitude: 139.730302) // 港区の例
                                let destinationLocation = mapItem.placemark.location!
                                let distanceInMeters = currentLocation.distance(from: destinationLocation)
                                let distanceInKm = distanceInMeters / 1000.0

                                selectedLocation = Location(
                                    name: mapItem.name ?? "不明な場所",
                                    address: mapItem.placemark.title,
                                    latitude: mapItem.placemark.coordinate.latitude,
                                    longitude: mapItem.placemark.coordinate.longitude,
                                    distance: distanceInKm
                                )
                                
                                // モーダルを閉じる
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                    } label: {
                        VStack(alignment: .leading) {
                            Text(suggestion.title)
                                .font(.headline)
                            Text(suggestion.subtitle)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .listStyle(.plain) // リストのスタイルを調整
            }
            .navigationTitle("場所を検索") // このビューのナビゲーションタイトル
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { // 閉じるボタンを追加
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("閉じる") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}
