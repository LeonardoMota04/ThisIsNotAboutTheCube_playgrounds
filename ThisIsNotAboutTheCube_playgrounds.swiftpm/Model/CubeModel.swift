//
//  CubeModel.swift
//  RubiksCubeSceneKit
//
//  Created by Leonardo Mota on 29/11/23.
//

import SceneKit

enum CubeSide {
    case front  // F
    case back   // B

    case right  // R
    case left   // L
    
    case up     // U
    case down   // D
    
    case none
}

class RubiksCube: SCNNode {
    
    var cubeWidth: CGFloat = 1
    var spaceBetweenCubes:Float = 0.0
    //let colors:[UIColor] = [.orange, .green, .red, .blue, .yellow, .white]
    var cubeGeometry: SCNBox
    var isFake: Bool = false

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init() {
        self.cubeGeometry = SCNBox(width: 0, height: 0, length: 0, chamferRadius: 0)
        
        super.init()
        
        createCube()
    }
    
    func createCube() {
        // materials
        let greenMaterial = SCNMaterial()
        greenMaterial.diffuse.contents = UIColor.green
        
        let redMaterial = SCNMaterial()
        redMaterial.diffuse.contents = UIColor.red
        
        let blueMaterial = SCNMaterial()
        blueMaterial.diffuse.contents = UIColor.blue
        
        let yellowMaterial = SCNMaterial()
        yellowMaterial.diffuse.contents = UIColor.yellow
        
        let whiteMaterial = SCNMaterial()
        whiteMaterial.diffuse.contents = UIColor.white
        
        let orangeMaterial = SCNMaterial()
        orangeMaterial.diffuse.contents = UIColor.orange
        
        let blackMaterial = SCNMaterial()
        blackMaterial.diffuse.contents = UIColor.black
        
        // initial positions
        let cubeOffsetDistance = self.cubeOffsetDistance()
        var xPos:Float = -cubeOffsetDistance
        var yPos:Float = -cubeOffsetDistance
        var zPos:Float = -cubeOffsetDistance
        
        // iterations for each cube
        for i in 0..<2 {
            for j in 0..<2 {
                for k in 0..<2 {
                    self.cubeGeometry = SCNBox(width: cubeWidth,
                                               height: cubeWidth,
                                               length: cubeWidth,
                                               chamferRadius: 0.15)
                    
                    // applying materials
                    var materials: [SCNMaterial] = []
                    if i == 0 && j == 0 {
                        materials = (k % 2 == 0)
                        ? [blackMaterial, blackMaterial, blueMaterial, orangeMaterial, blackMaterial, yellowMaterial]
                        : [blackMaterial, redMaterial, blueMaterial, blackMaterial, blackMaterial, yellowMaterial]
                    }
                    if i == 0 && j == 1 {
                        materials = (k % 2 == 0)
                        ? [blackMaterial, blackMaterial, blueMaterial, orangeMaterial, whiteMaterial, blackMaterial]
                        : [blackMaterial, redMaterial, blueMaterial, blackMaterial, whiteMaterial, blackMaterial]
                    }
                    if i == 1 && j == 0 {
                        materials = (k % 2 == 0)
                        ? [greenMaterial, blackMaterial, blackMaterial, orangeMaterial, blackMaterial, yellowMaterial]
                        : [greenMaterial, redMaterial, blackMaterial, blackMaterial, blackMaterial, yellowMaterial]
                    }
                    if i == 1 && j == 1 {
                        materials = (k % 2 == 0)
                        ? [greenMaterial, blackMaterial, blackMaterial, orangeMaterial, whiteMaterial, blackMaterial]
                        : [greenMaterial, redMaterial, blackMaterial, blackMaterial, whiteMaterial, blackMaterial]
                    }
                    
                    cubeGeometry.materials = materials
                    
                    // creating cube
                    let cube = SCNNode(geometry: cubeGeometry)
                    cube.position = SCNVector3(x: xPos, y: yPos, z: zPos)
                    
                    // nome
                    cube.name = "\(i)-\(j)-\(k)"
                    
                    xPos += Float(cubeWidth) + spaceBetweenCubes
                    
                    self.addChildNode(cube)
                }
                xPos = -cubeOffsetDistance
                yPos += Float(cubeWidth) + spaceBetweenCubes
            }
            xPos = -cubeOffsetDistance
            yPos = -cubeOffsetDistance
            zPos += Float(cubeWidth) + spaceBetweenCubes
        }
    }
    
    
    private func cubeOffsetDistance()->Float {
        return Float((cubeWidth) / 2)
    }
    
    func getSouthWall() -> [SCNNode] {
        let southWallNodes = self.childNodes { (child, _) -> Bool in
            return child.position.z.isVeryClose(to: self.cubeOffsetDistance(), withTolerance: 0.01)
        }
        return southWallNodes
    }
    
    func getChildPositions(forAxis axis: SCNVector3, node: SCNNode) -> Float {
        switch axis {
        case SCNVector3(x: 1, y: 0, z: 0):  // Check for x-axis
            return node.position.x
        case SCNVector3(x: 0, y: 1, z: 0):  // Check for y-axis
            return node.position.y
        case SCNVector3(x: 0, y: 0, z: 1):  // Check for z-axis
            return node.position.z
        default:
            fatalError()
        }
    }

    // Returns a specif wall of nodes (independent of the colors in it) to rotate
    func getWall(forAxis axis: SCNVector3, negative: Bool) -> [SCNNode] {
        let nodes = self.childNodes { (child, _) -> Bool in
            let childPosition = getChildPositions(forAxis: axis, node: child)
            return childPosition.isVeryClose(to: negative ? -self.cubeOffsetDistance() : self.cubeOffsetDistance(), withTolerance: 0.01)
        }
        return nodes
    }

    func getZWall() -> [SCNNode] {
        let northWallNodes = self.childNodes { (child, _) -> Bool in
            return child.position.z.isVeryClose(to: self.cubeOffsetDistance(), withTolerance: 0.01)
            //return child.position.z == self.cubeOffsetDistance()
        }
        return northWallNodes
    }
    
    func isZWallSolved() -> Bool {
        let zWallNodes = getZWall()
        let material = zWallNodes[0].geometry?.materials[0]
        for i in 1..<zWallNodes.count {
            if material != zWallNodes[i].geometry?.materials[0] {
                return false
            }
        }
        return true
    }
    
    func isSolved() -> Bool {
        return false
    }
    
    func resetCubeColors() {
        let greenMaterial = SCNMaterial()
        greenMaterial.diffuse.contents = UIColor.green
        
        let redMaterial = SCNMaterial()
        redMaterial.diffuse.contents = UIColor.red
        
        let blueMaterial = SCNMaterial()
        blueMaterial.diffuse.contents = UIColor.blue
        
        let yellowMaterial = SCNMaterial()
        yellowMaterial.diffuse.contents = UIColor.yellow
        
        let whiteMaterial = SCNMaterial()
        whiteMaterial.diffuse.contents = UIColor.white
        
        let orangeMaterial = SCNMaterial()
        orangeMaterial.diffuse.contents = UIColor.orange
        
        let blackMaterial = SCNMaterial()
        blackMaterial.diffuse.contents = UIColor.black
        
        var materialArray: [SCNMaterial] = []
        
        for i in 0..<2 {
            for j in 0..<2 {
                for k in 0..<2 {
                    if i == 0 && j == 0 {
                        materialArray = (k % 2 == 0)
                            ? [blackMaterial, blackMaterial, blueMaterial, orangeMaterial, blackMaterial, yellowMaterial]
                            : [blackMaterial, redMaterial, blueMaterial, blackMaterial, blackMaterial, yellowMaterial]
                    }
                    if i == 0 && j == 0 {
                        materialArray = (k % 2 == 0)
                        ? [blackMaterial, blackMaterial, blueMaterial, orangeMaterial, blackMaterial, yellowMaterial]
                        : [blackMaterial, redMaterial, blueMaterial, blackMaterial, blackMaterial, yellowMaterial]
                    }
                    if i == 0 && j == 1 {
                        materialArray = (k % 2 == 0)
                        ? [blackMaterial, blackMaterial, blueMaterial, orangeMaterial, whiteMaterial, blackMaterial]
                        : [blackMaterial, redMaterial, blueMaterial, blackMaterial, whiteMaterial, blackMaterial]
                    }
                    if i == 1 && j == 0 {
                        materialArray = (k % 2 == 0)
                        ? [greenMaterial, blackMaterial, blackMaterial, orangeMaterial, blackMaterial, yellowMaterial]
                        : [greenMaterial, redMaterial, blackMaterial, blackMaterial, blackMaterial, yellowMaterial]
                    }
                    if i == 1 && j == 1 {
                        materialArray = (k % 2 == 0)
                        ? [greenMaterial, blackMaterial, blackMaterial, orangeMaterial, whiteMaterial, blackMaterial]
                        : [greenMaterial, redMaterial, blackMaterial, blackMaterial, whiteMaterial, blackMaterial]
                    }
                    
                    _ = "\(i)-\(j)-\(k)"
                    for node in self.childNodes {
                        node.geometry?.materials = materialArray
                    }
                }
            }
        }
    }
    
    func changeCubeTexture() {
        print("chamado!")
        
        let iceMaterial = SCNMaterial()
        iceMaterial.diffuse.contents = (UIImage(named: "Ice"))
        if let iceTexture = UIImage(named: "Ice") {
                let iceMaterial = SCNMaterial()
                iceMaterial.diffuse.contents = iceTexture
                iceMaterial.diffuse.wrapS = .repeat
                iceMaterial.diffuse.wrapT = .repeat
                iceMaterial.isDoubleSided = true
                
                for node in self.childNodes {
                    node.geometry?.materials = [iceMaterial]
                }
            }
        
        for node in self.childNodes {
            node.geometry?.materials = [iceMaterial]
        }
    }
    func changeCubeTextureToRed() {
        let redMaterial = SCNMaterial()
        redMaterial.diffuse.contents = UIColor.red
        
        for node in self.childNodes {
            node.geometry?.materials = [redMaterial]
        }
    }
    
    func row(yy: Float, childNodes: [SCNNode]) -> SCNNode {
        let container = SCNNode()
        
        for node in childNodes {
            if let geo = node.geometry, geo is SCNBox && node.isHidden && node.position.y >= -2 && (node.position.y.isAlmost(yy)) {
                container.addChildNode(node)
            }
        }
        return container
    }
    
    func col(xx: Float, childNodes: [SCNNode]) -> SCNNode {
        let container = SCNNode()
        
        for node in childNodes {
            if let geo = node.geometry, geo is SCNBox && node.isHidden && node.position.y >= -2 && (node.position.x.isAlmost(xx) || node.presentation.position.x.isAlmost(xx)) {
                node.removeFromParentNode()
                container.addChildNode(node)
            }
        }
        return container
    }
    
    func col(zz: Float, childNodes: [SCNNode]) -> SCNNode {
        let container = SCNNode()
        
        for node in childNodes {
            if let geo = node.geometry, geo is SCNBox && node.isHidden && node.position.y >= -2 && (node.position.z.isAlmost(zz) || node.presentation.position.z.isAlmost(zz)) {
                node.removeFromParentNode()
                container.addChildNode(node)
            }
        }
        return container
    }
    

    
}




extension Float {
//    func nearlyEqual(b: Float, tolerance: Float) -> Bool {
//        
//        let difference = abs(self - b)
//        // if the difference is irrelevant OR the greatest of them is smaller than the tolerance
//        return difference < tolerance || difference / max(abs(self), abs(b)) < tolerance
//        
//    }
    
    func isVeryClose(to: Float, withTolerance: Float) -> Bool {
        let a = self
        let absA = abs(a)
        let absB = abs(to)
        let diff = abs(a - to)
        
        if (a == to) {
            // Se a e b são iguais, não há necessidade de verificar mais nada.
            return true
        } else if (a == 0 || to == 0 || diff < Float.leastNormalMagnitude) {
            // Se a ou b é zero ou ambos são extremamente próximos de zero,
            // a comparação de erro relativo é menos significativa aqui.
            return diff < (withTolerance * Float.leastNormalMagnitude)
        } else {
            // Usar erro relativo.
            return diff / (absA + absB) < withTolerance
        }
    }
    
    func isAlmost(_ num : Float) -> Bool {
        return abs(self - num) < 0.05
    }

    static func randomRotation() -> Float {
        let randomFactor = Float.random(in: 0..<4) // 0, 1, 2 or 3
        return randomFactor * Float.pi / 2
    }
//    // returns a random rotation in 90 degree intervals: 0, 90, 270, 360
//    static func randomRotation() -> Float {
//        // random between 1 and 359
//        let randomDegreeNumber = Int(arc4random_uniform(360) + 1)
//        // rounds it to nearest rotation
//        let rotation = Float(Int((Double(randomDegreeNumber) / 90.0) + 0.5) * 90) * Float(Double.pi / 180)
//        return rotation
//    }
//    
    
}

extension SCNVector3: Equatable {
    public static func == (lhs: SCNVector3, rhs: SCNVector3) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z
    }
}
