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
