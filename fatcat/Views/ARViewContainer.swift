//
//  ARViewContainer.swift
//  fatcat
//
//  Created by 佐伯小遥 on 2025/06/21.
//

import SwiftUI
import ARKit
import RealityKit
import Combine // Combineフレームワークをインポート

struct ARViewContainer: UIViewRepresentable {
    @Binding var cat: Cat
    @Binding var fish: Fish
    @Binding var isFishPlaced: Bool
    @Binding var showFeedButton: Bool
    @Binding var statusMessage: String
    @Binding var niboshiCount: Int
    @Binding var isCatPlaced: Bool // ★追加: 猫が配置されているかどうかのフラグ

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
        var fishEntity: ModelEntity?
        var fishAnchor: AnchorEntity?
        var catEntity: ModelEntity?
        var cancellables = Set<AnyCancellable>()

        init(_ parent: ARViewContainer) {
            self.parent = parent
        }

        // 画面タップ時の処理
        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let arView = arView else { return }

            // 魚がまだ配置されていない場合
            if !parent.isFishPlaced {
                placeFish(gesture: gesture)
            }
            //else {
//                parent.statusMessage = "魚のぬいぐるみを置きました！猫が来るのを待っています。"
//            }
        }

        // 魚を配置する処理
        private func placeFish(gesture: UITapGestureRecognizer) {
            guard let arView = arView else { return }

            let location = gesture.location(in: arView)
            let results = arView.raycast(
                from: location,
                allowing: .estimatedPlane,
                alignment: .horizontal
            )

            if let firstResult = results.first {
                Entity.loadModelAsync(named: "fish.usdz")
                    .sink(receiveCompletion: { completion in
                        if case let .failure(error) = completion {
                            print("Error loading fish model: \(error.localizedDescription)")
                            self.parent.statusMessage = "魚のぬいぐるみのモデルをロードできませんでした。"
                        }
                    }, receiveValue: { modelEntity in
                        self.fishEntity = modelEntity as? ModelEntity
                        if let fishEntity = self.fishEntity {
                            fishEntity.scale = [self.parent.fish.size, self.parent.fish.size, self.parent.fish.size]
                            fishEntity.orientation = simd_quatf(angle: .pi / 2, axis: [0, 0, 1])

                            let anchor = AnchorEntity(world: firstResult.worldTransform)
                            anchor.addChild(fishEntity)
                            arView.scene.addAnchor(anchor)

                            self.fishAnchor = anchor

                            DispatchQueue.main.async {
                                self.parent.isFishPlaced = true
                                self.parent.statusMessage = "魚のぬいぐるみが配置されました！猫がやってくるかな？"
                            }
                            
                            // 魚が配置されてから5秒後に猫を配置
                            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                                self.placeCat(at: firstResult.worldTransform)
                            }
                        }
                    })
                    .store(in: &cancellables)
            }
        }

        // 猫を配置する処理
                private func placeCat(at fishTransform: simd_float4x4) { // 引数を Transform から simd_float4x4 に変更
                    guard let arView = arView else { return }

                    Entity.loadModelAsync(named: "cat.usdz")
                        .sink(receiveCompletion: { completion in
                            if case let .failure(error) = completion {
                                print("Error loading cat model: \(error.localizedDescription)")
                                self.parent.statusMessage = "猫のモデルをロードできませんでした。"
                            }
                        }, receiveValue: { modelEntity in
                            self.catEntity = modelEntity as? ModelEntity
                            if let catEntity = self.catEntity {
                                // 猫の初期サイズを設定
                                catEntity.scale = [self.parent.cat.size, self.parent.cat.size, self.parent.cat.size]

                                // 魚のTransformを取得し、猫を隣に配置するためのオフセットを適用
                                var catTransform = fishTransform
                                // X軸方向に正の値を加算すると「右」に移動
                                // Z軸方向に正の値を加算すると「手前」に移動
                                catTransform.columns.3.x += 0.3 // 右に0.3メートル (30cm) ずらす
                                catTransform.columns.3.z += 0.2 // 手前に0.2メートル (20cm) ずらす

                                let anchor = AnchorEntity(world: catTransform)
                                anchor.addChild(catEntity)
                                arView.scene.addAnchor(anchor)

                                DispatchQueue.main.async {
                                    self.parent.statusMessage = "猫がやってきました！"
                                    self.parent.isCatPlaced = true
                                    self.parent.showFeedButton = true
                                }
                            }
                        })
                        .store(in: &cancellables)
                }

        // 猫のサイズを更新
        func updateCatSize(_ size: Float) {
            catEntity?.scale = [size, size, size]
        }
    }
}
