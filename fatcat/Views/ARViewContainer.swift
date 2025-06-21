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
            } else {
                // 魚が配置済みの場合、餌やりボタンを表示
                parent.showFeedButton = true
                parent.statusMessage = "魚のぬいぐるみを置きました！"
            }
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

                            let anchor = AnchorEntity(world: firstResult.worldTransform)
                            anchor.addChild(fishEntity)
                            arView.scene.addAnchor(anchor)

                            self.fishAnchor = anchor

                            DispatchQueue.main.async {
                                self.parent.isFishPlaced = true
                                self.parent.statusMessage = "魚のぬいぐるみが配置されました！猫がやってくるかな？"
                                self.parent.showFeedButton = true
                            }
                            
                            // 魚が配置されてから5秒後に猫を配置
                            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                                self.placeCat(at: Transform(matrix: firstResult.worldTransform))
                            }
                        }
                    })
                    .store(in: &cancellables)
            }
        }

        // 猫を配置する処理
        private func placeCat(at transform: Transform) {
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

                        let anchor = AnchorEntity(world: transform.matrix)
                        anchor.addChild(catEntity)
                        arView.scene.addAnchor(anchor)

                        DispatchQueue.main.async {
                            self.parent.statusMessage = "猫がやってきました！"
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
