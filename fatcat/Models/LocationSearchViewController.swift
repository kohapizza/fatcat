//
//  LocationSearchViewController.swift
//  fatcat
//
//  Created by 佐伯小遥 on 2025/06/21.
//

import UIKit
import CoreLocation
import MapKit

// MARK: - LocationSelectionDelegate Protocol

// LocationSearchRepresentable.swiftでも同じ定義が必要ですが、
// ここに定義することで、このファイル単体でもプロトコルを確認できます。
// または、共通のSwiftファイルにプロトコルを定義して両方からimportする形も良いでしょう。

// MARK: - LocationSearchViewController

class LocationSearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating, CLLocationManagerDelegate {

    // MARK: - Properties

    // 選択されたLocationを通知するためのデリゲート
    weak var delegate: LocationSelectionDelegate?

    // UIコンポーネント
    let tableView = UITableView()
    let searchController = UISearchController(searchResultsController: nil)

    // 位置情報データ
    var allLocations: [Location] = [] // アプリが持つ全ての場所データ
    var filteredLocations: [Location] = [] // 検索バーでフィルタリングされた場所データ

    // 位置情報サービスマネージャー
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation? // ユーザーの現在地

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupSearchBar()
        setupTableView()
        setupLocationManager()

        // ダミーデータ（実際にはAPIなどから動的に取得することを想定）
        // Minato City, Tokyo, Japan を基準としたダミーデータ
        allLocations = [
            // 六本木エリア
            Location(name: "六本木グランドタワー", distance: 0.1, address: "港区六本木3-2-1", latitude: 35.663189, longitude: 139.737197),
            Location(name: "住友不動産六本木グランドタワー", distance: 0.1, address: "Minato", latitude: 35.663189, longitude: 139.737197),
            Location(name: "Roppongi", distance: 0.5, address: "Roppongi", latitude: 35.665793, longitude: 139.732442),
            Location(name: "六本木一丁目駅", distance: 0.1, address: nil, latitude: 35.664478, longitude: 139.738872),
            Location(name: "DMM.com", distance: 0.1, address: "六本木3-2-1 住友不動産六本木グランドタワー...", latitude: 35.663189, longitude: 139.737197),
            Location(name: "teamLab Borderless / チームラボボーダレス", distance: 0.5, address: "麻布台1丁目2-4 麻布台ヒルズ ガーデンプラザ...", latitude: 35.661730, longitude: 139.737220),
            Location(name: "テレビ東京", distance: 0.1, address: "港区六本木3-2-1", latitude: 35.663189, longitude: 139.737197),
            Location(name: "Minato", distance: 1.0, address: nil, latitude: 35.667793, longitude: 139.731992), // 港区の代表的な座標
            
            // 周辺の他のエリア
            Location(name: "長岡市", distance: 2.1, address: "Chiyoda", latitude: 35.689531, longitude: 139.691682), // 千代田区の座標を想定
            Location(name: "Tokyo, Japan", distance: 4.7, address: nil, latitude: 35.689487, longitude: 139.691704), // 東京駅周辺の座標を想定
            Location(name: "SHIBUYA SKY", distance: 3.3, address: "渋谷区渋谷2-24-12 渋谷スクランブルスクエア 14階...", latitude: 35.659556, longitude: 139.703247),
            Location(name: "TV Tokyo", distance: 0.1, address: "虎ノ門4-3-12", latitude: 35.663189, longitude: 139.737197) // 六本木周辺なので重複するが例示
        ]
        filteredLocations = allLocations // 初期表示は全ての場所
        tableView.reloadData()
    }

    // MARK: - UI Setup

    private func setupNavigationBar() {
        title = "Locations" // ナビゲーションバーのタイトル
        // 右側のキャンセルボタンを設定
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelButtonTapped))
        // 左側の戻るボタンはUINavigationControllerによって自動的に提供されることが多い
        // 必要に応じてカスタムの戻るボタンを設定することも可能
    }

    private func setupSearchBar() {
        searchController.searchResultsUpdater = self // 検索結果の更新をこのVCに委任
        searchController.obscuresBackgroundDuringPresentation = false // 検索中に背景を暗くしない
        searchController.searchBar.placeholder = "Search" // プレースホルダーテキスト
        navigationItem.searchController = searchController // ナビゲーションバーに検索コントローラを設定
        definesPresentationContext = true // 検索コントローラの表示範囲を設定
    }

    private func setupTableView() {
        view.addSubview(tableView) // テーブルビューをビューに追加
        tableView.translatesAutoresizingMaskIntoConstraints = false // Auto Layoutを使用
        // Auto Layoutの制約を設定（ビュー全体に広がるように）
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        tableView.dataSource = self // データソースをこのVCに設定
        tableView.delegate = self // デリゲートをこのVCに設定
        // セルを登録（標準のUITableViewCellを使用）
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "locationCell")
        // カスタムセルを使用する場合は、カスタムUITableViewCellクラスを作成し、そのクラスを登録する
    }

    private func setupLocationManager() {
        locationManager.delegate = self // 位置情報マネージャーのデリゲートをこのVCに設定
        locationManager.requestWhenInUseAuthorization() // アプリ使用中の位置情報利用許可を要求
        // 位置情報の更新を開始（許可が得られていれば）
        locationManager.startUpdatingLocation()
    }

    // MARK: - Actions

    @objc private func cancelButtonTapped() {
        // モーダルとして表示されているビューコントローラを閉じる
        // この操作により、LocationSearchRepresentableのCoordinatorのdismiss()が間接的にトリガーされる
        dismiss(animated: true, completion: nil)
    }

    // MARK: - UISearchResultsUpdating (検索結果の更新)

    func updateSearchResults(for searchController: UISearchController) {
        // 検索バーのテキストを取得
        guard let searchText = searchController.searchBar.text, !searchText.isEmpty else {
            // テキストが空の場合、全ての場所を表示
            filteredLocations = allLocations
            tableView.reloadData()
            return
        }

        // 検索テキストに基づいて場所をフィルタリング
        filteredLocations = allLocations.filter { location in
            return location.name.lowercased().contains(searchText.lowercased()) || // 名前でフィルタリング
                   (location.address?.lowercased().contains(searchText.lowercased()) ?? false) // 住所でフィルタリング
        }
        tableView.reloadData() // テーブルビューをリロードして検索結果を反映
    }

    // MARK: - UITableViewDataSource (テーブルビューのデータソース)

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredLocations.count // フィルタリングされた場所の数を行数とする
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "locationCell", for: indexPath)
        let location = filteredLocations[indexPath.row]

        // セルの内容を設定（iOS 14以降の新しいContent Configuration APIを使用）
        var content = cell.defaultContentConfiguration()
        content.text = location.name // メインのテキスト（場所の名前）
        
        var detailText = ""
        // ユーザーの現在地が利用可能であれば、実際の距離を計算して表示
        if let current = currentLocation, let lat = location.latitude, let lon = location.longitude {
            let targetLocation = CLLocation(latitude: lat, longitude: lon)
            let distanceInMeters = current.distance(from: targetLocation)
            let distanceInKm = distanceInMeters / 1000.0 // メートルをキロメートルに変換
            if distanceInKm < 1.0 {
                detailText += String(format: "<%.1fkm", distanceInKm) // 1km未満は "<0.1km" のように表示
            } else {
                detailText += String(format: "%.1fkm", distanceInKm) // 1km以上は "X.Xkm" のように表示
            }
        } else {
            // 現在地が取得できない場合、Location構造体のダミー距離を使用
            if location.distance < 1.0 {
                detailText += String(format: "<%.1fkm", location.distance)
            } else {
                detailText += String(format: "%.1fkm", location.distance)
            }
        }

        // 住所情報があれば追加
        if let address = location.address, !address.isEmpty {
            detailText += "・" + address
        }
        content.secondaryText = detailText // サブテキスト（距離と住所）
        cell.contentConfiguration = content // セルに設定を適用
        
        return cell
    }

    // MARK: - UITableViewDelegate (テーブルビューのデリゲート)

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true) // セルの選択状態を解除

        let selectedLocation = filteredLocations[indexPath.row]
        print("選択された場所: \(selectedLocation.name)")
        
        // 選択された場所をデリゲートを介してLocationSearchRepresentableに通知
        delegate?.didSelectLocation(selectedLocation)
        // このビューコントローラ自体は、デリゲートを介した通知を受けたLocationSearchRepresentableのCoordinatorによって閉じられるため、
        // ここで直接 dismiss(animated: true, completion: nil) は呼び出さない
    }

    // MARK: - CLLocationManagerDelegate (位置情報マネージャーのデリゲート)

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // 最新の位置情報を取得
        if let location = locations.last { // .last が最新のデータ
            currentLocation = location
            // 現在地が更新された際に、必要に応じてテーブルビューをリロードし、距離表示を更新する
            // しかし、頻繁な更新はバッテリー消費やUIパフォーマンスに影響するため、注意が必要
            // 例: tableView.reloadData() // これをコメントアウトして、パフォーマンスを優先することも多い
            print("現在地が更新されました: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("位置情報の取得に失敗しました: \(error.localizedDescription)")
        // エラーハンドリング（例: ユーザーにエラーメッセージを表示する）
    }
    
    // 位置情報利用許可のステータス変更時に呼ばれる
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation() // 許可が得られたら位置情報の更新を開始
        case .denied, .restricted:
            print("位置情報サービスの利用が拒否または制限されています。")
            // ユーザーに設定画面での許可を促すアラートなどを表示
        case .notDetermined:
            break // まだ許可を求められていない状態
        @unknown default:
            break
        }
    }
}
