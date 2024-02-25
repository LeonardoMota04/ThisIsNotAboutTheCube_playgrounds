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
    var cubeWidth: CGFloat = 1 // pieces size
    var cubeGeometry: SCNBox = SCNBox()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init() {
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
                    
                    xPos += Float(cubeWidth)
                    
                    self.addChildNode(cube)
                }
                xPos = -cubeOffsetDistance
                yPos += Float(cubeWidth)
            }
            xPos = -cubeOffsetDistance
            yPos = -cubeOffsetDistance
            zPos += Float(cubeWidth)
        }
    }
    
    
    private func cubeOffsetDistance() -> Float {
        return Float((cubeWidth) / 2)
    }
    
    func getChildPositions(forAxis axis: SCNVector3, node: SCNNode) -> Float {
        switch axis {
        case SCNVector3(x: 1, y: 0, z: 0):  // check for x-axis
            return node.position.x
        case SCNVector3(x: 0, y: 1, z: 0):  // check for y-axis
            return node.position.y
        case SCNVector3(x: 0, y: 0, z: 1):  // check for z-axis
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
    
}


// MARK: - EXTENSIONS
extension Float {
    func isVeryClose(to: Float, withTolerance: Float) -> Bool {
        let a = self
        let absA = abs(a)
        let absB = abs(to)
        let diff = abs(a - to)
        
        if (a == to) {
            // if A and B are equal, no necessity of verifying more
            return true
        } else if (a == 0 || to == 0 || diff < Float.leastNormalMagnitude) {
            // if A or B are zero, or both are nearly equal zero, error comparison is less important here
            return diff < (withTolerance * Float.leastNormalMagnitude)
        } else {
            // use relative error
            return diff / (absA + absB) < withTolerance
        }
    }
}

// SCNVector3 equatable so I can use it inside a SWITCH - CASE
extension SCNVector3: Equatable {
    public static func == (lhs: SCNVector3, rhs: SCNVector3) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z
    }
}
