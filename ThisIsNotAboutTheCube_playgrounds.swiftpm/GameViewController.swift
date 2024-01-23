import UIKit
import SceneKit

class ViewController: UIViewController, ObservableObject {
    
    // MARK: - VARIABLES
    // PHASES - published variables for SwiftUI
    @Published var cubePhases: [PhaseModel] = []
    @Published var currentPhaseIndex: Int = 0
    @Published var numOfMovements: Int = 0
    
    // SCREEN
    let screenSize: CGRect = UIScreen.main.bounds
    var screenWidth: Float!
    var screenHeight: Float!
    
    // SCENE
    var sceneView: SCNView!
    var rootNode: SCNNode!
    var cameraNode: SCNNode!
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScene()
        createRubiksCube()
        setupFloatingAnimation()
        setupCamera()
        setupCurrentPhase()
        //setupLights()
        setupGestureRecognizers()
    }
    
    // MARK: - PHASES
    func setupCurrentPhase() {
        let currentPhase = cubePhases[currentPhaseIndex]
        //sceneView.backgroundColor = currentPhase.backgroundColor
        
        switch currentPhase.phaseNumber {
            case 0:
                print("fase 0")
                setupLights()
            case 1:
                print("fase 1")
                self.rubiksCube.changeCubeTexture()
            case 2:
                print("fase 2")
            case 3:
                print("fase 3")
            case 4:
                print("fase 4")
            case 5:
                print("fase 5")
            default:
                print("fase fora")
            
        }
       
            
        // titulo
    }
    
    func moveToNextPhase() {
        currentPhaseIndex += 1
        if currentPhaseIndex < cubePhases.count {
            setupCurrentPhase()
            // setuplights for phase tal
        } else {
            // ACABOU
            print("cabou")
        }
    }
    
    func checkIfFinishedPhase() {
        let requiredMovements = cubePhases[currentPhaseIndex].movementsRequired
        if numOfMovements == requiredMovements { // ou numero necessario para passar para proxima fase
            moveToNextPhase()
            numOfMovements = 0
        }
    }
    
    // MARK: - SCENE
    func setupScene() {
        screenWidth = Float(screenSize.width)
        screenHeight = Float(screenSize.height)

        sceneView = SCNView(frame: self.view.frame)
        sceneView.scene = SCNScene()
        sceneView.backgroundColor = .clear
        
        
        sceneView.showsStatistics = true
        self.view.addSubview(sceneView)
        rootNode = sceneView.scene!.rootNode
    
        cubePhases = [
            PhaseModel(phaseNumber: 0, title: "", actionLabel: "", backgroundColor: .black, movementsRequired: 10),
            PhaseModel(phaseNumber: 1, title: "Clareca amoreca", actionLabel: "ACAO1", backgroundColor: .blue, movementsRequired: 3),
            PhaseModel(phaseNumber: 2, title: "sr panday sdds", actionLabel: "ACAO2", backgroundColor: .black, movementsRequired: 5),
            PhaseModel(phaseNumber: 3, title: "3 FASE", actionLabel: "ACAO3", backgroundColor: .red, movementsRequired: 5),
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

        // FIRST ANIMATION (ZOOM IN)
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 8.0
            self.cameraNode.pivot = SCNMatrix4MakeTranslation(0, 0, -10)
            self.cameraNode.eulerAngles = SCNVector3(-0.5, 0.75, 0)
            SCNTransaction.commit()

            // SECOND ANIMATION
            DispatchQueue.main.asyncAfter(deadline: .now() + 8.0) {
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 4.0
                // esquerda
                SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                self.cameraNode.position.x += 5.0 // ajuste conforme necessário
                self.cameraNode.eulerAngles = SCNVector3(0, 0, 0)
                SCNTransaction.commit()

                // direita
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
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
    }


    // MARK: - LIGHTS
    func setupLights() {
        // Sphere that follows the camera to illuminate the top of the cube
        let sphereGeometry = SCNSphere(radius: 0.1)
        let sphereNode = SCNNode(geometry: sphereGeometry)
        let orangeMaterial = SCNMaterial()
        orangeMaterial.diffuse.contents = UIColor.clear
        sphereGeometry.materials = [orangeMaterial]
        sphereNode.position = SCNVector3(0, 1.5, -5)
        cameraNode.addChildNode(sphereNode)
        
        // Light above cube
        let light_Omni = SCNLight()
        light_Omni.type = .omni
        light_Omni.intensity = 1200
        light_Omni.color = UIColor.white
        let lightNode_Omni = SCNNode()
        lightNode_Omni.light = light_Omni
        lightNode_Omni.position = sphereNode.position
        sphereNode.addChildNode(lightNode_Omni)
        
        // Ambient light
        let light_Ambient = SCNLight()
        light_Ambient.type = .ambient
        light_Ambient.color = UIColor.white
        light_Ambient.intensity = 10
        let lightNode_Ambient = SCNNode()
        lightNode_Ambient.light = light_Ambient
        rootNode.addChildNode(lightNode_Ambient)
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
        
        // MARK: - 2 FINGERS: CAMERA
        if recognizer.numberOfTouches == 2 {
            // ROTATIONS
            let old_Rotation = cameraNode.rotation as SCNQuaternion
            var new_Rotation = GLKQuaternionMakeWithAngleAndAxis(old_Rotation.w, old_Rotation.x, old_Rotation.y, old_Rotation.z)

            // VELOCITY
            let xVelocity = Float(recognizer.velocity(in: sceneView).x) * 0.1
            let yVelocity = Float(recognizer.velocity(in: sceneView).y) * 0.1
            let velocity = xVelocity + yVelocity
            
            // AXIS
            let rotX = GLKQuaternionMakeWithAngleAndAxis(-xVelocity/screenWidth, 0, 1, 0)
            let rotY = GLKQuaternionMakeWithAngleAndAxis(-yVelocity/screenHeight, 1, 0, 0)
            
            // NETS
            let rotation_Net = GLKQuaternionMultiply(rotX, rotY)
            new_Rotation = GLKQuaternionMultiply(new_Rotation, rotation_Net)
            
            // NEW AXIS AND ANGLE
            let axis = GLKQuaternionAxis(new_Rotation)
            let angle = GLKQuaternionAngle(new_Rotation)
            
            cameraNode.rotation = SCNVector4Make(axis.x, axis.y, axis.z, angle)
        }

        
        // MARK: - 1 FINGER: CUBE
        // gets first touch
        if recognizer.numberOfTouches == 1
            && hitResults.count > 0
            && recognizer.state == UIGestureRecognizer.State.began
            && beganPanNode == nil {

            beganPanHitResult = hitResults[0]
            beganPanNode = hitResults[0].node
        }
        
        // when the touch ends
        else if recognizer.state == UIGestureRecognizer.State.ended
                    && beganPanNode != nil
                    && animationLock == false {
            animationLock = true
            
            // TOQUE
            let touch_Location = recognizer.location(in: sceneView); // posicao do toque
            let projectedOrigin = sceneView.projectPoint(beganPanHitResult.worldCoordinates); // coordenadas do ponto inicial do toque em 3D
            let estimatedPoint = sceneView.unprojectPoint(SCNVector3( Float(touch_Location.x),
                                                                      Float(touch_Location.y),
                                                                      projectedOrigin.z) );

            // PLANO
            var plane = "?";
            var direction = 1;
            
            //
            let xDiff = estimatedPoint.x - beganPanHitResult.worldCoordinates.x; // movimento relativo desde o inicio do toque ate o momento atual
            let yDiff = estimatedPoint.y - beganPanHitResult.worldCoordinates.y;
            let zDiff = estimatedPoint.z - beganPanHitResult.worldCoordinates.z;
            
            let absXDiff = abs(xDiff)
            let absYDiff = abs(yDiff)
            let absZDiff = abs(zDiff)
            
            // LADO TOCADO
            var side:CubeSide!
            side = selectedCubeSide(hitResult: beganPanHitResult, edgeDistanceFromOrigin: edgeDistance975) //1.475)
            

            
            if side == CubeSide.none {
                self.animationLock = false;
                self.beganPanNode = nil;
                return
            }
            
            // MARK: - DIRECTION
            // DIREITA ou ESQUERDA
            if side == CubeSide.right || side == CubeSide.left {
                if absYDiff > absZDiff {
                    plane = "Y";
                    if side == CubeSide.right {
                        direction = yDiff > 0 ? 1 : -1;
                    }
                    else {
                        direction = yDiff > 0 ? -1 : 1;
                    }
                }
                else {
                    plane = "Z";
                    if side == CubeSide.right {
                        direction = zDiff > 0 ? -1 : 1;
                    }
                    else {
                        direction = zDiff > 0 ? 1 : -1;
                    }
                }
            }
            
            // CIMA ou BAIXO
            else if side == CubeSide.up || side == CubeSide.down {
                if absXDiff > absZDiff {
                    plane = "X";
                    if side == CubeSide.up {
                        direction = xDiff > 0 ? -1 : 1;
                    }
                    else {
                        direction = xDiff > 0 ? 1 : -1;
                    }
                }
                else {
                    plane = "Z"
                    if side == CubeSide.up {
                        direction = zDiff > 0 ? 1 : -1;
                    }
                    else {
                        direction = zDiff > 0 ? -1 : 1;
                    }
                }
            }
            
            // TRÁS ou FRENTE
            else if side == CubeSide.back || side == CubeSide.front {
                if absXDiff > absYDiff {
                    plane = "X";
                    if side == CubeSide.back {
                        direction = xDiff > 0 ? -1 : 1;
                    }
                    else {
                        direction = xDiff > 0 ? 1 : -1;
                    }
                }
                else {
                    plane = "Y"
                    if side == CubeSide.back {
                        direction = yDiff > 0 ? 1 : -1;
                    }
                    else {
                        direction = yDiff > 0 ? -1 : 1;
                    }
                }
            }
            
            // MARK: - ROTATION AXIS && POSITIONS
            let nodesToRotate =  rubiksCube.childNodes { (child, _) -> Bool in
                
                // PLANO Z - DIREITA E ESQUERDA ou PLANO X - FRENTE E TRÁS
                if ((side == CubeSide.right || side == CubeSide.left) && plane == "Z")
                    || ((side == CubeSide.front || side == CubeSide.back) && plane == "X") {
                        self.rotationAxis = SCNVector3(0,1,0) // Y
                    return child.position.y.nearlyEqual(b: self.beganPanNode.position.y, tolerance: tolerance25)
                }
                
                
                // PLANO Y - DIREITA E ESQUERDA ou PLANO X - CIMA E BAIXO
                if ((side == CubeSide.right || side == CubeSide.left) && plane == "Y")
                    || ((side == CubeSide.up || side == CubeSide.down) && plane == "X") {
                        self.rotationAxis = SCNVector3(0,0,1) // Z
                        return child.position.z.nearlyEqual(b: self.beganPanNode.position.z, tolerance: tolerance25)
                }
                
                
                // PLANO Y - FRENTE E TRÁS ou PLANO Z - CIMA E BAIXO
                if ((side == CubeSide.front || side == CubeSide.back) && plane == "Y")
                    || ((side == CubeSide.up || side == CubeSide.down) && plane == "Z") {
                        self.rotationAxis = SCNVector3(1,0,0) // X
                        return child.position.x.nearlyEqual(b: self.beganPanNode.position.x, tolerance: tolerance25)
                }
                
                
                return false;
            }
            
            // this shouldnt happen, so exit
            if nodesToRotate.count <= 0 {
                self.animationLock = false;
                self.beganPanNode = nil;
                return
            }
            
            // add nodes we want to rotate to a parent node so that we can rotate relative to the root
            let container = SCNNode()
            rootNode.addChildNode(container)
            for nodeToRotate in nodesToRotate {
                container.addChildNode(nodeToRotate)
            }
            
            // create action
            let rotationAngle = CGFloat(direction) * .pi/2;
            let rotation_Action = SCNAction.rotate(by: rotationAngle, around: self.rotationAxis, duration: 0.2)


            // TIRANDO NODES DO CONTAINER
            container.runAction(rotation_Action, completionHandler: { () -> Void in
                for node: SCNNode in nodesToRotate {
                    let transform = node.parent!.convertTransform(node.transform, to: self.rubiksCube)
                    node.removeFromParentNode()
                    node.transform = transform
                    self.rubiksCube.addChildNode(node)
                }
                self.numOfMovements += 1
                //self.rubiksCube.changeCubeTexture()
                self.checkIfFinishedPhase()
                print("\n\nLADO NORTE RESOLVIDO: \(self.rubiksCube.isNorthWallSolved())")
                print("ROTACAO ANGULO: \(rotationAngle) / ROTACAOaxis: \(self.rotationAxis!)")
                print("lado: \(side!)")
                print("plano: \(plane)")
                print("direction: \(direction)")
                print("NUM DE MOVIMENTOS: \(self.numOfMovements)")
                self.animationLock = false
                self.animationLock = false
                self.beganPanNode = nil
            })
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

