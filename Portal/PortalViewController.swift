import ARKit
import UIKit

class PortalViewController: UIViewController {
    
    // MARK: - State
    
    enum State: Int16 {
        case detectSurface  // Scan playable surface (Plane Detection On)
        case pointToSurface // Point to surface to see focus point (Plane Detection Off)
        case swipeToPlay    // Focus point visible on surface, swipe up to play
    }

    // MARK: - Outlets
    
    @IBOutlet var crosshair: UIView!
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet var messageLabel: UILabel?
    @IBOutlet var sessionStateLabel: UILabel?
    
    // MARK: - Actions
    
    @IBAction func backAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let hit = sceneView?.hitTest(self.focusPoint, types: [.existingPlaneUsingExtent]).first {
            sceneView?.session.add(anchor: ARAnchor(transform: hit.worldTransform))
        }
    }
    
    // MARK: - Property
    var focusPoint:CGPoint!
    var focusNode: SCNNode!
    var portalNode: SCNNode?
    var appState: State = .detectSurface
    var isPortalPlaced = false
    var debugPlanes: [SCNNode] = []
//    var viewCenter: CGPoint {
//        let viewBounds = view.bounds
//        return CGPoint(x: viewBounds.width / 2.0, y: viewBounds.height / 2.0)
//    }
    
    let POSITION_Y: CGFloat = -0.25
    let POSITION_Z: CGFloat = -SURFACE_LENGTH * 0.5
    
    let DOOR_WIDTH: CGFloat = 1.0
    let DOOR_HEIGHT: CGFloat = 2.4
    
    // MARK: - View Management
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resetLabels()
        
        initSceneView()
        initScene()
        let focusScene = SCNScene(named: "Assets.scnassets/FocusScene.scn")!
        focusNode = focusScene.rootNode.childNode(
            withName: "focus", recursively: false)!
        
        sceneView.scene.rootNode.addChildNode(focusNode)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initARSession()
        print("*** ViewWillAppear()")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("*** ViewWillDisappear()")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("*** DidReceiveMemoryWarning()")
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @objc
    func orientationChanged() {
        focusPoint = CGPoint(x: view.center.x, y: view.center.y + view.center.y * 0.25)
    }
    
    // MARK: - Initialization
    
    func initSceneView() {
        sceneView.delegate = self
        sceneView.showsStatistics = true
//        #if DEBUG
//        sceneView.debugOptions = [
//            ARSCNDebugOptions.showFeaturePoints,
//            ARSCNDebugOptions.showWorldOrigin,
//            SCNDebugOptions.showBoundingBoxes,
//            SCNDebugOptions.showWireframe
//        ]
//        #endif
        
        focusPoint = CGPoint(x: view.center.x, y: view.center.y + view.center.y * 0.25)
        NotificationCenter.default.addObserver(self, selector: #selector(PortalViewController.orientationChanged), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    func initScene() {
        let scene = SCNScene()
        sceneView.scene = scene
        //scene.lightingEnvironment.contents = "PokerDice.scnassets/Textures/Environment_CUBE.jpg"
        //scene.lightingEnvironment.intensity = 2
        scene.physicsWorld.speed = 1
        scene.physicsWorld.timeStep = 1.0 / 60.0
    }
    
    func initARSession() {
        guard ARWorldTrackingConfiguration.isSupported else {
            print("*** ARConfig: AR World Tracking Not Supported")
            return
        }
        
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = .horizontal
        config.isLightEstimationEnabled = true
        sceneView.session.run(config, options: [.resetTracking, .removeExistingAnchors])
    }
    
    // MARK: - Helper function
    
    func updateFocusNode() {
        if (self.appState != .detectSurface) {
            return
        }
        
        let results = self.sceneView.hitTest(self.focusPoint, types: [.existingPlaneUsingExtent])
        
        if results.count == 1 {
            if let match = results.first {
                let t = match.worldTransform
                self.focusNode.position = SCNVector3(x: t.columns.3.x, y: t.columns.3.y, z: t.columns.3.z)
//                self.gameState = .swipeToPlay
                focusNode.isHidden = false
            }
        } else {
//            self.gameState = .pointToSurface
            focusNode.isHidden = true
        }
    }
    
    func resetLabels() {
        messageLabel?.alpha = 1.0
        messageLabel?.text = "touch screen to place"
        sessionStateLabel?.alpha = 0.0
        sessionStateLabel?.text = ""
    }
    
    func showMessage(_ message: String, label: UILabel, seconds: Double) {
        label.text = message
        label.alpha = 1
        
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            if label.text == message {
                label.text = ""
                label.alpha = 0
            }
        }
    }
    
    func removeAllNodes() {
        removeDebugPlanes()
        portalNode?.removeFromParentNode()
        appState = .detectSurface
//        isPortalPlaced = false
    }
    
    func removeDebugPlanes() {
        for debugPlaneNode in debugPlanes {
            debugPlaneNode.removeFromParentNode()
        }
        debugPlanes = []
    }
    
    // MARK: - Make model
    
    func makeVideo() -> SCNNode {
        let node = SCNNode()
        
        let videoNode = SKVideoNode(fileNamed: "harrypotter.mp4")
        
        videoNode.play()
        
        let videoScene = SKScene(size: CGSize(width: 480, height: 360))
        videoScene.scaleMode = .aspectFit
        
        
        videoNode.position = CGPoint(x: videoScene.size.width / 2, y: videoScene.size.height / 2)
        videoNode.size = videoScene.size
        videoScene.backgroundColor = .clear
        videoNode.yScale = -1.0
        
        videoScene.addChild(videoNode)
        
        
        let plane = SCNPlane(width: CGFloat(0.11866), height: CGFloat(0.076))
//        let plane = SCNPlane(width: videoScene.size.width / 2, height: videoScene.size.height / 2)
        
        plane.firstMaterial?.diffuse.contents = videoScene
        
        let planeNode = SCNNode(geometry: plane)
        
//        planeNode.eulerAngles.x = .pi
        
        node.addChildNode(planeNode)
        
        return node
    }
    
    func makePortal() -> SCNNode {
        let portal = SCNNode()
        
        var virusNodes: [SCNNode] = []
        for i in 0...3 {
            virusNodes.append(makeVirusNode(sceneName: "Assets.scnassets/VirusScene.scn", withName: "virus\(i)"))
        }
        virusNodes[0].position = SCNVector3(0.7, POSITION_Y + 1.7, POSITION_Z + 0.7)
        portal.addChildNode(virusNodes[0])

        virusNodes[1].position = SCNVector3(0, POSITION_Y + 1.5, POSITION_Z + 0.9)
        portal.addChildNode(virusNodes[1])
        
        virusNodes[2].position = SCNVector3(-0.7, POSITION_Y + 1.7, POSITION_Z + 0.7)
        portal.addChildNode(virusNodes[2])
        
        virusNodes[3].position = SCNVector3(0, POSITION_Y + 0.5, POSITION_Z)
        portal.addChildNode(virusNodes[3])
        
        let floorNode = makeFloorNode()
        floorNode.position = SCNVector3(0, POSITION_Y, POSITION_Z)
        portal.addChildNode(floorNode)
        
        let ceilingNode = makeCeilingNode()
        ceilingNode.position = SCNVector3(0, POSITION_Y + WALL_HEIGHT, POSITION_Z)
        portal.addChildNode(ceilingNode)
        
        let farWallNode = makeWallNode()
        farWallNode.eulerAngles = SCNVector3(0, 90.0.degreesToRadians, 0)
        farWallNode.position = SCNVector3(0, POSITION_Y + WALL_HEIGHT * 0.5, POSITION_Z - SURFACE_LENGTH * 0.5)
        portal.addChildNode(farWallNode)
        
        let rightSideWallNode = makeWallNode(maskLowerSide: true)
        rightSideWallNode.eulerAngles = SCNVector3(0, 180.0.degreesToRadians, 0)
        rightSideWallNode.position = SCNVector3(WALL_LENGTH * 0.5, POSITION_Y + WALL_HEIGHT * 0.5, POSITION_Z)
        portal.addChildNode(rightSideWallNode)
        
        let leftSideWallNode = makeWallNode(maskLowerSide: true)
        leftSideWallNode.position = SCNVector3(-WALL_LENGTH * 0.5, POSITION_Y + WALL_HEIGHT * 0.5, POSITION_Z)
        portal.addChildNode(leftSideWallNode)
        
        addDoorway(node: portal)
        placeLightSource(rootNode: portal)
        return portal
    }
    
    func addDoorway(node: SCNNode) {
        let halfWallLength: CGFloat = WALL_LENGTH * 0.5
        let frontHalfWallLength: CGFloat = (WALL_LENGTH - DOOR_WIDTH) * 0.5
        
        let rightDoorSideNode = makeWallNode(length: frontHalfWallLength)
        rightDoorSideNode.eulerAngles = SCNVector3(0, 270.0.degreesToRadians, 0)
        rightDoorSideNode.position = SCNVector3(halfWallLength - 0.5 * DOOR_WIDTH, POSITION_Y + WALL_HEIGHT * 0.5, POSITION_Z + SURFACE_LENGTH * 0.5)
        node.addChildNode(rightDoorSideNode)
        
        let leftDoorSideNode = makeWallNode(length: frontHalfWallLength)
        leftDoorSideNode.eulerAngles = SCNVector3(0, 270.0.degreesToRadians, 0)
        leftDoorSideNode.position = SCNVector3(-halfWallLength + 0.5 * frontHalfWallLength, POSITION_Y + WALL_HEIGHT * 0.5, POSITION_Z + SURFACE_LENGTH * 0.5)
        node.addChildNode(leftDoorSideNode)
        
        let aboveDoorNode = makeWallNode(length: DOOR_WIDTH, height: WALL_HEIGHT - DOOR_HEIGHT)
        aboveDoorNode.eulerAngles = SCNVector3(0, 270.0.degreesToRadians, 0)
        aboveDoorNode.position = SCNVector3(0, POSITION_Y + (WALL_HEIGHT - DOOR_HEIGHT) * 0.5 + DOOR_HEIGHT, POSITION_Z + SURFACE_LENGTH * 0.5)
        node.addChildNode(aboveDoorNode)
    }
    
    func placeLightSource(rootNode: SCNNode) {
        let light = SCNLight()
        light.intensity = 10
        light.type = .omni
        let lightNode = SCNNode()
        lightNode.light = light
        lightNode.position = SCNVector3(0, POSITION_Y + WALL_HEIGHT, POSITION_Z)
        rootNode.addChildNode(lightNode)
    }
}

extension PortalViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        DispatchQueue.main.async {
            if let planeAnchor = anchor as? ARPlaneAnchor, self.appState == .detectSurface {
                #if DEBUG
                let debugPlaneNode = createPlaneNode(center: planeAnchor.center, extent: planeAnchor.extent)
                node.addChildNode(debugPlaneNode)
                self.debugPlanes.append(debugPlaneNode)
                #endif
                self.messageLabel?.alpha = 1.0
                self.messageLabel?.text = "Tap on the detected horizontal plane to place the room"
            } else if self.appState == .detectSurface {   // this must be the anchor you add when the user taps on the screen to place the portal.
                self.portalNode = self.makePortal()
                if let portal = self.portalNode {
                    node.addChildNode(portal)
                    self.appState = .swipeToPlay
                    
                    self.removeDebugPlanes()
                    self.sceneView?.debugOptions = []
                    
                    DispatchQueue.main.async {
                        self.messageLabel?.text = ""
                        self.messageLabel?.alpha = 0
                    }
                }
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        DispatchQueue.main.async {
            if let planeAnchor = anchor as? ARPlaneAnchor, node.childNodes.count > 0, self.appState == .detectSurface {
                updatePlaneNode(node.childNodes[0], center: planeAnchor.center, extent: planeAnchor.extent)
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if (self.appState != .detectSurface) {
            self.focusNode.isHidden = false
            return
        }
        DispatchQueue.main.async {
            self.updateFocusNode()
            if let _ = self.sceneView.hitTest(self.focusPoint, types: [.existingPlaneUsingExtent]).first {
                self.focusNode.isHidden = false
            } else {
                self.focusNode.isHidden = true
            }
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        guard let label = sessionStateLabel else { return }
        showMessage(error.localizedDescription, label: label, seconds: 3)
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        guard let label = sessionStateLabel else { return }
        showMessage("Session interrupted", label: label, seconds: 3)
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        guard let label = sessionStateLabel else { return }
        showMessage("Session resumed", label: label, seconds: 3)
        
        DispatchQueue.main.async {
            self.removeAllNodes()
            self.resetLabels()
        }
        initSceneView()
        initScene()
        initARSession()
    }
}
