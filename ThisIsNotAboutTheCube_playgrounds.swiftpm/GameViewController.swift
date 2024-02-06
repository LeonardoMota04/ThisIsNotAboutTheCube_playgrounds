import UIKit
import AVFAudio
import SceneKit

class ViewController: UIViewController, ObservableObject {
    
    var pode: Bool = true
    // MARK: - VARIABLES
    // PHASES - published variables for SwiftUI
    @Published var cubePhases: [PhaseModel] = []
    @Published var currentPhaseIndex: Int = 0
    @Published var numOfMovements: Int = 0
    
    var currentPhase: PhaseModel {
        return cubePhases[currentPhaseIndex]
    }
    
    var requiredMovementsForCurrentPhase: Int {
        return currentPhase.movementsRequired
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
    var madeTwoFingerMovements: Bool = false
    var movementsToPassTutorial: Int = 3
    var readOnBoardingText1: Bool = false
    var readOnBoardingText2: Bool = false
    var cameraIsMoving: Bool = false
    var canRotateCamera: Bool = true
    
    // AUDIO
    let audioManager = AudioManager.shared
    
    // PHASE 1
    var rotatedNodesPhase1: [SCNNode] = []
    var podePassar1: Bool = false
    
    // PHASE 2
    var rotatedNodesPhase2: [[SCNNode]] = []
    
    // PHASE 7
    @Published var numOfMovementsPhase7: Int = 0
    
    
    // MARK: - DIDLOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScene()
        createRubiksCube()
        setupFloatingAnimation()
        setupCurrentPhase()
        setupGestureRecognizers()
        
    }
    
    // MARK: - PHASES 
    // SETUP WHAT HAPPENS EVERYTIME A NEW PHASE COME IN
    func setupCurrentPhase() {
        switch currentPhaseIndex {
            case 0:
                print("OnBoarding")
                setupCamera()
                setupLabel(camera: self.cameraNode, root: self.rootNode)
                audioManager.startBackgroundMusic()
                
            case 1:
                print("fase 1")
                shuffleCube(times: 15)
                canRotateCamera = false
//                 Rotate last layer
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    self.rotateLastLayer(axis: SCNVector3(0, 1, 0)) { rotatedNodes in
                        self.rotatedNodesPhase1 = rotatedNodes
                    }
                    // Can rotate cube
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.canRotateCube = true
                        self.cameraIsMoving = false
                    }
                }
                
            case 2:
                print("fase 2")
                canRotateCamera = true
                // Can rotate cube
           
            case 3:
                print("fase 3")
            case 4:
                print("fase 4")
                setupLights(camera: self.cameraNode, root: self.rootNode)
            case 5:
                print("fase 5")
                setupVibrantLights(root: self.rootNode)
            case 6:
                print("fase 6")
            case 7:
                print("fase 7")
                self.rubiksCube.changeCubeTexture()
            case 8:
                print("fase 8")
                self.createCenterBall()
            case 9:
                print("fase 9")
            self.currentPhaseIndex = 0
            
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
            
            case 1:
                if podePassar1 {
                    moveToNextPhase()
                    numOfMovements = 0
                }
            
            case 2, 3, 4, 5, 6, 7, 8, 9:
                print("fases")
                if numOfMovements == requiredMovementsForCurrentPhase {
                    moveToNextPhase()
                    numOfMovements = 0
                }
            default:
                print("fase fora")
        }
    }
    
    func moveToNextPhase() {
        currentPhaseIndex += 1
        if currentPhaseIndex < cubePhases.count {
            setupCurrentPhase()
        } else {
            // ACABOU
            print("cabou")
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
        cubePhases = PhaseModel.phases
    }

    // MARK: - CUBE
    func createRubiksCube() {
        rubiksCube = RubiksCube()
        rootNode.addChildNode(rubiksCube)
    }

    // MARK: - FLOATING ANIMATION (PHASE)
    func setupFloatingAnimation() {
        let floatUp = SCNAction.move(by: SCNVector3(0, 0.3, 0), duration: 1.0)
        let floatDown = SCNAction.move(by: SCNVector3(0, -0.3, 0), duration: 1.0)
        let floatSequence = SCNAction.sequence([floatUp, floatDown])
        let floatForever = SCNAction.repeatForever(floatSequence)

        if shouldFloat {
            //rubiksCube.runAction(floatForever)
        }
    }

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
    
    func startFirstAnimation () {
        // FIRST ANIMATION (ZOOM IN)
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 5
            SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

            self.cameraNode.pivot = SCNMatrix4MakeTranslation(0, 0, -10)
            self.cameraNode.eulerAngles = SCNVector3(-0.5, 0.75, 0)
            self.cameraIsMoving = true
            SCNTransaction.completionBlock = {
                if !self.readOnBoardingText2 {
                    self.cameraIsMoving = false
                }
            }
            SCNTransaction.commit()
    }
    
    func startSecondAnimation(initialPosition: SCNVector3) {
        // ANIMATION BEGINS
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 1
        SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .easeIn)
    
        self.cameraNode.position = initialPosition
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
        if !firstEverTouch {
            startFirstAnimation() // Zoom in
            //moveText(text1: textNode01, text2: textNode02, by: SCNVector3(-1, 8, 50), duration: 5)
            moveText(text1: textNode01, text2: textNode02, by: SCNVector3(-0.5, -8, 50), duration: 5)
            firstEverTouch = true
        }
    }
    
    
    @objc
    func sceneTouched(_ recognizer: UIPanGestureRecognizer) {
        let location = recognizer.location(in: sceneView)
        let hitResults = sceneView.hitTest(location, options: nil)
        let currentPhase = cubePhases[currentPhaseIndex]
        
        // MARK: - 2 FINGERS: CAMERA
        if recognizer.numberOfTouches == 2 && !cameraIsMoving && canRotateCamera {
            switch recognizer.state {

            case .began:
                print("comecou")
                // initial camera position
                //initialCameraPosition = cameraNode.position
                
            case .changed:
                // ROTATIONS
                let old_Rotation = cameraNode.rotation as SCNQuaternion
                var new_Rotation = GLKQuaternionMakeWithAngleAndAxis(old_Rotation.w, old_Rotation.x, old_Rotation.y, old_Rotation.z)

                // VELOCITY
                let xVelocity = Float(recognizer.velocity(in: sceneView).x) * 0.1
                let yVelocity = Float(recognizer.velocity(in: sceneView).y) * 0.1
                //let velocity = xVelocity + yVelocity
                
                // AXIS
                let rotX = GLKQuaternionMakeWithAngleAndAxis(-xVelocity/screenWidth, 0, 1, 0)
                let rotY = GLKQuaternionMakeWithAngleAndAxis(-yVelocity/screenHeight, 1, 0, 0)
                
                // NETS
                let rotation_Net = GLKQuaternionMultiply(rotX, rotY)
                new_Rotation = GLKQuaternionMultiply(new_Rotation, rotation_Net)
                
                // NEW AXIS AND ANGLE
                let axis = GLKQuaternionAxis(new_Rotation)
                let angle = GLKQuaternionAngle(new_Rotation)
                
                finalCameraPositionAfterManipulation = cameraNode.position
                // SE ESTIVER NA FASE 0 E OS PRIMEIROS MOVIMENTOS JA TIVEREM SIDO FEITOS
                switch currentPhaseIndex {
                case 0:
                    if self.madeOneFingerMovements {
                        self.madeTwoFingerMovements = true
                        cameraNode.rotation = SCNVector4Make(axis.x, axis.y, axis.z, angle)

                        if pode {
                            self.pode = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                                self.madeTwoFingerMovements = true
                                self.startSecondAnimation(initialPosition: self.finalCameraPositionAfterManipulation!)
                            }
                        }
                    }
                case 2:
                    cameraNode.rotation = SCNVector4Make(-axis.x, -axis.y, axis.z, -angle)
                case 1, 3, 4, 5, 6, 7, 8, 9:
                    cameraNode.rotation = SCNVector4Make(axis.x, axis.y, axis.z, angle)

                default:
                    cameraNode.rotation = SCNVector4Make(axis.x, axis.y, axis.z, angle)
                }

                
                
            case .ended, .cancelled:
                print("acabou a mov")
                // end of the rotation gesture
                finalCameraPositionAfterManipulation = cameraNode.position
                if currentPhase.phaseNumber == 0 && self.madeOneFingerMovements {
                    
                    // Gesture ended, start the second animation with the initial camera position
                    self.startSecondAnimation(initialPosition: finalCameraPositionAfterManipulation!)
                    finalCameraPositionAfterManipulation = nil
                }
            default:
                return
            }
            
            
//            // SE ESTIVER NA FASE 0 E OS PRIMEIROS MOVIMENTOS JA TIVEREM SIDO FEITOS
//            if currentPhase.phaseNumber == 0 && self.madeOneFingerMovements {
//                print("antes\(self.madeTwoFingerMovements)")
//                self.madeTwoFingerMovements = true
//                print("depois\(self.madeTwoFingerMovements)")
//                print("entrou aqui em kkkk")
//                cameraNode.rotation = SCNVector4Make(axis.x, axis.y, axis.z, angle)
//                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//                    self.madeTwoFingerMovements = true
//                    self.startSecondAnimation()
//                }
//            }
            
        }

        
        // MARK: - 1 FINGER: CUBE
        // gets first touch
        if recognizer.numberOfTouches == 1
            && hitResults.count > 0
            && recognizer.state == UIGestureRecognizer.State.began
            && beganPanNode == nil 
            && canRotateCube
            && !cameraIsMoving {

            beganPanHitResult = hitResults[0]
            beganPanNode = hitResults[0].node
        }
        
        // when the touch ends
        else if recognizer.state == UIGestureRecognizer.State.ended
                    && beganPanNode != nil
                    && animationLock == false {
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
            //print("nodes para rotacionar")
            rootNode.addChildNode(container)
            for nodeToRotate in nodesToRotate {
                //print(nodeToRotate)
                container.addChildNode(nodeToRotate)
            }
            
            // MARK: - ROTATIONS ACTIONS
            // create action
            let rotationAngle = CGFloat(direction) * .pi/2
            let rotation_Action = SCNAction.rotate(by: rotationAngle, around: self.rotationAxis, duration: 0.2)
            
            /// phase 1 - um em baixo
            /// phase 2 - reagem de forma contraria
            /// phase 3 - recuperacao
            /// phase 4 - sombras, perde cores, refletir
            /// phase 5 - vibrante, rotar camera
            /// phase 6 - flutuante, movimento lento, usar coremotion?
            /// phase 7 - congelado, lento e 15x em uma so
            /// phase 8 - transparente, 1 toque na central, bloquear
            /// phase 9 - montado, ganhar cores
            
            var finalRotation_Action: SCNAction = rotation_Action
            
            let nodesToRotateSet = Set(nodesToRotate) // sequencia nao importa
            let rotatedNodesPhase1Set = Set(self.rotatedNodesPhase1)
            let rotatedNodesPhase2Set = Set(self.rotatedNodesPhase2)

            switch currentPhaseIndex {
            case 1:
                print("fase 1")
                // animacao de rotacao bloqueada
                let rotationAngle = CGFloat(direction) * .pi / 4
                // Ação de rotação bloqueada
                let rotateRightAction = SCNAction.rotate(by: rotationAngle, around: self.rotationAxis, duration: 0.1)
                let rotateLeftAction = SCNAction.rotate(by: -rotationAngle*2, around: self.rotationAxis, duration: 0.1)
                
                let lockedRotation_Action = SCNAction.sequence([rotateRightAction, rotateLeftAction, rotateRightAction])
                
                if nodesToRotateSet == rotatedNodesPhase1Set {
                    podePassar1 = true
                } else {
                    finalRotation_Action = lockedRotation_Action
                }
                
            case 2:
                let invertedRotation_Action = SCNAction.rotate(by: -rotationAngle, around: self.rotationAxis, duration: 0.2)
                finalRotation_Action = invertedRotation_Action
                
                rotatedNodesPhase2.append(nodesToRotate)
            case 3:
                print("fase 3")
//                // Inverte rotatedNodesPhase2
//                //let reversedRotatedNodesPhase2 = Array(rotatedNodesPhase2.reversed())
//
//                // animacao de rotacao bloqueada
//                let rotationAngle = CGFloat(direction) * .pi / 4
//                // Ação de rotação bloqueada
//                let rotateRightAction = SCNAction.rotate(by: rotationAngle, around: self.rotationAxis, duration: 0.1)
//                let rotateLeftAction = SCNAction.rotate(by: -rotationAngle*2, around: self.rotationAxis, duration: 0.1)
//                
//                let lockedRotation_Action = SCNAction.sequence([rotateRightAction, rotateLeftAction, rotateRightAction])
//                
//                // Inverte rotatedNodesPhase2
//                let reversedRotatedNodesPhase2 = Array(rotatedNodesPhase2.reversed())
//                
//                
//                
//                // Verifica se nodesToRotateSet é igual ao conjunto de rotatedNodesPhase2 de trás para frente
//                if nodesToRotateSet == Set(rotatedNodesPhase2[0]) {
//                    finalRotation_Action = rotation_Action
//                } else {
//                    finalRotation_Action = lockedRotation_Action
//                    print("NODES TO ROTATE: \(nodesToRotate.count)")
//                    print("ROTATED: \(rotatedNodesPhase2[0].count)")
//                }
                
                
            case 4:
                print("fase 4")
                
            case 5:
                print("fase 5")
            case 6:
                print("espaço")
                let slowedRotation_Action = SCNAction.rotate(by: rotationAngle, around: self.rotationAxis, duration: 1.0)
                finalRotation_Action = slowedRotation_Action
                
            case 7:
                print("fase 7")
                let icedRotation_Action = SCNAction.rotate(by: rotationAngle/10, around: self.rotationAxis, duration: 0.5)
                finalRotation_Action = icedRotation_Action
            case 8:
                print("fase 8")
            case 9:
                print("fase 9")
            
            default:
                print("fase fora aq")
                finalRotation_Action = rotation_Action

            }
            
            // TIRANDO NODES DO CONTAINER
            container.runAction(finalRotation_Action) {
                for node: SCNNode in nodesToRotate {
                    let transform = node.parent!.convertTransform(node.transform, to: self.rubiksCube)
                    node.removeFromParentNode()
                    node.transform = transform
                    self.rubiksCube.addChildNode(node)
                }
                self.numOfMovements += 1
                //self.rubiksCube.changeCubeTexture()
                self.HandleReactionsForEachMovementInPhase()
                //print("\n\nLADO NORTE RESOLVIDO: \(self.rubiksCube.isNorthWallSolved())")
                //print("ROTACAO ANGULO: \(rotationAngle) / ROTACAOaxis: \(self.rotationAxis!)")
                //print("lado: \(side!)")
                //print("plano: \(plane)")
                //print("direction: \(direction)")
                print("NUM DE MOVIMENTOS: \(self.numOfMovements)")
                self.animationLock = false
                self.animationLock = false
                self.beganPanNode = nil
            }
        }
    }
    
    func setupLabel(camera: SCNNode, root: SCNNode) {
        if let customFont = UIFont(name: "fffforward", size: 5) {
            // Criar os textos
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
        let moveAction = SCNAction.move(by: by, duration: duration)
        moveAction.timingMode = .easeIn
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
        
        // TIRANDO NODES DO CONTAINER
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
    
    func shuffleCube(times: Int) {
        let numberOfMoves = times
        // Função para executar um movimento aleatório
        func performRandomMove(completion: @escaping () -> Void) {
            let randomValue = Float.random(in: 0...1)
            let randomAxis: SCNVector3
            
            if randomValue < 0.33 {
                // Caso em que x é 1
                randomAxis = SCNVector3(x: 1, y: 0, z: 0)
            } else if randomValue < 0.66 {
                // Caso em que y é 1
                randomAxis = SCNVector3(x: 0, y: 1, z: 0)
            } else {
                // Caso em que z é 1
                randomAxis = SCNVector3(x: 0, y: 0, z: 1)
            }
            
            let randomNegative = Bool.random()
            
            rotate(axis: randomAxis, negative: randomNegative) { nodes in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    completion()
                }
            }
        }

        
        // Função para executar a próxima iteração do embaralhamento
        func performNextIteration(iteration: Int) {
            if iteration < numberOfMoves {
                performRandomMove {
                    performNextIteration(iteration: iteration + 1)
                }
            }
        }
        
        // Iniciar o embaralhamento
        performNextIteration(iteration: 0)
    }


    // PHASE 1
    func rotateLastLayer(axis: SCNVector3, completion: @escaping ([SCNNode]) -> Void) {
        let container = SCNNode()
        let wallNodes = rubiksCube.getWall(forAxis: axis, negative: true)
        rootNode.addChildNode(container)
        for node in wallNodes {
            container.addChildNode(node)
        }
       
        let rotateAction = SCNAction.rotate(by: .pi*2, around: axis, duration: 1)
        rotateAction.timingMode = .easeInEaseOut
        // TIRANDO NODES DO CONTAINER
        container.runAction(rotateAction) {
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

