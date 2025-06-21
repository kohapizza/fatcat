//
//  LocationSearchRepresentable.swift
//  fatcat
//
//  Created by 佐伯小遥 on 2025/06/21.
//

import SwiftUI
import UIKit // UIViewControllerRepresentableのために必要
import CoreLocation // LocationSearchViewController内で使っているため（直接は使わないが、依存関係を示すため）
import MapKit     // LocationSearchViewController内で使っているため

// LocationSearchViewControllerから選択された場所を受け取るためのデリゲートプロトコル
// LocationSearchViewControllerのファイルにも同じ定義が必要
protocol LocationSelectionDelegate: AnyObject {
    func didSelectLocation(_ location: Location) // 選択された位置情報を渡すメソッド
}

struct LocationSearchRepresentable: UIViewControllerRepresentable {
    // モーダルを閉じるための環境変数
    @Environment(\.presentationMode) var presentationMode

    // 選択された位置情報を親ビューに渡すためのBinding
    @Binding var selectedLocation: Location?

    // UIViewControllerのインスタンスを作成
    func makeUIViewController(context: Context) -> UINavigationController {
        let locationSearchVC = LocationSearchViewController()
        locationSearchVC.delegate = context.coordinator // Coordinatorをデリゲートに設定
        let navController = UINavigationController(rootViewController: locationSearchVC) // ナビゲーションバーのためにUINavigationControllerでラップ
        return navController
    }

    // UIViewControllerの状態を更新（今回は特に変更なし）
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        // 必要であれば、ここでUIViewControllerの更新を行う
    }

    // UIKitのデリゲートメソッドをSwiftUIに橋渡しするCoordinatorのインスタンスを作成
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    // Coordinatorクラスは、UIKitからのイベントを受け取り、SwiftUIの状態を更新する役割を担う
    class Coordinator: NSObject, LocationSelectionDelegate {
        var parent: LocationSearchRepresentable

        init(_ parent: LocationSearchRepresentable) {
            self.parent = parent
        }

        // LocationSearchViewControllerから場所が選択されたときに呼ばれるデリゲートメソッド
        func didSelectLocation(_ location: Location) {
            parent.selectedLocation = location // 親ビューのBindingに選択された場所を設定
            parent.presentationMode.wrappedValue.dismiss() // モーダルを閉じる
        }
    }
}
