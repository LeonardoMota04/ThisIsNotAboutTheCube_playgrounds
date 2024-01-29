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

    var edgeDistance975 : Float = 0.975
    var tolerance25: Float = 0.025
    
    // onboarding controll
    var madeOneFingerMovements: Bool = false
    var madeTwoFingerMovements: Bool = false
    var movementsToPassTutorial: Int = 3
    var readOnBoardingText: Bool = true
    var cameraIsMoving: Bool = false
    
    // AUDIO
    let audioManager = AudioManager.shared
    
    // MARK: - DIDLOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScene()
        createRubiksCube()
        setupFloatingAnimation()
        setupCurrentPhase()
        setupGestureRecognizers()
    }
    
    // MARK: - PHASES ===========================================================
    func setupCurrentPhase() {
        switch currentPhaseIndex {
            case 0:
                print("OnBoarding")
                setupCamera()
                //setupLights(camera: cameraNode, root: rootNode)
                audioManager.startBackgroundMusic()
                //setupOnboarding()
                
            case 1:
                print("fase 1")
                self.rubiksCube.changeCubeTexture()
            self.createCenterBall()
            case 2:
                print("fase 2")
            case 3:
                print("fase 3")
            case 4:
                print("fase 4")
            case 5:
                print("fase 5")
            case 6:
                print("fase 6")
            case 7:
                print("fase 7")
            case 8:
                print("fase 8")
            case 9:
                print("fase 9")
            
            default:
                print("fase fora")
            
        }
    }
    func HandleReactionsForEachMovementInPhase() {
        switch currentPhaseIndex {
            case 0:
                print("OnBoardingAAAAAAAAA")
                if numOfMovements == movementsToPassTutorial {
                    self.madeOneFingerMovements = true // setupOnboarding()
                } else if numOfMovements == requiredMovementsForCurrentPhase {
                    moveToNextPhase()
                    numOfMovements = 0
                }
            
            case 1, 2, 3, 4, 5, 6, 7, 8, 9:
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
        sceneView.showsStatistics = true
        self.view.addSubview(sceneView)
        rootNode = sceneView.scene!.rootNode
    
        /// phases
        cubePhases = [
            /// Onboarding
            PhaseModel(phaseNumber: 0, title: "", actionLabel: "", backgroundColor: .black, movementsRequired: 5),
            /// 1
            PhaseModel(phaseNumber: 1, title: "FASE 1 TÍTULO AQUI", actionLabel: "ACAO1", backgroundColor: .blue, movementsRequired: 1),
            /// 2
            PhaseModel(phaseNumber: 2, title: "FASE 2 TÍTULO AQUI", actionLabel: "ACAO2", backgroundColor: .red, movementsRequired: 5),
            /// 3
            PhaseModel(phaseNumber: 3, title: "FASE 3 TÍTULO AQUI", actionLabel: "ACAO3", backgroundColor: .green, movementsRequired: 5),
            /// 4
            PhaseModel(phaseNumber: 3, title: "FASE 4 TÍTULO AQUI", actionLabel: "ACAO4", backgroundColor: .purple, movementsRequired: 5),
            /// 5
            PhaseModel(phaseNumber: 3, title: "FASE 5 TÍTULO AQUI", actionLabel: "ACAO5", backgroundColor: .red, movementsRequired: 5),
            /// 6
            PhaseModel(phaseNumber: 3, title: "FASE 6 TÍTULO AQUI", actionLabel: "ACAO6", backgroundColor: .white, movementsRequired: 5),
            /// 7
            PhaseModel(phaseNumber: 3, title: "FASE 7 TÍTULO AQUI", actionLabel: "ACAO7", backgroundColor: .red, movementsRequired: 5),
            /// 8
            PhaseModel(phaseNumber: 3, title: "FASE 8 TÍTULO AQUI", actionLabel: "ACAO8", backgroundColor: .blue, movementsRequired: 5),
            /// 9
            PhaseModel(phaseNumber: 3, title: "FASE 9 TÍTULO AQUI", actionLabel: "ACAO9", backgroundColor: .purple, movementsRequired: 5),
        ]

        //setupCurrentPhase()
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

        startFirstAnimation()
    }
    
    func startFirstAnimation () {
        // FIRST ANIMATION (ZOOM IN)
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 1
            self.cameraNode.pivot = SCNMatrix4MakeTranslation(0, 0, -10)
            self.cameraNode.eulerAngles = SCNVector3(-0.5, 0.75, 0)
            self.cameraIsMoving = true
            SCNTransaction.completionBlock = {
                self.cameraIsMoving = false
                //self.startSecondAnimation()
            }
            SCNTransaction.commit()
    }
    
    func startSecondAnimation(initialPosition: SCNVector3) {
        // volta pro normal
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 1.0
        SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .easeIn)
    
        self.cameraNode.position = initialPosition
        //self.cameraNode.eulerAngles = currentCameraRotation
        self.cameraNode.eulerAngles = SCNVector3(0, 0, 0)
        self.cameraNode.pivot = SCNMatrix4MakeTranslation(0, 0, -10) // CAMERA INITIAL POSITION

        SCNTransaction.completionBlock = {
            //DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                
                // esquerda
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 4.0
                SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                self.cameraNode.position.x += 5.0
            
                SCNTransaction.completionBlock = {
                    // direita
                    // check if user read text
                    if self.readOnBoardingText {
                        SCNTransaction.begin()
                        SCNTransaction.animationDuration = 4.0
                        SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                        self.cameraNode.position.x -= 10.0
                        //self.cameraNode.eulerAngles = SCNVector3(-0.5, 0.75, 0)
                        SCNTransaction.commit()
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                            SCNTransaction.begin()
                            SCNTransaction.animationDuration = 4.0
                            SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                            self.cameraNode.position.x += 5.0
                            //self.cameraNode.eulerAngles = SCNVector3(-0.5, 0.75, 0)
                            SCNTransaction.commit()
                        }
                    }
                }
                
                SCNTransaction.commit()
            //}
        }
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
        sceneView.gestureRecognizers = [panRecognizer]
    }
    
    @objc
    func sceneTouched(_ recognizer: UIPanGestureRecognizer) {
        let location = recognizer.location(in: sceneView)
        let hitResults = sceneView.hitTest(location, options: nil)
        let currentPhase = cubePhases[currentPhaseIndex]
        
        // MARK: - 2 FINGERS: CAMERA
        if recognizer.numberOfTouches == 2 && !cameraIsMoving {
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
                if self.madeOneFingerMovements {
                    self.madeTwoFingerMovements = true
                    print("entrou aqui em kkkk")
                    cameraNode.rotation = SCNVector4Make(axis.x, axis.y, axis.z, angle)
                    
                    if pode {
                        self.pode = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                            self.madeTwoFingerMovements = true
                            self.startSecondAnimation(initialPosition: self.finalCameraPositionAfterManipulation!)
                        }
                    }
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
                if recognizer.numberOfTouches == 0 {
                    print("aaaaasdasd")
                }
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
            // animation conditionalsπ
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
                    return child.position.y.nearlyEqual(b: self.beganPanNode.position.y, tolerance: tolerance25)
                }
                
                
                // (PLANO Y - DIREITA E ESQUERDA) ou (PLANO X - CIMA E BAIXO)
                if ((side == CubeSide.right || side == CubeSide.left) && plane == "Y")
                    || ((side == CubeSide.up || side == CubeSide.down) && plane == "X") {
                        self.rotationAxis = SCNVector3(0,0,1) // Z
                        //print("\nY ou X \(child.position.z.nearlyEqual(b: self.beganPanNode.position.z, tolerance: tolerance25))")
                        return child.position.z.nearlyEqual(b: self.beganPanNode.position.z, tolerance: tolerance25)
                }
                
                
                // (PLANO Y - FRENTE E TRÁS) ou (PLANO Z - CIMA E BAIXO)
                // |
                // v e pra cima
                if ((side == CubeSide.front || side == CubeSide.back) && plane == "Y")
                    || ((side == CubeSide.up || side == CubeSide.down) && plane == "Z") {
                        self.rotationAxis = SCNVector3(1,0,0) // X
                        //print("\nY ou Z \(child.position.x.nearlyEqual(b: self.beganPanNode.position.x, tolerance: tolerance25))")
                        return child.position.x.nearlyEqual(b: self.beganPanNode.position.x, tolerance: tolerance25)
                }
                
                
                return false
            }
            
            // this shouldnt happen, so exit
            if nodesToRotate.count <= 0 {
                self.animationLock = false
                self.beganPanNode = nil
                return
            }
            
            // add nodes we want to rotate to a parent node so that we can rotate relative to the root
            let container = SCNNode()
            print("nodes para rotacionar")
            rootNode.addChildNode(container)
            for nodeToRotate in nodesToRotate {
                //print(nodeToRotate.position)
                container.addChildNode(nodeToRotate)
            }
            
            // create action
            let rotationAngle = CGFloat(direction) * .pi/2
            let rotation_Action = SCNAction.rotate(by: rotationAngle, around: self.rotationAxis, duration: 0.2)
            let invertedRotation_Action = SCNAction.rotate(by: -rotationAngle, around: self.rotationAxis, duration: 0.2)
            
            var finalRotation_Action: SCNAction
            if currentPhaseIndex == 2 {
                finalRotation_Action = invertedRotation_Action
            } else {
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
                print("\n\nLADO NORTE RESOLVIDO: \(self.rubiksCube.isNorthWallSolved())")
                print("ROTACAO ANGULO: \(rotationAngle) / ROTACAOaxis: \(self.rotationAxis!)")
                print("lado: \(side!)")
                print("plano: \(plane)")
                print("direction: \(direction)")
                print("NUM DE MOVIMENTOS: \(self.numOfMovements)")
                self.animationLock = false
                self.animationLock = false
                self.beganPanNode = nil
            }
        }
    }
  
    private func selectedCubeSide(hitResult: SCNHitTestResult, edgeDistanceFromOrigin:Float) -> CubeSide {
        
        // X
        if beganPanHitResult.worldCoordinates.x.nearlyEqual(b: edgeDistanceFromOrigin, tolerance: tolerance25) {
            return .right
        }
        else if beganPanHitResult.worldCoordinates.x.nearlyEqual(b: -edgeDistanceFromOrigin, tolerance: tolerance25) {
            return .left
        }
        
        // Y
        else if beganPanHitResult.worldCoordinates.y.nearlyEqual(b: edgeDistanceFromOrigin, tolerance: tolerance25) {
            return .up
        }
        else if beganPanHitResult.worldCoordinates.y.nearlyEqual(b: -edgeDistanceFromOrigin, tolerance: tolerance25) {
            return .down
        }
        
        // Z
        else if beganPanHitResult.worldCoordinates.z.nearlyEqual(b: edgeDistanceFromOrigin, tolerance: tolerance25) {
            return .front
        }
        else if beganPanHitResult.worldCoordinates.z.nearlyEqual(b: -edgeDistanceFromOrigin, tolerance: tolerance25) {
            return .back
        }
        return .none
    }
}

