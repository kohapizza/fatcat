//
//  ARViewContainer.swift
//  fatcat
//
//  Created by 佐伯小遥 on 2025/06/21.
//

import SwiftUI
import ARKit
import RealityKit

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
        private func placeCat(gesture: UITapGestureRecognizer) {
            guard let arView = arView else { return }
            
            let location = gesture.location(in: arView)
            let results = arView.raycast(
                from: location,
                allowing: .estimatedPlane,
                alignment: .horizontal
            )
            
            if let firstResult = results.first {
                // 猫の3Dモデルを作成（シンプルなボックス）
                let catMesh = MeshResource.generateBox(size: 0.2)
                let catMaterial = SimpleMaterial(color: .orange, isMetallic: false)
                let catEntity = ModelEntity(mesh: catMesh, materials: [catMaterial])
                
                // 猫を世界に配置
                let anchor = AnchorEntity(world: firstResult.worldTransform)
                anchor.addChild(catEntity)
                arView.scene.addAnchor(anchor)
                
                // 保存
                self.catEntity = catEntity
                self.catAnchor = anchor
                
                // 状態更新
                DispatchQueue.main.async {
                    self.parent.isCatPlaced = true
                    self.parent.statusMessage = "猫が配置されました！タップして餌をあげよう"
                    self.parent.showFeedButton = true
                }
            }
        }
        
        // 猫のサイズを更新
        func updateCatSize(_ size: Float) {
            catEntity?.scale = [size, size, size]
        }
    }
}
