/**
 * Copyright (c) 2019 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
 * distribute, sublicense, create a derivative work, and/or sell copies of the
 * Software in any work that is designed, intended, or marketed for pedagogical or
 * instructional purposes related to programming, coding, application development,
 * or information technology.  Permission for such use, copying, modification,
 * merger, publication, distribution, sublicensing, creation of derivative works,
 * or sale is expressly withheld.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import SceneKit

let SURFACE_LENGTH: CGFloat = 3.0
let SURFACE_HEIGHT: CGFloat = 0.1
let SURFACE_WIDTH: CGFloat = 3.0

let SCALEX: Float = 2.0
let SCALEY: Float = 2.0

let WALL_WIDTH:CGFloat = 0.1
let WALL_HEIGHT:CGFloat = 3.0
let WALL_LENGTH:CGFloat = 3.0


func createPlaneNode(center: vector_float3,
                     extent: vector_float3) -> SCNNode {
    
    let plane = SCNPlane(width: CGFloat(extent.x), height: CGFloat(extent.z))
    
    let planeMaterial = SCNMaterial()
    planeMaterial.diffuse.contents = UIColor.yellow.withAlphaComponent(0.4)
    plane.materials = [planeMaterial]
    
    let planeNode = SCNNode(geometry: plane)
    planeNode.position = SCNVector3Make(center.x, 0, center.z)
    planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2, 1, 0, 0)
    
    return planeNode
}

func updatePlaneNode(_ node: SCNNode,
                     center: vector_float3,
                     extent: vector_float3) {
    
    let geometry = node.geometry as? SCNPlane
    geometry?.width = CGFloat(extent.x)
    geometry?.height = CGFloat(extent.z)
    
    node.position = SCNVector3Make(center.x, 0, center.z)
}

func repeatTextures(geometry: SCNGeometry, scaleX: Float, scaleY: Float) {
    geometry.firstMaterial?.diffuse.wrapS = SCNWrapMode.repeat
    geometry.firstMaterial?.selfIllumination.wrapS = SCNWrapMode.repeat
    geometry.firstMaterial?.normal.wrapS = SCNWrapMode.repeat
    geometry.firstMaterial?.specular.wrapS = SCNWrapMode.repeat
    geometry.firstMaterial?.emission.wrapS = SCNWrapMode.repeat
    geometry.firstMaterial?.roughness.wrapS = SCNWrapMode.repeat
    
    geometry.firstMaterial?.diffuse.wrapT = SCNWrapMode.repeat
    geometry.firstMaterial?.selfIllumination.wrapT = SCNWrapMode.repeat
    geometry.firstMaterial?.normal.wrapT = SCNWrapMode.repeat
    geometry.firstMaterial?.specular.wrapT = SCNWrapMode.repeat
    geometry.firstMaterial?.emission.wrapT = SCNWrapMode.repeat
    geometry.firstMaterial?.roughness.wrapT = SCNWrapMode.repeat
    
    geometry.firstMaterial?.diffuse.contentsTransform =
        SCNMatrix4MakeScale(scaleX, scaleY, 0)
    geometry.firstMaterial?.selfIllumination.contentsTransform =
        SCNMatrix4MakeScale(scaleX, scaleY, 0)
    geometry.firstMaterial?.normal.contentsTransform =
        SCNMatrix4MakeScale(scaleX, scaleY, 0)
    geometry.firstMaterial?.specular.contentsTransform =
        SCNMatrix4MakeScale(scaleX, scaleY, 0)
    geometry.firstMaterial?.emission.contentsTransform =
        SCNMatrix4MakeScale(scaleX, scaleY, 0)
    geometry.firstMaterial?.roughness.contentsTransform =
        SCNMatrix4MakeScale(scaleX, scaleY, 0)
}

func makeOuterSurfaceNode(width: CGFloat,
                          height: CGFloat,
                          length: CGFloat) -> SCNNode {
    let outerSurface = SCNBox(width: SURFACE_WIDTH,
                              height: SURFACE_HEIGHT,
                              length: SURFACE_LENGTH,
                              chamferRadius: 0)
    outerSurface.firstMaterial?.diffuse.contents = UIColor.white
    outerSurface.firstMaterial?.transparency = 0.8
    let outerSurfaceNode = SCNNode(geometry: outerSurface)
    outerSurfaceNode.renderingOrder = 10
    return outerSurfaceNode
}

func makeFloorNode() -> SCNNode {
    let outerFloorNode = makeOuterSurfaceNode(width: SURFACE_WIDTH,
                                              height: SURFACE_HEIGHT,
                                              length: SURFACE_LENGTH)
    outerFloorNode.position = SCNVector3(SURFACE_HEIGHT * 0.5,
                                         -SURFACE_HEIGHT, 0)
    let floorNode = SCNNode()
    floorNode.addChildNode(outerFloorNode)
    
    let innerFloor = SCNBox(width: SURFACE_WIDTH,
                            height: SURFACE_HEIGHT,
                            length: SURFACE_LENGTH,
                            chamferRadius: 0)
    
    innerFloor.firstMaterial?.lightingModel = .physicallyBased
    innerFloor.firstMaterial?.diffuse.contents =
        UIImage(named: "Assets.scnassets/floor/textures/Floor_Diffuse.png")
    innerFloor.firstMaterial?.normal.contents =
        UIImage(named: "Assets.scnassets/floor/textures/Floor_Normal.png")
    innerFloor.firstMaterial?.roughness.contents =
        UIImage(named: "Assets.scnassets/floor/textures/Floor_Roughness.png")
    innerFloor.firstMaterial?.specular.contents =
        UIImage(named: "Assets.scnassets/floor/textures/Floor_Specular.png")
    innerFloor.firstMaterial?.selfIllumination.contents =
        UIImage(named: "Assets.scnassets/floor/textures/Floor_Gloss.png")
    repeatTextures(geometry: innerFloor, scaleX: SCALEX, scaleY: SCALEY)
    
    let innerFloorNode = SCNNode(geometry: innerFloor)
    innerFloorNode.renderingOrder = 100
    innerFloorNode.position = SCNVector3(SURFACE_HEIGHT * 0.5, 0, 0)
    floorNode.addChildNode(innerFloorNode)
    return floorNode
}

func makeCeilingNode() -> SCNNode {
    let outerCeilingNode = makeOuterSurfaceNode(width: SURFACE_WIDTH,
                                                height: SURFACE_HEIGHT,
                                                length: SURFACE_LENGTH)
    outerCeilingNode.position = SCNVector3(SURFACE_HEIGHT * 0.5,
                                           SURFACE_HEIGHT, 0)
    let ceilingNode = SCNNode()
    ceilingNode.addChildNode(outerCeilingNode)
    
    let innerCeiling = SCNBox(width: SURFACE_WIDTH,
                              height: SURFACE_HEIGHT,
                              length: SURFACE_LENGTH,
                              chamferRadius: 0)
    innerCeiling.firstMaterial?.lightingModel = .physicallyBased
    innerCeiling.firstMaterial?.diffuse.contents =
        UIImage(named: "Assets.scnassets/ceiling/textures/Ceiling_Diffuse.png")
    innerCeiling.firstMaterial?.emission.contents =
        UIImage(named: "Assets.scnassets/ceiling/textures/Ceiling_Emis.png")
    innerCeiling.firstMaterial?.normal.contents =
        UIImage(named: "Assets.scnassets/ceiling/textures/Ceiling_Normal.png")
    innerCeiling.firstMaterial?.specular.contents =
        UIImage(named: "Assets.scnassets/ceiling/textures/Ceiling_Specular.png")
    innerCeiling.firstMaterial?.selfIllumination.contents =
        UIImage(named: "Assets.scnassets/ceiling/textures/Ceiling_Gloss.png")
    
    repeatTextures(geometry: innerCeiling, scaleX: SCALEX, scaleY: SCALEY)
    
    let innerCeilingNode = SCNNode(geometry: innerCeiling)
    innerCeilingNode.renderingOrder = 100
    innerCeilingNode.position = SCNVector3(SURFACE_HEIGHT * 0.5, 0, 0)
    ceilingNode.addChildNode(innerCeilingNode)
    
    return ceilingNode
}


func makeWallNode(length: CGFloat = WALL_LENGTH,
                  height: CGFloat = WALL_HEIGHT,
                  maskLowerSide:Bool = false) -> SCNNode {
    let outerWall = SCNBox(width: WALL_WIDTH,
                           height: height,
                           length: length,
                           chamferRadius: 0)
    outerWall.firstMaterial?.diffuse.contents = UIColor.white
    outerWall.firstMaterial?.transparency = 0.8
    let outerWallNode = SCNNode(geometry: outerWall)
    let multiplier: CGFloat = maskLowerSide ? -1 : 1
    outerWallNode.position = SCNVector3(WALL_WIDTH*multiplier,0,0)
    outerWallNode.renderingOrder = 10
    let wallNode = SCNNode()
    wallNode.addChildNode(outerWallNode)
    
    let innerWall = SCNBox(width: WALL_WIDTH,
                           height: height,
                           length: length,
                           chamferRadius: 0)
    innerWall.firstMaterial?.lightingModel = .physicallyBased
    innerWall.firstMaterial?.diffuse.contents =
        UIImage(named: "Assets.scnassets/wall/textures/Walls_Diffuse.png")
    innerWall.firstMaterial?.metalness.contents =
        UIImage(named: "Assets.scnassets/wall/textures/Walls_Metalness.png")
    innerWall.firstMaterial?.roughness.contents =
        UIImage(named: "Assets.scnassets/wall/textures/Walls_Roughness.png")
    innerWall.firstMaterial?.normal.contents =
        UIImage(named: "Assets.scnassets/wall/textures/Walls_Normal.png")
    //    innerWall.firstMaterial?.specular.contents =
    //        UIImage(named: "Assets.scnassets/wall/textures/Walls_Spec.png")
    //    innerWall.firstMaterial?.selfIllumination.contents =
    //        UIImage(named: "Assets.scnassets/wall/textures/Walls_Gloss.png")
    
    let innerWallNode = SCNNode(geometry: innerWall)
    innerWallNode.renderingOrder = 100
    wallNode.addChildNode(innerWallNode)
    
    return wallNode
}
