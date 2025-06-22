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
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var dataStore: CatDataStore
    
    @Binding var cat: Cat
    @Binding var fish: Fish
    @Binding var isFishPlaced: Bool
    @Binding var showFeedButton: Bool
    @Binding var statusMessage: String
    @Binding var niboshiCount: Int
    @Binding var isCatPlaced: Bool
    @Binding var isTakingScreenshot: Bool // Add binding for screenshot
    @Binding var isInLocation: Bool // MainTabViewにifInLocationの結果を渡すための新しいバインディング

    func ifInLocation() -> Bool {
        return dataStore.ifInLocation(currentLocation: locationManager.currentLocation)
    }

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
        
        // ifInLocationの結果を更新し、MainTabViewに伝える
        DispatchQueue.main.async {
            self.isInLocation = self.ifInLocation()
        }

        if isTakingScreenshot {
            context.coordinator.takeScreenshot()
            DispatchQueue.main.async {
                isTakingScreenshot = false // Reset the flag
            }
        }
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

            // MARK: - ここから変更
            // ifInLocationがfalseの場合はぬいぐるみを配置しない
            if !parent.isInLocation {
                DispatchQueue.main.async {
                    self.parent.statusMessage = "猫がいないみたい"
                }
                return
            }
            // MARK: - ここまで変更

            // 魚がまだ配置されていない場合
            if !parent.isFishPlaced {
                placeFish(gesture: gesture)
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
                            let rotationToCorrectSide = simd_quatf(angle: .pi / 2, axis: [0, 0, 1])
                            let rotationToFaceWest = simd_quatf(angle: -.pi / 2, axis: [0, 1, 0])
                            fishEntity.orientation = rotationToFaceWest * rotationToCorrectSide

                            // 変更点: ワールド座標に固定するAnchorEntityを使用
                            let anchor = AnchorEntity(world: firstResult.worldTransform) // ここを変更
                            anchor.addChild(fishEntity)
                            arView.scene.addAnchor(anchor)

                            self.fishAnchor = anchor

                            DispatchQueue.main.async {
                                self.parent.isFishPlaced = true
                                self.parent.statusMessage = "ぬいぐるみを置いたよ！猫はやってくるかな？"
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

        private func placeCat(at fishTransform: simd_float4x4) {
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
                        catEntity.scale = [self.parent.cat.size, self.parent.cat.size, self.parent.cat.size]

                        // 猫のアンカーを魚と同じワールド変換で作成する
                        let anchor = AnchorEntity(world: fishTransform)
                        arView.scene.addAnchor(anchor) // 先にアンカーをシーンに追加
                        
                        let rotationToFaceSouth = simd_quatf(angle: .pi / 2, axis: [0, 1, 0])
                        catEntity.orientation = rotationToFaceSouth

                        // 猫のエンティティのローカル座標を調整して、魚の隣に配置する
                        // 猫を魚の少し右に配置
                        catEntity.transform.translation = [0.1, 0, 0]

                        anchor.addChild(catEntity) // アンカーに猫エンティティを追加。

                        // アニメーションの開始位置（魚からの相対位置）
                        let initialCatLocalPosition = SIMD3<Float>(0.5, 0, -1.0) // 例えば魚から右に0.5m、奥に1m
                        catEntity.transform.translation = initialCatLocalPosition // 初期位置を設定

                        // アニメーションの最終位置（魚からの相対位置）
                        let finalCatLocalPosition = SIMD3<Float>(0.1, 0, 0) // 魚の右に0.1m

                        let transformAnimation = FromToByAnimation(
                            from: Transform(scale: catEntity.scale, rotation: catEntity.orientation, translation: initialCatLocalPosition),
                            to: Transform(scale: catEntity.scale, rotation: catEntity.orientation, translation: finalCatLocalPosition),
                            duration: 1.5,
                            timing: .easeOut,
                            bindTarget: .transform
                        )

                        let animationResource = try! AnimationResource.generate(with: transformAnimation)
                        catEntity.playAnimation(animationResource, transitionDuration: 0.5, startsPaused: false)

                        DispatchQueue.main.async {
                            self.parent.statusMessage = "猫がやってきたよ！"
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
        
        func takeScreenshot() {
            guard let arView = arView else { return }
            arView.snapshot(saveToHDR: false) { image in
                if let image = image {
                    UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
                }
            }
        }
        
        @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
            if let error = error {
                parent.statusMessage = "写真の保存に失敗しました: \(error.localizedDescription)"
            } else {
                parent.statusMessage = "写真を保存しました！"
            }
        }
    }
}
