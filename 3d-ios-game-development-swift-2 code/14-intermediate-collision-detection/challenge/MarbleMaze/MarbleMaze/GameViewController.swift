  /*
  * Copyright (c) 2015 Razeware LLC
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
  * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
  * THE SOFTWARE.
  */
  
import UIKit
import SceneKit

class GameViewController: UIViewController {
  
  // Bit Masks
  let CollisionCategoryBall = 1
  let CollisionCategoryStone = 2
  let CollisionCategoryPillar = 4
  let CollisionCategoryCrate = 8
  let CollisionCategoryPearl = 16
  
  // Scene
  var scnView:SCNView!
  var scnScene:SCNScene!
  
  // Nodes
  var ballNode:SCNNode!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupScene()
    setupNodes()
    setupSounds()
  }
  
  func setupScene() {
    scnView = self.view as! SCNView
    scnView.delegate = self
    scnView.allowsCameraControl = true
    scnView.showsStatistics = true
    scnScene = SCNScene(named: "art.scnassets/game.scn")
    scnScene.physicsWorld.contactDelegate = self
    scnView.scene = scnScene
  }
  
  func setupNodes() {
    
    // Setup Ball Node
    ballNode = scnScene.rootNode.childNodeWithName("ball", recursively: true)!
    ballNode.physicsBody?.contactTestBitMask = CollisionCategoryPillar |
      CollisionCategoryCrate | CollisionCategoryPearl
  }
  
  func setupSounds() {
  }
  
  override func shouldAutorotate() -> Bool {
    return false
  }
  
  override func prefersStatusBarHidden() -> Bool {
    return true
  }
}

extension GameViewController: SCNSceneRendererDelegate {
  func renderer(renderer: SCNSceneRenderer, updateAtTime time: NSTimeInterval) {
  }
}

extension GameViewController : SCNPhysicsContactDelegate {
  func physicsWorld(world: SCNPhysicsWorld, didBeginContact contact: SCNPhysicsContact) {
    
    // Set Contact Node
    var contactNode:SCNNode!
    if contact.nodeA.name == "ball" {
      contactNode = contact.nodeB
    } else {
      contactNode = contact.nodeA
    }
    
    // Contact with Pearls
    if contactNode.physicsBody?.categoryBitMask == CollisionCategoryPearl {
      contactNode.hidden = true
      contactNode.runAction(SCNAction.waitForDurationThenRunBlock(30) { (node:SCNNode!) -> Void in
        node.hidden = false
        })
    }
    
    // Contact with Pillars & Crates go bump in the night
    if contactNode.physicsBody?.categoryBitMask == CollisionCategoryPillar ||
      contactNode.physicsBody?.categoryBitMask == CollisionCategoryCrate {
    }
  }
}