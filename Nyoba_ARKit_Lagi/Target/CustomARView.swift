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
    
    var moveToLocation: Transform = Transform()
    var modelEntity: ModelEntity?
    
    required init(frame frameRect: CGRect) {
        super.init(frame: frameRect)
    }
    
    @MainActor required dynamic init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(){
        self.init(frame: UIScreen().bounds)
        
        planeDetection()
//        coaching tu yg ada tulisan "Move iPhone to Start"
        addCoaching()
        loadModel(model: "Tiger")
        placeBlock()
//        createBackground()
//        subscribeToActionStream()
        
//        butuh ini keknya gegara kita tu make ARView nya bukan di aplikasi AR, tp di aplikasi swiftui biasa
//        self.installGestures([.all], for: modelEntity! as HasCollision)
        
        /*
         buat installGesture ini ada:
         1. All: termasuk semua
         2. rotation: buat rotate model
         3. scale: buat gede kecilin modelnya
         4. translation: buat gerakin modelnya
         
         disini gw coba matiin tp ternyata macannya bisa kepencet. Emg buat control modelnya aja ini
         */
        
//        ini intinya buat kasih tau kalo user ada tap di layar
        /*
         Param:
         1. target: target object yg datanya mau dikirim
         2. action: jalanin function apa setelah ada gesture (disini tap gesture). functionnya harus ada @objc
         */
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
        self.addGestureRecognizer(tap)
        

    }
    
    func planeDetection(){
//        yang ada disini gw kurang tau juga, baca2 aja wkwkw. gw asal nambah soalnya
        self.automaticallyConfigureSession = true
        
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal,.vertical]
        config.environmentTexturing = .automatic
        
//        yg debugOptions ini buat keluarin ijo2 di plane yg ke detect
        self.debugOptions = .showAnchorGeometry
        self.session.run(config)
    }
    
//    ini load model
    func loadModel(model: String){
        modelEntity = try! Entity.loadModel(named: model + ".usdz")
        modelEntity?.setScale(SIMD3(x: 0.1, y: 0.1, z: 0.1), relativeTo: modelEntity)
        modelEntity?.name = "Macan"
        
//        nyalain collision buat modelnya
        modelEntity?.generateCollisionShapes(recursive: true)
    }
    
//    cancellable is needed whenever your app is using Combine
    private var cancellables: Set<AnyCancellable> = []
    
//    func subscribeToActionStream(){
//        ARManager.shared.actionStream
//            .sink { [weak self] action in
//                switch action {
//                case .placeBlock(let model):
//                    self?.placeBlock(ofModel: model)
//                    self?.playAnimation()
//                    
//                case .removeAllAnchors:
//                    self?.scene.anchors.removeAll()
//                    
//                case .addBackgroundImage:
//                    self?.createBackground()
//                }
//                
//            }
//            .store(in: &cancellables) // this will make sure that the subscription is kept alive even when the function is done
//    }
    
//    handle tap function
//    @objc itu kasih tau kalo nih function tu punya objective c
    @objc
    func handleTap(recognizer: UITapGestureRecognizer? = nil){
//        2D tap location
        guard let tapLocation = recognizer?.location(in: self) else { return }
        
//        dia kek nyalain hit test gitu
        let result: [CollisionCastHit] = self.hitTest(tapLocation)

//        buat dapetin resultnya
        guard let hitTest: CollisionCastHit = result.first
        else { return }

//        ini entity yang kepencet
        let entity: Entity = hitTest.entity
        
        print(entity.name)
        
//        raycast = 2d to 3d
//        let results = self.raycast(from: tapLocation, allowing: .estimatedPlane, alignment: .horizontal)
        
//        if let firstResult = results.first {
//            3d position
//            let worldPos = simd_make_float3(firstResult.worldTransform.columns.3)
//            place object
//            placeBlock(position: worldPos)
            
            //        Move the model
//            moveEntity(direction: "forward")
//        }
    }

    func addCoaching(){
        let coachingOverlay = ARCoachingOverlayView()

        // Goal is a field that indicates your app's tracking requirements.
        coachingOverlay.goal = .tracking
             
        // The session this view uses to provide coaching.
        coachingOverlay.session = self.session
             
        // How a view should resize itself when its superview's bounds change.
        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        coachingOverlay.activatesAutomatically = true

        self.addSubview(coachingOverlay)
        
    }
    
//    ini buat bikin background png doang
    func createBackground(){
        let screen = MeshResource.generatePlane(width: 1, depth: 1)
        var material = UnlitMaterial()
        
        if let baseResource = try? TextureResource.load(named: "Mountain_BG"){
            let baseColor = MaterialParameters.Texture(baseResource)
            
//            ini yang bikin background di gambar ilang
            material.color = .init(tint: UIColor(white: 1, alpha: 0.99), texture: baseColor)
        }
        
        let imageModelEntity = ModelEntity(mesh: screen, materials: [material])
        let anchor = AnchorEntity(plane: .vertical)
        
        anchor.addChild(imageModelEntity)
        
        scene.addAnchor(anchor)
    }
    
    func placeBlock(){
        // create an anchor entity and add the model to it
        let anchorEntity = AnchorEntity(plane: .horizontal)
        anchorEntity.addChild(modelEntity!)
        
        playAnimation()
        
        scene.addAnchor(anchorEntity)
    }
    
    func playAnimation(){
        if let entityAnimation = modelEntity?.availableAnimations.first{
//            play animation
            modelEntity?.playAnimation(entityAnimation.repeat(), transitionDuration: 5, startsPaused: false)
        }
    }
    
    func moveEntity(direction: String){
        switch direction{
        case "forward":
//            ini maju kedepan. translation itu buat kasih tau kalo maju kedepan nambahin vector z nya 20
            moveToLocation.translation = (modelEntity?.transform.translation)! + simd_float3(x: 0, y: 0, z: 100)
            modelEntity?.move(to: moveToLocation, relativeTo: modelEntity, duration: 5)
            print("gerak depan")
            
//            nambahin animasi jalan kalo bisa wkwk
        
        case "back":
            moveToLocation.translation = (modelEntity?.transform.translation)! + simd_float3(x: 0, y: 0, z: -20)
            modelEntity?.move(to: moveToLocation, relativeTo: modelEntity, duration: 5)
            
        case "left":
            let rotateAngle = simd_quatf(angle: GLKMathDegreesToRadians(90), axis: SIMD3(x: 0, y: 1, z: 0))
            modelEntity?.setOrientation(rotateAngle, relativeTo: modelEntity)
            
        case "right":
            let rotateAngle = simd_quatf(angle: GLKMathDegreesToRadians(90), axis: SIMD3(x: 0, y: 1, z: 0))
            modelEntity?.setOrientation(rotateAngle, relativeTo: modelEntity)
        default:
            print("Ga gerak mas")
        }
    }
    
    
//  ---------------- EXAMPLE ONLY ----------------
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
//  ---------------- EXAMPLE ONLY ----------------
    
    
}
