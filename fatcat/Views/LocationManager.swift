//
//  LocationManager.swift
//  fatcat
//
//  Created by 佐伯小遥 on 2025/06/22.
//


import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {

    private let locationManager = CLLocationManager()

    @Published var currentLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10.0
    }

    func requestLocationAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }

    func startUpdatingLocation() {
        if authorizationStatus == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
            print("位置情報の更新を開始しました。")

        } else {
            print("位置情報サービスの利用が許可されていません。ステータス: \(authorizationStatus.rawValue)")
        }
    }

    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
        print("位置情報の更新を停止しました。")
    }

    // MARK: - CLLocationManagerDelegate

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        print("location manager did change authorization called", authorizationStatus.rawValue)
        // 許可が得られたら自動的に更新を開始することもできます
         if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
             startUpdatingLocation()
         }
    }

    // ここで現在地をプリントします
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
        if let location = currentLocation {
            // 緯度と経度をコンソールにプリント
            print("現在の位置 (LocationManager): 緯度 \(location.coordinate.latitude), 経度 \(location.coordinate.longitude)")
            // 必要に応じて他の情報もプリント
            print("  精度: \(location.horizontalAccuracy)m, 高度: \(location.altitude)m")
            print("  タイムスタンプ: \(location.timestamp)")
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("位置情報の取得に失敗しました: \(error.localizedDescription)")
    }
}
