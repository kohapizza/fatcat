//
//  ARViewContainer.swift
//  fatcat
//
//  Created by 佐伯小遥 on 2025/06/21.
//

import SwiftUI
import ARKit
import RealityKit
import Combine

struct ARViewContainer: UIViewRepresentable {
    @Binding var cat: Cat
    @Binding var isCatPlaced: Bool
    @Binding var showFeedButton: Bool
    @Binding var statusMessage: String
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        
        // AR設定
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        arView.session.run(config)
        
        // タップで猫を配置
        let tapGesture = UITapGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleTap)
        )
        arView.addGestureRecognizer(tapGesture)
        
        context.coordinator.arView = arView
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        // 猫のサイズが変わったら更新
        context.coordinator.updateCatSize(cat.size)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}

// ARの処理を担当するクラス
extension ARViewContainer {
    class Coordinator: NSObject {
        let parent: ARViewContainer
        var arView: ARView?
        var catEntity: ModelEntity?
        var catAnchor: AnchorEntity?
        var cancellables = Set<AnyCancellable>()
        
        init(_ parent: ARViewContainer) {
            self.parent = parent
        }
        
        // 画面タップ時の処理
        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let arView = arView else { return }
            
            // 猫がまだ配置されていない場合
            if !parent.isCatPlaced {
                placeCat(gesture: gesture)
            } else {
                // 猫が配置済みの場合、餌やりボタンを表示
                parent.showFeedButton = true
                parent.statusMessage = "餌やりボタンが表示されました！"
            }
        }
        
        // 猫を配置する処理
//        private func placeCat(gesture: UITapGestureRecognizer) {
//            guard let arView = arView else { return }
//            
//            let location = gesture.location(in: arView)
//            let results = arView.raycast(
//                from: location,
//                allowing: .estimatedPlane,
//                alignment: .horizontal
//            )
//            
//            if let firstResult = results.first {
//                // 猫の3Dモデルを作成（シンプルなボックス）
//                let catMesh = MeshResource.generateBox(size: 0.2)
//                let catMaterial = SimpleMaterial(color: .orange, isMetallic: false)
//                let catEntity = ModelEntity(mesh: catMesh, materials: [catMaterial])
//                
//                
//                
//                // 猫を世界に配置
//                let anchor = AnchorEntity(world: firstResult.worldTransform)
//                anchor.addChild(catEntity)
//                arView.scene.addAnchor(anchor)
//                
//                // 保存
//                self.catEntity = catEntity
//                self.catAnchor = anchor
//                
//                // 状態更新
//                DispatchQueue.main.async {
//                    self.parent.isCatPlaced = true
//                    self.parent.statusMessage = "猫が配置されました！タップして餌をあげよう"
//                    self.parent.showFeedButton = true
//                }
//            }
//        }
        
        private func placeCat(gesture: UITapGestureRecognizer) {
            guard let arView = arView else { return }

            let location = gesture.location(in: arView)
            let results = arView.raycast(
                from: location,
                allowing: .estimatedPlane,
                alignment: .horizontal
            )

            if let firstResult = results.first {
                // MARK: - ここから変更
                // モデルを非同期でロードする
                var catEntity: ModelEntity? // ModelEntityをオプショナルで宣言

                let modelFileName = "fish.usdz" // ここにあなたのUSDZファイル名を入れる

                // モデルのロードを試みる
                ModelEntity.loadModelAsync(named: modelFileName)
                    .collect()
                    .sink { completion in
                        if case let .failure(error) = completion {
                            print("Error loading model: \(error)")
                            // エラー処理（例: ユーザーにエラーメッセージを表示）
                            DispatchQueue.main.async {
                                self.parent.statusMessage = "モデルのロードに失敗しました。"
                            }
                        }
                    } receiveValue: { entities in
                        if let loadedEntity = entities.first {
                            catEntity = loadedEntity
                            // モデルのロードが成功したら、アンカーに追加してシーンに配置
                            let anchor = AnchorEntity(world: firstResult.worldTransform)
                            anchor.addChild(catEntity!) // ここでロードしたモデルを追加
                            arView.scene.addAnchor(anchor)

                            // モデルのサイズ調整（必要に応じて）


                            self.catEntity = catEntity
                            self.catAnchor = anchor

                            DispatchQueue.main.async {
                                self.parent.isCatPlaced = true
                                self.parent.statusMessage = "新しいモデルが配置されました！タップして餌をあげよう"
                                self.parent.showFeedButton = true
                            }
                        } else {
                            print("No entity found in the loaded USDZ.")
                            DispatchQueue.main.async {
                                self.parent.statusMessage = "モデルファイルが空です。"
                            }
                        }
                    }
                    .store(in: &cancellables) // cancellablesはCombineのSubscriptionを保持するSet<AnyCancellable>

                // MARK: - ここまで変更
            }
        }

        // クラスのプロパティとして追加
        // var cancellables = Set<AnyCancellable>()
        // ARViewを保持しているクラスに`import Combine`と`var cancellables = Set<AnyCancellable>()`を追加してください。
        
        // 猫のサイズを更新
        func updateCatSize(_ size: Float) {
            catEntity?.scale = [size, size, size]
        }
    }
}
