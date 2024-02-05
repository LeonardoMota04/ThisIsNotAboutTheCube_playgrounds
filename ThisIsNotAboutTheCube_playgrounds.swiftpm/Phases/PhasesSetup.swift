import Foundation
import SceneKit

func setupLights(camera: SCNNode, root: SCNNode) {
    // Sphere that follows the camera to illuminate the top of the cube
    let sphereGeometry = SCNSphere(radius: 1)
    let sphereNode = SCNNode(geometry: sphereGeometry)
    let orangeMaterial = SCNMaterial()
    orangeMaterial.diffuse.contents = UIColor.clear
    sphereGeometry.materials = [orangeMaterial]
    sphereNode.position = SCNVector3(0, 1.5, -5)
    camera.addChildNode(sphereNode)
    
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
    root.addChildNode(lightNode_Ambient)
}


func setupVibrantLights(root: SCNNode) {
    // Adicione luzes à cena para criar um ambiente vibrante
    let ambientLightNode = SCNNode()
    ambientLightNode.light = SCNLight()
    ambientLightNode.light?.type = .ambient
    ambientLightNode.light?.intensity = 0.5 // Ajuste conforme necessário
    ambientLightNode.light?.color = UIColor.white
    root.addChildNode(ambientLightNode)

    let directionalLightNode = SCNNode()
    directionalLightNode.light = SCNLight()
    directionalLightNode.light?.type = .directional
    directionalLightNode.light?.intensity = 1.0 // Ajuste conforme necessário
    directionalLightNode.light?.color = UIColor.white
    directionalLightNode.position = SCNVector3(x: 0, y: 10, z: 0) // Posição da luz direcional
    root.addChildNode(directionalLightNode)

    let omniLightNode = SCNNode()
    omniLightNode.light = SCNLight()
    omniLightNode.light?.type = .omni
    omniLightNode.light?.intensity = 1.0 // Ajuste conforme necessário
    omniLightNode.light?.color = UIColor.white
    omniLightNode.position = SCNVector3(x: 0, y: 10, z: 0) // Posição da luz omni
    root.addChildNode(omniLightNode)
}


// PHASE 7
func rotateIceLayer(axis: SCNVector3, negative: Bool, cube: RubiksCube, root: SCNNode, completion: @escaping () -> Void) {
    let container = SCNNode()
    let wallNodes = cube.getWall(forAxis: axis, negative: negative)
    root.addChildNode(container)
    for node in wallNodes {
        container.addChildNode(node)
    }
    
    let rotationAction = SCNAction.rotate(by: .pi/40, around: axis, duration: 1)
    rotationAction.timingMode = .easeInEaseOut
    
    // TIRANDO NODES DO CONTAINER
    container.runAction(rotationAction) {
        var rotatedNodes: [SCNNode] = []
        
        for node: SCNNode in container.childNodes {
            let transform = node.parent!.convertTransform(node.transform, to: cube)
            node.removeFromParentNode()
            node.transform = transform
            cube.addChildNode(node)
            rotatedNodes.append(node)
        }
        completion()
    }
}
