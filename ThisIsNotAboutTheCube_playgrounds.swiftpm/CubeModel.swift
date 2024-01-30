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
    let colors:[UIColor] = [.orange, .green, .red, .blue, .yellow, .white]
    var cubeGeometry: SCNBox

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
                        ? [blackMaterial, blackMaterial, blueMaterial, orangeMaterial, blackMaterial, whiteMaterial]
                        : [blackMaterial, redMaterial, blueMaterial, blackMaterial, blackMaterial, whiteMaterial]
                    }
                    if i == 0 && j == 1 {
                        materials = (k % 2 == 0)
                        ? [blackMaterial, blackMaterial, blueMaterial, orangeMaterial, yellowMaterial, blackMaterial]
                        : [blackMaterial, redMaterial, blueMaterial, blackMaterial, yellowMaterial, blackMaterial]
                    }
                    if i == 1 && j == 0 {
                        materials = (k % 2 == 0)
                        ? [greenMaterial, blackMaterial, blackMaterial, orangeMaterial, blackMaterial, whiteMaterial]
                        : [greenMaterial, redMaterial, blackMaterial, blackMaterial, blackMaterial, whiteMaterial]
                    }
                    if i == 1 && j == 1 {
                        materials = (k % 2 == 0)
                        ? [greenMaterial, blackMaterial, blackMaterial, orangeMaterial, yellowMaterial, blackMaterial]
                        : [greenMaterial, redMaterial, blackMaterial, blackMaterial, yellowMaterial, blackMaterial]
                    }
                    cubeGeometry.materials = materials
                    
                    // creating cube
                    let cube = SCNNode(geometry: cubeGeometry)
                    cube.position = SCNVector3(x: xPos, y: yPos, z: zPos)
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
        let southWallNodes = self.childNodes { (child, stop) -> Bool in
            return child.position.z.nearlyEqual(b: self.cubeOffsetDistance(), tolerance: 0.01)
        }
        return southWallNodes
    }
    
    func getNorthWall() -> [SCNNode] {
        let northWallNodes = self.childNodes { (child, stop) -> Bool in
            return child.position.z.nearlyEqual(b: -self.cubeOffsetDistance(), tolerance: 0.01)
        }
        return northWallNodes
    }
    
    func isNorthWallSolved() -> Bool {
        let northWallNodes = getNorthWall()
        let material = northWallNodes[0].geometry?.materials[0]
        for i in 1..<northWallNodes.count {
            if material != northWallNodes[i].geometry?.materials[0] {
                return false
            }
        }
        return true
    }
    
    func isSolved() -> Bool {
        return false
    }
    
    func changeCubeTexture() {
        print("chamado!")
        
        let iceMaterial = SCNMaterial()
        iceMaterial.diffuse.contents = (UIImage(named: "Ice"))
        
        for node in self.childNodes {
            node.geometry?.materials = [iceMaterial]
        }
    }
    
    func getRandomAdjacentContainer(rotationAxis: SCNVector3, plane: String) -> SCNNode {
        let container = SCNNode()

        guard let shuffledNodes = self.childNodes.shuffled() as? [SCNNode] else {
            return container
        }

        // Selecione um node aleatório como ponto de partida
        guard let initialNode = shuffledNodes.randomElement() else {
            return container
        }

        // Filtra nodes que estão na mesma camada
        let sameLayerNodes = shuffledNodes.filter {
            switch plane {
            case "X":
                return $0.position.x.nearlyEqual(b: initialNode.position.x, tolerance: 0.025)
            case "Y":
                return $0.position.y.nearlyEqual(b: initialNode.position.y, tolerance: 0.025)
            case "Z":
                return $0.position.z.nearlyEqual(b: initialNode.position.z, tolerance: 0.025)
            default:
                return false
            }
        }

        var selectedNodes: [SCNNode] = []

        // Adiciona nodes adjacentes na mesma camada
        for _ in 0..<4 {
            // Adiciona um node aleatório próximo
            if let newNode = sameLayerNodes.randomElement() {
                selectedNodes.append(newNode)
            }
        }

        // Adiciona os nodes selecionados ao contêiner
        selectedNodes.forEach { container.addChildNode($0) }

        return container
    }

    
    
    private func row(y: Float) -> SCNNode {
        let container = SCNNode()
        
        for node in self.childNodes {
            if let geo = node.geometry, geo is SCNBox, node.position.y.isAlmost(y) {
                container.addChildNode(node)
            }
        }
        return container
    }
    
    private func col(x: Float) -> SCNNode {
        let container = SCNNode()
        
        for node in self.childNodes {
            if let geo = node.geometry, geo is SCNBox, node.position.x.isAlmost(x) {
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
    
    func nearlyEqual(b: Float, tolerance: Float) -> Bool {
        let a = self
        let absA = abs(a)
        let absB = abs(b)
        let diff = abs(a - b)
        
        if (a == b) {
            // Se a e b são iguais, não há necessidade de verificar mais nada.
            return true
        } else if (a == 0 || b == 0 || diff < Float.leastNormalMagnitude) {
            // Se a ou b é zero ou ambos são extremamente próximos de zero,
            // a comparação de erro relativo é menos significativa aqui.
            return diff < (tolerance * Float.leastNormalMagnitude)
        } else {
            // Usar erro relativo.
            return diff / (absA + absB) < tolerance
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

