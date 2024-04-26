//
//  CustomARView.swift
//  Nyoba_ARKit
//
//  Created by Renaldi Antonio on 22/04/24.
//

import Combine
import SwiftUI
import RealityKit
import ARKit

class CustomARView: ARView {
    required init(frame frameRect: CGRect) {
        super.init(frame: frameRect)
    }
    
    @MainActor required dynamic init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(){
        self.init(frame: UIScreen().bounds)
        
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal,.vertical]
        config.environmentTexturing = .automatic
        self.session.run(config)
        
        addCoaching()
//        createBackground()
        subscribeToActionStream()
    }
    
//    cancellable is needed whenever your app is using Combine
    private var cancellables: Set<AnyCancellable> = []
    
    func subscribeToActionStream(){
        ARManager.shared.actionStream
            .sink { [weak self] action in
                switch action {
                case .placeBlock(let model):
                    self?.placeBlock(ofModel: model)
                    
                case .removeAllAnchors:
                    self?.scene.anchors.removeAll()
                    
                case .addBackgroundImage:
                    self?.createBackground()
                }
                
            }
            .store(in: &cancellables) // this will make sure that the subscription is kept alive even when the function is done
    }
    
    func configurationExample(){
//        Tracks the device relative to it's environment
        let configuration = ARWorldTrackingConfiguration()
        session.run(configuration)
        // Not supported in all regions, tracks w.r.t. global coordinates
        let _ = ARGeoTrackingConfiguration()
        
        // Tracks faces in the scene
        let _ = ARFaceTrackingConfiguration()
        
        // Tracks bodies in the scene
        let _ = ARBodyTrackingConfiguration()
    }
    
    func anchorExample(){
        // Attach anchors at specific coordinates in the iPhone-centered coordinate system
        let coordinateAnchor = AnchorEntity(world: .zero)
        
        // Attach anchors to detected planes (this works best on devices with a LIDAR sensor)
        let _ = AnchorEntity(plane: .horizontal)
        let _ = AnchorEntity(plane: .vertical)
        
        // Attach anchors to tracked body parts, such as the face
        let _ = AnchorEntity(.face)
        
        // Attach anchors to tracked images, such as markers or visual codes
        let _ = AnchorEntity(.image (group: "group", name: "name"))
        
        // Add an anchor to the scene
        scene.addAnchor (coordinateAnchor)
    }
    
    func entityExample(){
        // Load an entity from a usdz file
        let _ = try? Entity.load(named: "usdzFileName")
        
        // Load an entity from a reality file
        let _ = try? Entity.load(named: "realityFileName")
        
        // Generate an entity with code
        let box = MeshResource.generateBox (size: 1)
        let entity = ModelEntity (mesh: box)
        
        // Add entity to an anchor SO it's placed in the scene
        let anchor = AnchorEntity()
        anchor.addChild(entity)
    }
    
    func addCoaching(){
        let coachingOverlay = ARCoachingOverlayView()

        // Goal is a field that indicates your app's tracking requirements.
        coachingOverlay.goal = .tracking
             
        // The session this view uses to provide coaching.
        coachingOverlay.session = self.session
             
        // How a view should resize itself when its superview's bounds change.
        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        self.addSubview(coachingOverlay)
        
    }
    
    func createBackground(){
        let screen = MeshResource.generatePlane(width: 1, depth: 1)
        var material = UnlitMaterial()
        
        if let baseResource = try? TextureResource.load(named: "Mountain_BG"){
            let baseColor = MaterialParameters.Texture(baseResource)
            material.color = .init(tint: UIColor(white: 1, alpha: 0.99), texture: baseColor)
        }
        
        let imageModelEntity = ModelEntity(mesh: screen, materials: [material])
        let anchor = AnchorEntity(plane: .vertical)
        
//        imageModelEntity.setPosition(SIMD3(x: 0, y: 0, z: 1.5), relativeTo: anchor)
//        imageModelEntity.transform.rotation = simd_quatf(angle: -90, axis: [1, 0, 0])
        
        anchor.addChild(imageModelEntity)
        
        scene.addAnchor(anchor)
    }
    
    func placeBlock(ofModel model: String){
//        let block = MeshResource.generateBox(size: 1)
//        let material = SimpleMaterial(color: UIColor(color), isMetallic: false)
//        let entity = ModelEntity(mesh: block, materials: [material])
//        
//        let anchor = AnchorEntity(plane: .horizontal)
//        anchor.addChild(entity)
//        
//        scene.addAnchor(anchor)
        
        // load the model from the app's asset catalog
        let modelEntity = try! ModelEntity.load(named: model + ".usdz")
        if(model == "Tiger"){
            modelEntity.setScale(SIMD3(x: 0.1, y: 0.1, z: 0.1), relativeTo: modelEntity)
        }
        
        // create an anchor entity and add the model to it
        let anchorEntity = AnchorEntity(plane: .horizontal)
        anchorEntity.addChild(modelEntity)
        
        scene.addAnchor(anchorEntity)
    }
    
}
