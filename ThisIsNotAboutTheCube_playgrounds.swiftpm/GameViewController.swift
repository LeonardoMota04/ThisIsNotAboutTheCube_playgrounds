import UIKit
import AVFAudio
import SceneKit

class ViewController: UIViewController, ObservableObject {
    var currentAngleY: Float = 0
    var currentAngleX: Float = 0

    // MARK: - VARIABLES
    // PHASES - published variables for SwiftUI
    @Published var cubePhases: [PhaseModel] = []
    @Published var currentPhaseIndex: Int = 0
    @Published var numOfMovements: Int = 0
    
    var currentPhase: PhaseModel? {
        guard !cubePhases.isEmpty else {
            return nil
        }
        return cubePhases[currentPhaseIndex]
    }

    
    var requiredMovementsForCurrentPhase: Int {
        return currentPhase!.movementsRequired
    }
    
    var finishedOnboarding: Bool {
        return readOnBoardingText2
    }
    
    // SCREEN
    let screenSize: CGRect = UIScreen.main.bounds
    var screenWidth: Float!
    var screenHeight: Float!
    
    // SCENE
    var sceneView: SCNView!
    var rootNode: SCNNode!
    var cameraNode: SCNNode!
    var finalCameraPositionAfterManipulation: SCNVector3?
    var rubiksCube: RubiksCube!
    var rubiksCube2: RubiksCube!
    var rubiksCube3: RubiksCube!

    // TOUCHES
    var beganPanHitResult: SCNHitTestResult!
    var beganPanNode: SCNNode!
    var rotationAxis:SCNVector3!
    
    // CONTROL VARIABLES
    var animationLock = false
    var shouldFloat = true
    var canRotateCube = true

    var edgeDistance975 : Float = 0.975
    var tolerance25: Float = 0.025
    
    // onboarding controll
    var firstEverTouch: Bool = false
    var textNode01: SCNNode?
    var textNode02: SCNNode?
    var madeOneFingerMovements: Bool = false
    @Published var madeTwoFingerMovements: Bool = false
    var shouldMakeTwoFingerMovement: Bool = true
    var movementsToPassTutorial: Int = 3
    @Published var readOnBoardingText1: Bool = false
    @Published var readOnBoardingText2: Bool = false
    
    var cameraIsMoving: Bool = false
    var canRotateCamera: Bool = true
    
    // AUDIO
    let audioManager = AudioManager.shared
    
    // PHASE 1
    var rotatedNodesPhase1: [SCNNode] = []
    //var podePassar1: Bool = false
    
    // PHASE 2
    var rotatedNodesPhase2: [[SCNNode]] = []
    
    // PHASE 5
    @Published var readText1: Bool = false
    @Published var readText2: Bool = false
    
    
    // MARK: - DIDLOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScene()
        setupCurrentPhase()
        setupGestureRecognizers()
        
    }
    
    // MARK: - PHASES
    // SETUP WHAT HAPPENS EVERYTIME A NEW PHASE COME IN
    func setupCurrentPhase() {
        switch currentPhaseIndex {
            case 0:
            // FIRST INTERACTION
            if !finishedOnboarding {
                print("OnBoarding")
                createRubiksCube()
                setupCamera()
                setupLabel(camera: self.cameraNode, root: self.rootNode)
                audioManager.startBackgroundMusic()
                
            // RETURNED INTERACTIONS
            } else {
                print("entrei aqui")
                self.rubiksCube3.removeFromParentNode() // remove cubo falso
                createRubiksCube() // adiciona cubo normal
                self.startLastAnimation() // zoom out
                moveText(text1: textNode01!, text2: textNode02!, by: SCNVector3(0.5, 8, -50), duration: 5) // volta
                //moveText(text1: textNode01!, text2: textNode02!, by: SCNVector3(1.5, 24, -150), duration: 5) // voltabotao pular

                firstEverTouch = false
            }
            case 1:
                print("fase 1")
                shuffleCube(times: 25) {
                    setupLights(camera: self.cameraNode, root: self.rootNode)
                    self.canRotateCube = true
                    self.cameraIsMoving = false
                }
                
            // ANGER
            case 2:
                print("fase 2")
                //self.rubiksCube.changeCubeTexture()
            
            // BARGAINING
            case 3:
                print("fase 3")
                canRotateCamera = false
                
                self.bargainingAnimationCamera()

            case 4:
                print("fase 4")
                canRotateCamera = true
                rubiksCube2.removeFromParentNode()
            case 5:
                print("fase 5")
                setupVibrantLights(root: self.rootNode)

            default:
                print("fase fora")
            
        }
    }
    // MARK: - EACH PHASE INTERACTIONS
    func HandleReactionsForEachMovementInPhase() {
        switch currentPhaseIndex {
            case 0:
                if numOfMovements == movementsToPassTutorial {
                        self.madeOneFingerMovements = true
                        self.canRotateCube = false
                        numOfMovements = 0
                }
            
            case 2:
            self.denialAnimationCamera()
                if numOfMovements == requiredMovementsForCurrentPhase {
                    moveToNextPhase()
                    numOfMovements = 0
                }
            
            case 3:
            self.adjustCameraPositionPhase03()
            if numOfMovements == requiredMovementsForCurrentPhase {
                moveToNextPhase()
                numOfMovements = 0
            }
            
            case 1, 4:
                if numOfMovements == requiredMovementsForCurrentPhase {
                    moveToNextPhase()
                    numOfMovements = 0
                }
            // Camera / Removes cube and adds new one solved / Returns to phase 0
            case 5:
                if numOfMovements == requiredMovementsForCurrentPhase {
                    self.canRotateCube = false
                    self.canRotateCamera = false
                    self.currentPhaseIndex = 0
                    self.numOfMovements = 0
                    self.adjustCameraPositionPhase05_1()
                    self.rubiksCube.removeFromParentNode()
                    // places new cube
                    rubiksCube3 = RubiksCube()
                    rubiksCube3.position = SCNVector3Make(0, 0, 0)
                    rootNode.addChildNode(rubiksCube3)
                }
                
            
            default:
                print("fase fora")
        }
    }
    
    func moveToNextPhase() {
        if currentPhaseIndex < cubePhases.count {
            //DispatchQueue.main.async { [self] in
                currentPhaseIndex += 1
                setupCurrentPhase()
            //}
        }
    }
    // PHASES ===========================================================
    
    // MARK: - SCENE
    func setupScene() {
        screenWidth = Float(screenSize.width)
        screenHeight = Float(screenSize.height)
        
        /// sceneview
        sceneView = SCNView(frame: self.view.frame)
        sceneView.scene = SCNScene()
        sceneView.backgroundColor = .clear
        sceneView.showsStatistics = false
        sceneView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(sceneView)
        rootNode = sceneView.scene!.rootNode
        
        /// setup all phases
        DispatchQueue.main.async {
            self.cubePhases = PhaseModel.phases
        }
    }

    // MARK: - CUBE
    func createRubiksCube() {
        rubiksCube = RubiksCube()
        rootNode.addChildNode(rubiksCube)
    }

    // MARK: - FLOATING ANIMATION (PHASE)
    

    // MARK: - CAMERA
    func setupCamera() {
        let camera = SCNCamera()
        cameraNode = SCNNode()
        cameraNode.camera = camera
        rootNode.addChildNode(cameraNode)
        
        cameraNode.position = SCNVector3Make(0, 0, 0)
        cameraNode.pivot = SCNMatrix4MakeTranslation(0, 0, -80) // CAMERA INITIAL POSITION
        cameraNode.eulerAngles = SCNVector3(0, 0, 0)
    }
    
   
    func denialAnimationCamera() {
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 1
        SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        let randomRotationX = Float.random(in: -10...10)
        let randomRotationY = Float.random(in: -10...10)
        let randomRotationZ = Float.random(in: -10...10)
        
        let randomPivotZ = Float.random(in: -20...(-10))
        
        self.cameraNode.rotation = SCNVector4Make(randomRotationX, randomRotationY, randomRotationZ, -2)
        self.cameraNode.pivot = SCNMatrix4MakeTranslation(0, 0, randomPivotZ)
        
        SCNTransaction.commit()
    }

    func bargainingAnimationCamera() {
        // brings to center
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 5
        SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

        self.cameraNode.pivot = SCNMatrix4MakeTranslation(0, 0, -10)
        self.cameraNode.eulerAngles = SCNVector3(-0.5, 0.75, 0)
        self.cameraIsMoving = true
        SCNTransaction.completionBlock = { [self] in
            
                // left
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 3
                SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                cameraNode.position = SCNVector3Make(3, 0, -3)
            
            SCNTransaction.completionBlock = { [self] in
                cameraIsMoving = false
                
                // places new cube
                rubiksCube2 = RubiksCube()
                rubiksCube2.opacity = 0.0
                rootNode.addChildNode(rubiksCube2)

                SCNTransaction.begin()
                SCNTransaction.animationDuration = 4
                SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                rubiksCube2.opacity = 1.0
                rubiksCube2.position = SCNVector3Make(6, 0, -6)
                SCNTransaction.commit()
            }
            
            SCNTransaction.commit()
        }
        SCNTransaction.commit()
    }
    
    func adjustCameraPositionPhase03() {
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 1.0
        
        // Ajustar a posição da câmera
        let currentPosition = self.cameraNode.position
        let targetPosition = SCNVector3(x: max(currentPosition.x - 0.5, 0), y: currentPosition.y, z: min(currentPosition.z + 0.5, 0))
        self.cameraNode.position = targetPosition
        
        // Ajustar a posição do rubiksCube2
        let rubiksCube2TargetPosition = SCNVector3(x: Float(numOfMovements * 2), y: 0, z: -Float(numOfMovements * 2))
        rubiksCube2.position = rubiksCube2TargetPosition
        
        SCNTransaction.commit()
    }
    
    // MARK: - ULTIMA FASE
    // MEIO + DIREITA
    func adjustCameraPositionPhase05_1() {
        // brings to center
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 5
        SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

        self.cameraNode.eulerAngles = SCNVector3(0, 0, 0)
        self.cameraIsMoving = true
        SCNTransaction.completionBlock = { [self] in
            // right
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 3
            SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            self.cameraNode.position.x -= 5.0
        
            SCNTransaction.commit()
        }
        SCNTransaction.commit()
    }
    // ESQUERDA
    func adjustCameraPositionPhase05_2() {
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 3
        SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        self.cameraNode.position.x += 10.0
        
        SCNTransaction.commit()
    }
    // CENTRO
    func adjustCameraPositionPhase05_3() {
        // ANIMATION BEGINS
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 1
        SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .easeIn)
        self.cameraNode.position.x -= 5.0
        
        SCNTransaction.completionBlock = {
            self.setupCurrentPhase()
        }
        
        SCNTransaction.commit()
    }
    
    
    // LAST ANIMATION (ZOOM OUT)
    func startLastAnimation() {
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 5
        SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

        self.cameraNode.pivot = SCNMatrix4MakeTranslation(0, 0, -80)
        self.cameraNode.eulerAngles = SCNVector3(0, 0, 0)
        self.cameraIsMoving = true
        SCNTransaction.completionBlock = {
            //if !self.readOnBoardingText2 {
                //self.cameraIsMoving = false
            //}
        }
        SCNTransaction.commit()
    }
    
    // FIRST ANIMATION (ZOOM IN)
    func startFirstAnimation () {
        // FIRST ANIMATION (ZOOM IN)
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 5
            SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

            self.cameraNode.pivot = SCNMatrix4MakeTranslation(0, 0, -10)
            self.cameraNode.eulerAngles = SCNVector3(-0.5, 0.75, 0)
            self.cameraIsMoving = true
            SCNTransaction.completionBlock = {
                self.cameraIsMoving = false
            }
            SCNTransaction.commit()
    }
    
    // centro
    func startSecondAnimation() {
        // ANIMATION BEGINS
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 1
        SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .easeIn)
    
        self.cameraNode.eulerAngles = SCNVector3(0, 0, 0)
        self.cameraNode.pivot = SCNMatrix4MakeTranslation(0, 0, -10) // CAMERA INITIAL POSITION
        self.cameraIsMoving = true

        SCNTransaction.completionBlock = {
            self.startThirdAnimation()
        }
        
        SCNTransaction.commit()
    }
    
    // esquerda
    func startThirdAnimation() {
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 2.0
        SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        self.cameraNode.position.x += 5.0

        SCNTransaction.commit()
    }

    // direitassa
    func startFourthAnimation() {
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 2.0
        SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            self.cameraNode.position.x -= 10.0


        SCNTransaction.commit()
    }
    
    func startFifthAnimation() {
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 2.0
        SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        self.cameraNode.position.x += 5.0

        SCNTransaction.commit()
    }
    
    
    func createCenterBall() {
        let ballGeometry = SCNSphere(radius: 0.1)
        let ballNode = SCNNode(geometry: ballGeometry)
        let redMaterial = SCNMaterial()
        redMaterial.diffuse.contents = UIColor.red
        ballGeometry.materials = [redMaterial]
        ballNode.position = SCNVector3(0,0,0)
        rootNode.addChildNode(ballNode)
    }
    
    

    // MARK: - GESTURE RECOGNIZERS
    func setupGestureRecognizers() {
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(sceneTouched(_:)))
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(sceneTapped(_:)))
        sceneView.gestureRecognizers = [panRecognizer, tapGesture]
    }
    
    
    @objc
    func sceneTapped(_ gestureRecognizer: UITapGestureRecognizer) {
        guard let textNode01 = textNode01, let textNode02 = textNode02 else {
            return
        }
        // First touch
            // only in phase 0 (onboarding)
        if currentPhaseIndex == 0 {
                // only if the user didn't touched the scene yet
            if !firstEverTouch {
                    // only if is the first time interacting with the scene
                if !finishedOnboarding {
                    startFirstAnimation() // Zoom in
                    moveText(text1: textNode01, text2: textNode02, by: SCNVector3(-0.5, -8, 50), duration: 5)
                    firstEverTouch = true
                    // is the return of the user to the beggining
                } else {
                    startFirstAnimation() // zoom in
                    moveText(text1: textNode01, text2: textNode02, by: SCNVector3(-0.5, -8, 50), duration: 5) // zoom in
                    firstEverTouch = true
                    moveToNextPhase()
                }
                
            }
        }
        
    }
    
    
    @objc
    func sceneTouched(_ recognizer: UIPanGestureRecognizer) {
        let location = recognizer.location(in: sceneView)
        let hitResults = sceneView.hitTest(location, options: nil)
        
        // ROTATIONS
        let translation = recognizer.translation(in: sceneView)
        
        // Perform rotation based on translation
        let newRotationX = -Float(translation.y) * (.pi)/180
        let newRotationY = -Float(translation.x) * (.pi)/180
        
        // MARK: - 2 FINGERS: CAMERA
        if recognizer.numberOfTouches == 2 && !cameraIsMoving && canRotateCamera {
            
            //currentAngleX += newRotationX
            //currentAngleY += newRotationY
            
            // Optionally, update camera position based on your logic
            finalCameraPositionAfterManipulation = cameraNode.position
            
            switch currentPhaseIndex {
            case 0:
                if self.madeOneFingerMovements {
                    self.madeTwoFingerMovements = true
                    cameraNode.eulerAngles.x = currentAngleX + newRotationX
                    cameraNode.eulerAngles.y = currentAngleY + newRotationY
                    
                    if shouldMakeTwoFingerMovement {
                        self.shouldMakeTwoFingerMovement = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                            self.madeTwoFingerMovements = true
                            self.startSecondAnimation()
                        }
                    }
            }
            case 1:
                cameraNode.eulerAngles.x = -(currentAngleX + newRotationX)
                cameraNode.eulerAngles.y = -(currentAngleY + newRotationY)
            case 2...9:
                cameraNode.eulerAngles.x = currentAngleX + newRotationX
                cameraNode.eulerAngles.y = currentAngleY + newRotationY
            default:
                break
            }
        } else if recognizer.state == .ended {
            currentAngleX = cameraNode.eulerAngles.x
            currentAngleY = cameraNode.eulerAngles.y
        }

        
        // MARK: - 1 FINGER: CUBE
        if recognizer.numberOfTouches == 1
            && hitResults.count > 0
            && recognizer.state == .began
            && beganPanNode == nil
            && canRotateCube
            && !cameraIsMoving {
            
            beganPanHitResult = hitResults.first
            beganPanNode = beganPanHitResult.node
            
        } else if recognizer.state == .ended && beganPanNode != nil && animationLock == false {
            
            animationLock = true
            
            // TOQUE
            let touch_Location = recognizer.location(in: sceneView) // posicao do toque
            let projectedOrigin = sceneView.projectPoint(beganPanHitResult.worldCoordinates) // coordenadas do ponto inicial do toque em 3D
            let estimatedPoint = sceneView.unprojectPoint(SCNVector3( Float(touch_Location.x),
                                                                      Float(touch_Location.y),
                                                                      projectedOrigin.z) )
            
            // PLANO
            var plane = "?"
            var direction = 1
            
            //
            let xDiff = estimatedPoint.x - beganPanHitResult.worldCoordinates.x // movimento relativo desde o inicio do toque ate o momento atual
            let yDiff = estimatedPoint.y - beganPanHitResult.worldCoordinates.y
            let zDiff = estimatedPoint.z - beganPanHitResult.worldCoordinates.z
            
            let absXDiff = abs(xDiff)
            let absYDiff = abs(yDiff)
            let absZDiff = abs(zDiff)
            
            // LADO TOCADO
            var side:CubeSide!
            side = selectedCubeSide(hitResult: beganPanHitResult, edgeDistanceFromOrigin: edgeDistance975) //1.475)
            
            
            
            if side == CubeSide.none {
                self.animationLock = false
                self.beganPanNode = nil
                return
            }
            
            // MARK: - DIRECTION
            // DIREITA ou ESQUERDA
            if side == CubeSide.right || side == CubeSide.left {
                if absYDiff > absZDiff {
                    plane = "Y"
                    if side == CubeSide.right {
                        direction = yDiff > 0 ? 1 : -1
                    }
                    else {
                        direction = yDiff > 0 ? -1 : 1
                    }
                }
                else {
                    plane = "Z"
                    if side == CubeSide.right {
                        direction = zDiff > 0 ? -1 : 1
                    }
                    else {
                        direction = zDiff > 0 ? 1 : -1
                    }
                }
            }
            
            // CIMA ou BAIXO
            else if side == CubeSide.up || side == CubeSide.down {
                if absXDiff > absZDiff {
                    plane = "X"
                    if side == CubeSide.up {
                        direction = xDiff > 0 ? -1 : 1
                    }
                    else {
                        direction = xDiff > 0 ? 1 : -1
                    }
                }
                else {
                    plane = "Z"
                    if side == CubeSide.up {
                        direction = zDiff > 0 ? 1 : -1
                    }
                    else {
                        direction = zDiff > 0 ? -1 : 1
                    }
                }
            }
            
            // TRÁS ou FRENTE
            else if side == CubeSide.back || side == CubeSide.front {
                if absXDiff > absYDiff {
                    plane = "X"
                    if side == CubeSide.back {
                        direction = xDiff > 0 ? -1 : 1
                    }
                    else {
                        direction = xDiff > 0 ? 1 : -1
                    }
                }
                else {
                    plane = "Y"
                    if side == CubeSide.back {
                        direction = yDiff > 0 ? 1 : -1
                    }
                    else {
                        direction = yDiff > 0 ? -1 : 1
                    }
                }
            }
            
            // MARK: - ROTATION AXIS && POSITIONS
            let nodesToRotate =  rubiksCube.childNodes { (child, _) -> Bool in
                
                // (PLANO Z - DIREITA E ESQUERDA) ou (PLANO X - FRENTE E TRÁS)
                // --> <--
                if ((side == CubeSide.right || side == CubeSide.left) && plane == "Z")
                    || ((side == CubeSide.front || side == CubeSide.back) && plane == "X") {
                    self.rotationAxis = SCNVector3(0,1,0) // Y
                    //print("Z ou X \(child.position.y.nearlyEqual(b: self.beganPanNode.position.y, tolerance: tolerance25))")
                    return child.position.y.isVeryClose(to: self.beganPanNode.position.y, withTolerance: tolerance25)
                }
                
                
                // (PLANO Y - DIREITA E ESQUERDA) ou (PLANO X - CIMA E BAIXO)
                if ((side == CubeSide.right || side == CubeSide.left) && plane == "Y")
                    || ((side == CubeSide.up || side == CubeSide.down) && plane == "X") {
                    self.rotationAxis = SCNVector3(0,0,1) // Z
                    //print("\nY ou X \(child.position.z.nearlyEqual(b: self.beganPanNode.position.z, tolerance: tolerance25))")
                    return child.position.z.isVeryClose(to: self.beganPanNode.position.z, withTolerance: tolerance25)
                }
                
                
                // (PLANO Y - FRENTE E TRÁS) ou (PLANO Z - CIMA E BAIXO)
                // |
                // v e pra cima
                if ((side == CubeSide.front || side == CubeSide.back) && plane == "Y")
                    || ((side == CubeSide.up || side == CubeSide.down) && plane == "Z") {
                    self.rotationAxis = SCNVector3(1,0,0) // X
                    //print("\nY ou Z \(child.position.x.nearlyEqual(b: self.beganPanNode.position.x, tolerance: tolerance25))")
                    return child.position.x.isVeryClose(to: self.beganPanNode.position.x, withTolerance: tolerance25)
                }
                
                
                return false
            }
            
            if nodesToRotate.count <= 0 {
                self.animationLock = false
                self.beganPanNode = nil
                return
            }
            
            // container that holds all nodes to rotate after touch finished
            let container = SCNNode()
            rootNode.addChildNode(container)
            for nodeToRotate in nodesToRotate {
                if currentPhaseIndex != 1 {
                    container.addChildNode(nodeToRotate)
                }
            }
            
            // MARK: - ROTATIONS ACTIONS
            let rotationAngle = CGFloat(direction) * .pi/2
            let rotation_Action = SCNAction.rotate(by: rotationAngle, around: self.rotationAxis, duration: 0.2)
            var finalRotation_Action: SCNAction = rotation_Action
            
            switch currentPhaseIndex {
                // DENIAL - reversed
            case 1:
                let possibleAxes: [SCNVector3] = [
                    SCNVector3(1, 0, 0),  //X
                    SCNVector3(0, 1, 0),  //Y
                    SCNVector3(0, 0, 1)   //Z
                ]
                var randomRotationAxis = possibleAxes.randomElement()
                while randomRotationAxis == self.rotationAxis {
                    randomRotationAxis = possibleAxes.randomElement()
                }
                
                rotate(axis: randomRotationAxis!, negative: Bool.random()) { _ in
                    DispatchQueue.main.async {
                        self.numOfMovements += 1
                        self.HandleReactionsForEachMovementInPhase()
                    }
                    self.animationLock = false
                    self.beganPanNode = nil
                }
                
                // ANGER - locked
            case 2:
                let rotationAngle = CGFloat(direction) * .pi / 4
                let rotateRightAction = SCNAction.rotate(by: rotationAngle, around: self.rotationAxis, duration: 0.1)
                let rotateLeftAction = SCNAction.rotate(by: -rotationAngle*2, around: self.rotationAxis, duration: 0.1)
                let lockedRotation_Action = SCNAction.sequence([rotateRightAction, rotateLeftAction, rotateRightAction])
                
                finalRotation_Action = lockedRotation_Action
                
            default:
                finalRotation_Action = rotation_Action
            }
            
            // Only phase 1 has a diferent rotation behavior
            if currentPhaseIndex != 1 {
                container.runAction(finalRotation_Action) {
                    for node: SCNNode in nodesToRotate {
                        let transform = node.parent!.convertTransform(node.transform, to: self.rubiksCube)
                        node.removeFromParentNode()
                        node.transform = transform
                        self.rubiksCube.addChildNode(node)
                    }
                    
                    DispatchQueue.main.async {
                        self.numOfMovements += 1
                        self.HandleReactionsForEachMovementInPhase()
                    }
                    self.animationLock = false
                    self.beganPanNode = nil
                }
            }
        }
    }
    
    func setupLabel(camera: SCNNode, root: SCNNode) {
        if let customFont = UIFont(name: "fffforward", size: 5) {
            let thisIsNotAbout = "THIS IS NOT ABOUT"
            let theCube = "THE CUBE"

            let textGeometry1 = SCNText(string: thisIsNotAbout, extrusionDepth: 0.5)
            let textGeometry2 = SCNText(string: theCube, extrusionDepth: 0.5)

            textGeometry1.font = customFont
            textGeometry1.flatness = 0.1

            textGeometry2.font = customFont
            textGeometry2.flatness = 0.1

            // materials
            let grayMaterial = SCNMaterial()
            grayMaterial.diffuse.contents = UIColor(named: "color_darkerGray")
            let blackMaterial = SCNMaterial()
            blackMaterial.diffuse.contents = UIColor.black
            
            textGeometry1.materials = [grayMaterial, blackMaterial, blackMaterial]
            textGeometry2.materials = [grayMaterial, blackMaterial, blackMaterial]

            // text nodes
            let textNode1 = SCNNode(geometry: textGeometry1)
            let textNode2 = SCNNode(geometry: textGeometry2)

            // text sizes for positions
            let textSize1_X = textGeometry1.boundingBox.max.x - textGeometry1.boundingBox.min.x
            let textSize1_Y = textGeometry1.boundingBox.max.y - textGeometry1.boundingBox.min.y
        
            let textSize2_X = textGeometry2.boundingBox.max.x - textGeometry2.boundingBox.min.x
            let textSize2_Y = textGeometry2.boundingBox.max.y - textGeometry2.boundingBox.min.y

        
            textNode1.position = SCNVector3(-Float(textSize1_X) / 2, Float(textSize1_Y) / 2, -50)
            textNode2.position = SCNVector3(-Float(textSize2_X) / 2, -Float(textSize2_Y) * 2, -50)

            camera.addChildNode(textNode1)
            camera.addChildNode(textNode2)
            
            textNode01 = textNode1
            textNode02 = textNode2

        } else {
            print("Erro: Não foi possível carregar a fonte personalizada.")
        }
    }
    
    func moveText(text1: SCNNode, text2: SCNNode, by: SCNVector3, duration: TimeInterval) {
        print("moveu")
        let moveAction = SCNAction.move(by: by, duration: duration)
        moveAction.timingMode = .easeInEaseOut
        text1.runAction(moveAction); text2.runAction(moveAction)
    }


    func rotate(axis: SCNVector3, negative: Bool, completion: @escaping ([SCNNode]) -> Void) {
        let container = SCNNode()
        let wallNodes = rubiksCube.getWall(forAxis: axis, negative: negative)
        rootNode.addChildNode(container)
        for node in wallNodes {
            container.addChildNode(node)
        }
        
        let rotationAction = SCNAction.rotate(by: .pi/2, around: axis, duration: 0.1)
        rotationAction.timingMode = .easeInEaseOut
        
        // REMOVING NODES FROM CONTAINER AFTER ROTATION
        container.runAction(rotationAction) {
            var rotatedNodes: [SCNNode] = []
            
            for node: SCNNode in container.childNodes {
                let transform = node.parent!.convertTransform(node.transform, to: self.rubiksCube)
                node.removeFromParentNode()
                node.transform = transform
                self.rubiksCube.addChildNode(node)
                rotatedNodes.append(node)
            }
            completion(rotatedNodes)
            self.animationLock = false
            self.beganPanNode = nil
        }
    }
    
    func shuffleCube(times: Int, completion: @escaping () -> Void) {
        let numberOfMoves = times
            
        func performRandomMove(iteration: Int, completion: @escaping () -> Void) {
            let randomValue = Float.random(in: 0...1)
            let randomAxis: SCNVector3
            
            if randomValue < 0.33 {
                randomAxis = SCNVector3(x: 1, y: 0, z: 0)
            } else if randomValue < 0.66 {
                randomAxis = SCNVector3(x: 0, y: 1, z: 0)
            } else {
                randomAxis = SCNVector3(x: 0, y: 0, z: 1)
            }
            
            let randomNegative = Bool.random()
            
            rotate(axis: randomAxis, negative: randomNegative) { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    completion()
                }
            }
        }

        func performNextIteration(iteration: Int) {
            if iteration < numberOfMoves {
                performRandomMove(iteration: iteration) {
                    performNextIteration(iteration: iteration + 1)
                }
            } else {
                completion()
            }
        }
        
        performNextIteration(iteration: 0)
    }



    private func selectedCubeSide(hitResult: SCNHitTestResult, edgeDistanceFromOrigin:Float) -> CubeSide {
        
        // X
        if beganPanHitResult.worldCoordinates.x.isVeryClose(to: edgeDistanceFromOrigin, withTolerance: tolerance25) {
            return .right
        }
        else if beganPanHitResult.worldCoordinates.x.isVeryClose(to: -edgeDistanceFromOrigin, withTolerance: tolerance25) {
            return .left
        }
        
        // Y
        else if beganPanHitResult.worldCoordinates.y.isVeryClose(to: edgeDistanceFromOrigin, withTolerance: tolerance25) {
            return .up
        }
        else if beganPanHitResult.worldCoordinates.y.isVeryClose(to: -edgeDistanceFromOrigin, withTolerance: tolerance25) {
            return .down
        }
        
        // Z
        else if beganPanHitResult.worldCoordinates.z.isVeryClose(to: edgeDistanceFromOrigin, withTolerance: tolerance25) {
            return .front
        }
        else if beganPanHitResult.worldCoordinates.z.isVeryClose(to: -edgeDistanceFromOrigin, withTolerance: tolerance25) {
            return .back
        }
        return .none
    }
}

