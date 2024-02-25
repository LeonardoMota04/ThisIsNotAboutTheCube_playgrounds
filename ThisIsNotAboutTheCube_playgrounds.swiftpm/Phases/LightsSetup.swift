import SceneKit

// DEFAULT LIGHTINING
func adjustDefaultLightning(intensityOmini: CGFloat, intensityAmbient: CGFloat, omniLight: SCNLight, ambientLight: SCNLight) {
    SCNTransaction.begin()
    SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
    SCNTransaction.animationDuration = 3
    
    omniLight.intensity = intensityOmini
    ambientLight.intensity = intensityAmbient
    
    SCNTransaction.commit()
}

// SETUP LOW LIGHT
func setupLowLights(ambientLight: SCNLight, omniLight: SCNLight, root: SCNNode, camera: SCNNode) {
    // Sphere that follows the camera to illuminate the top of the cube
    let sphereGeometry = SCNSphere(radius: 1)
    let sphereNode = SCNNode(geometry: sphereGeometry)
    sphereNode.position = SCNVector3(0, 1.5, -5)
    sphereNode.opacity = 0
    camera.addChildNode(sphereNode)

    // Light above cube
    omniLight.type = .omni
    omniLight.intensity = 0 // STARTS AT ZERO
    omniLight.color = UIColor.white
    let lightNode_Omni = SCNNode()
    lightNode_Omni.light = omniLight
    lightNode_Omni.position = sphereNode.position
    sphereNode.addChildNode(lightNode_Omni)

    // Ambient light
    ambientLight.type = .ambient
    ambientLight.color = UIColor.white
    ambientLight.intensity = 1000 // STARTS AT 1000
    let lightNode_Ambient = SCNNode()
    lightNode_Ambient.light = ambientLight
    root.addChildNode(lightNode_Ambient)

    SCNTransaction.begin()
    SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .easeOut)
    SCNTransaction.animationDuration = 3
    ambientLight.intensity = 0
    
    SCNTransaction.completionBlock = {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            SCNTransaction.begin()
            SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .easeIn)
            SCNTransaction.animationDuration = 1
            
            omniLight.intensity = 1200
            ambientLight.intensity = 50
            
            SCNTransaction.commit()
        }
    }
    SCNTransaction.commit()
}

