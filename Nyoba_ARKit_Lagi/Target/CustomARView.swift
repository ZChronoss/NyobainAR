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
import CoreMotion

class CustomARView: ARView {
    
    var moveToLocation: Transform = Transform()
    var tigerEntity: ModelEntity?
    var tigerAudio: AudioResource?
    
    var treeModel: ModelEntity?
    
    var tap = UITapGestureRecognizer()
    
    private let pedometer: CMPedometer = CMPedometer()
    private let activityManager: CMMotionActivityManager = CMMotionActivityManager()
    private var steps: Int = 0
    
    private let numOfFootstep = 6
    private var footstepsAudio: [AudioResource?] = []
    private var combinedFootstepAudio: AudioResource?
    
    let stepEntity = Entity()
    let stepAnchor = AnchorEntity()
    
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
//        loadAudio()
        placeTiger()
        modelAction()
        
//        buat pohon
        for _ in 1...10{
            placeTree(tree: "Maple_Tree")
            placeTree(tree: "Pohon_Jauh")
            placeTree(tree: "Semak")
        }
        
//        buat ground
//        loadGround(ground: "Ground")
        
//        ambient sound
        loadAmbient()
        
//        buat pedometer
        startUpdating()
        
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
        tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
        self.addGestureRecognizer(tap)
        

    }
    
    private func startUpdating() {
//        if CMMotionActivityManager.isActivityAvailable() {
//            startTrackingActivityType()
//        }
        
        if CMPedometer.isStepCountingAvailable() {
            startCountingSteps()
        }
    }
    
    private func startTrackingActivityType() {
        stepAnchor.addChild(stepEntity)
        self.scene.addAnchor(stepAnchor)

//        let randFootstep = Int.random(in: 0...(self.numOfFootstep - 1))
//        let controller = stepEntity.prepareAudio(self.footstepsAudio[randFootstep]!)
        let controller = stepEntity.prepareAudio(combinedFootstepAudio!)
        
        activityManager.startActivityUpdates(to: OperationQueue.main) { (activity: CMMotionActivity?) in

            guard let activity = activity else { return }
            DispatchQueue.main.async {
                if activity.stationary {
                    controller.stop()
                }else if activity.walking{
                    controller.play()
                }
            }
        }
    }
    
    private func startCountingSteps() {
        stepAnchor.addChild(stepEntity)
        self.scene.addAnchor(stepAnchor)
        
        pedometer.startUpdates(from: Date()) { (data: CMPedometerData?, error) -> Void in
            
            DispatchQueue.main.async(execute: { () -> Void in
                let randFootstep = Int.random(in: 0...(self.numOfFootstep - 1))
                let controller = self.stepEntity.prepareAudio(self.footstepsAudio[randFootstep]!)
                
//                let controller = self.stepEntity.prepareAudio(self.combinedFootstepAudio!)
                if(error == nil){
                    let tempStep = self.steps
                    self.steps = (data?.numberOfSteps.intValue)!
                    
                    if(tempStep == self.steps){
                        print("gak jalan")
                        controller.stop()
                    }else{
                        controller.play()
                    }
                    
//                    controller.play()
                    controller.completionHandler = {
                        let randFootstep = Int.random(in: 0...(self.numOfFootstep - 1))
                        let secController = self.stepEntity.prepareAudio(self.footstepsAudio[randFootstep]!)
                        
                        secController.play()
                        secController.completionHandler = {
                            let randFootstep = Int.random(in: 0...(self.numOfFootstep - 1))
                            let thirdController = self.stepEntity.prepareAudio(self.footstepsAudio[randFootstep]!)
                            
                            thirdController.play()
                            thirdController.completionHandler = {
                                let randFootstep = Int.random(in: 0...(self.numOfFootstep - 1))
                                _ = self.stepEntity.playAudio(self.footstepsAudio[randFootstep]!)
                            }
                        }
                    }
                    print(self.steps)
                }
            })
        }
    }
    
    func planeDetection(){
//        yang ada disini gw kurang tau juga, baca2 aja wkwkw. gw asal nambah soalnya
        self.automaticallyConfigureSession = true
        
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal,.vertical]
        config.environmentTexturing = .automatic
//        config.worldAlignment = .gravityAndHeading
        config.isAutoFocusEnabled = true
        
//        yg debugOptions ini buat keluarin ijo2 di plane yg ke detect
//        self.debugOptions = .showAnchorGeometry
        self.session.run(config)
    }
    
    func loadAudio(){
        tigerAudio = try? AudioFileResource.load(named: "tiger_roar.mp3", inputMode: .spatial, loadingStrategy: .preload,  shouldLoop: false)
        
//        ada 6 footsteps sound
        for i in 1...numOfFootstep {
            let footstep = try? AudioFileResource.load(named: "steps_dirt_\(i).mp3", inputMode: .nonSpatial, loadingStrategy: .preload,  shouldLoop: false)
            footstepsAudio.append(footstep)
        }
        
        combinedFootstepAudio = try? AudioFileResource.load(named: "footstep_combined.mp3", inputMode: .nonSpatial, loadingStrategy: .preload,  shouldLoop: true)

    }
    
    func loadAmbient(){
        let ambientEntity = Entity()
        let ambientAnchor = AnchorEntity()
        
        let ambient = try? AudioFileResource.load(named: "Forest_Ambient.wav", inputMode: .ambient, loadingStrategy: .preload,  shouldLoop: true)
        
        ambientAnchor.addChild(ambientEntity)
        
        self.scene.addAnchor(ambientAnchor)
        ambientEntity.playAudio(ambient!)
    }
    
//    func loadFog(){
//        let anchor = AnchorEntity()
//        let fogEntity = Entity()
//        
//        let fogNode = SCNNode()
//        
//        guard let fog = SCNParticleSystem(named: "Fog.sks", inDirectory: nil) else {return}
//        fogNode.addParticleSystem(fog)
//        
//        anchor.addChild(fogNode)
//
//        self.scene.
//    }
    
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
        
        if(entity.name == "Macan") {
//            tigerEntity?.playAudio(tigerAudio!)
        }
        
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
    
    func placeTiger(){
        let anchorEntity = AnchorEntity(plane: .horizontal)
        
        tigerEntity = try? Entity.loadModel(named: "Tiger.usdz")
        
        
        tigerEntity?.setScale(SIMD3(x: 0.3, y: 0.3, z: 0.3), relativeTo: tigerEntity)
        tigerEntity?.name = "Macan"
        
//        nyalain collision buat modelnya
        tigerEntity?.generateCollisionShapes(recursive: true)
        anchorEntity.addChild(tigerEntity!)
        
        var x = Float.random(in: -5 ... 5)
        var z = Float.random(in: -5 ... 5)
        
//        print("\(x)\n\(z)\n")
        
        x = randPosValidator(r1: 1.5, r2: 0, axis: x)
        z = randPosValidator(r1: 1.5, r2: 0, axis: z)
        
        anchorEntity.setPosition(SIMD3<Float>(x: x, y: 0, z: z), relativeTo: anchorEntity)
        
//        print("\(x)\n\(z)")
        
        playAnimation()
        loadAudio()

//        tigerEntity?.playAudio(tigerAudio!)
        
        scene.addAnchor(anchorEntity)
    }
    
    func playAnimation(){
        if let entityAnimation = tigerEntity?.availableAnimations.first{
//            play animation
            tigerEntity?.playAnimation(entityAnimation.repeat(), transitionDuration: 5, startsPaused: false)
        }
    }
    
    func modelAction(){
        let randNum = Int.random(in: 1 ... 4)
        var movement = moveEntity(direction: "forward")
//        tigerEntity?.playAudio(tigerAudio!)
        
        self.scene.publisher(for: AnimationEvents.PlaybackCompleted.self)
            .filter{ $0.playbackController == movement }
            .sink(receiveValue: { event in
//                movement = self.moveEntity(direction: "back")
                switch randNum {
                    case 1:
                        movement = self.moveEntity(direction: "forward")
                    case 2:
                        movement = self.moveEntity(direction: "back")
                    case 3:
                        movement = self.moveEntity(direction: "left")
                    case 4:
                        movement = self.moveEntity(direction: "right")
                    default:
                        print("error")
                }
                self.cancellables.removeAll()
                self.modelAction()
            }).store(in: &cancellables)
    }
    
    func randPosValidator(r1: Float, r2: Float, axis: Float) -> Float{
        var retVal: Float = axis
        
//      ini kalo angka random jatoh di antara -1 s.d. 0 bakal di kurangin -1 biar ga terlalu deket sama user
        if (-r1 ... r2).contains(axis){
            retVal = axis - r1
        }
        //      ini kalo 0 s.d. 1 bakal ditambah 1.
        else if (r2 ... r1).contains(axis) {
            retVal = axis + r1
        }
        
        return retVal
    }
    
    func randomTreePosition(tree: String) -> SIMD3<Float>{
        var x: Float = 0
        var z: Float = 0
        switch tree{
        case "Maple_Tree":
            x = Float.random(in: -5 ... 5)
            z = Float.random(in: -5 ... 5)
            
            x = randPosValidator(r1: 1, r2: 0, axis: x)
            z = randPosValidator(r1: 1, r2: 0, axis: z)

        case "Pohon_Jauh":
            x = Float.random(in: -10 ... 10)
            z = Float.random(in: -10 ... 10)
            
//            ini buat pohon jauh gw jauhin jadi 10 meteran dari user dan ga bakal spawn di jarak 5 meter dari user
            x = randPosValidator(r1: 5, r2: 0, axis: x)
            z = randPosValidator(r1: 5, r2: 0, axis: z)
            
        case "Semak":
            x = Float.random(in: -10 ... 10)
            z = Float.random(in: -10 ... 10)
            
            x = randPosValidator(r1: 1, r2: 0, axis: x)
            z = randPosValidator(r1: 1, r2: 0, axis: z)
            
        default:
            print("No Tree model with that name")
        }
        let randPos = SIMD3<Float>(x: x, y: 0, z: z)
        
//        print(randPos)
        return randPos
    }
    
    func placeTree(tree: String){
//        treeModel = try! Entity.loadModel(named: tree + ".usdz")
        let anchorEntity = AnchorEntity(plane: .horizontal)
        
        var cancellable: AnyCancellable? = nil
        cancellable = Entity.loadModelAsync(named: tree + ".usdz")
            .sink(receiveCompletion: { error in
                print(error)
                cancellable?.cancel()
            }, receiveValue: { entity in
                anchorEntity.addChild(entity.clone(recursive: true))
                cancellable?.cancel()
            })
        
        anchorEntity.setPosition(randomTreePosition(tree: tree), relativeTo: anchorEntity)
        
        scene.addAnchor(anchorEntity)
    }
    
    func loadGround(ground: String){
        let anchorEntity = AnchorEntity(plane: .horizontal)
        
        var cancellable: AnyCancellable? = nil
        cancellable = Entity.loadModelAsync(named: ground + ".usdz")
            .sink(receiveCompletion: { error in
                print(error)
                cancellable?.cancel()
            }, receiveValue: { entity in
                anchorEntity.addChild(entity)
                entity.setScale(SIMD3<Float>(x: 3, y: 3, z: 3), relativeTo: entity)
                cancellable?.cancel()
            })
        
        scene.addAnchor(anchorEntity)
    }
    
    func moveEntity(direction: String) -> AnimationPlaybackController{
        var movement: AnimationPlaybackController!
        
        tigerEntity?.playAudio(tigerAudio!)
        
        switch direction{
        case "forward":
//            ini maju kedepan. translation itu buat kasih tau kalo maju kedepan nambahin vector z nya 20
            moveToLocation.translation = (tigerEntity?.transform.translation)! + simd_float3(x: 0, y: 0, z: 100)
            movement = tigerEntity?.move(to: moveToLocation, relativeTo: tigerEntity, duration: 5)
            
            print("gerak depan")
            
//            nambahin animasi jalan kalo bisa wkwk
        
        case "back":
            let rotateAngle = simd_quatf(angle: GLKMathDegreesToRadians(180), axis: SIMD3(x: 0, y: 1, z: 0))
//            tigerEntity?.setOrientation(rotateAngle, relativeTo: tigerEntity)
            
            var rotationTransform = tigerEntity?.transform
            rotationTransform?.rotation = rotateAngle
            movement = tigerEntity?.move(to: rotationTransform!, relativeTo: tigerEntity?.parent, duration: 5)
            
//            moveToLocation.translation = (tigerEntity?.transform.translation)! + simd_float3(x: 0, y: 0, z: 100)
//            movement = tigerEntity?.move(to: moveToLocation, relativeTo: tigerEntity, duration: 5)
            
            print("gerak belakang")
            
        case "left":
            let rotateAngle = simd_quatf(angle: GLKMathDegreesToRadians(90), axis: SIMD3(x: 0, y: 1, z: 0))
//            tigerEntity?.setOrientation(rotateAngle, relativeTo: tigerEntity)
            
            var rotationTransform = tigerEntity?.transform
            rotationTransform?.rotation = rotateAngle
            movement = tigerEntity?.move(to: rotationTransform!, relativeTo: tigerEntity?.parent, duration: 5)
            
//            moveToLocation.translation = (tigerEntity?.transform.translation)! + simd_float3(x: 0, y: 0, z: 100)
//            movement = tigerEntity?.move(to: moveToLocation, relativeTo: tigerEntity, duration: 5)
            
            print("gerak kiri")
            
        case "right":
            let rotateAngle = simd_quatf(angle: GLKMathDegreesToRadians(-90), axis: SIMD3(x: 0, y: 1, z: 0))
//            tigerEntity?.setOrientation(rotateAngle, relativeTo: tigerEntity)
            
            var rotationTransform = tigerEntity?.transform
            rotationTransform?.rotation = rotateAngle
            movement = tigerEntity?.move(to: rotationTransform!, relativeTo: tigerEntity?.parent, duration: 5)
            
//            moveToLocation.translation = (tigerEntity?.transform.translation)! + simd_float3(x: 0, y: 0, z: 100)
//            movement = tigerEntity?.move(to: moveToLocation, relativeTo: tigerEntity, duration: 5)
            
            print("gerak kanan")
        default:
            print("Ga gerak mas")
        }
        
        return movement
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
