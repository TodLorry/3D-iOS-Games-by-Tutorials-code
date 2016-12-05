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

enum ColliderType: Int {
  case Ball = 0b1
  case Barrier = 0b10
  case Brick = 0b100
  case Paddle = 0b1000
}

class GameViewController: UIViewController {
  
  var scnView: SCNView!
  var scnScene: SCNScene!
  var game = GameHelper.sharedInstance
  var horizontalCameraNode: SCNNode!
  var verticalCameraNode: SCNNode!
  var ballNode: SCNNode!
  var paddleNode: SCNNode!
  var lastContactNode: SCNNode!
  var touchX: CGFloat = 0
  var paddleX: Float = 0
  var floorNode: SCNNode!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupScene()
    setupNodes()
    setupSounds()
  }
  
  func setupScene() {
    scnView = self.view as! SCNView
    scnView.delegate = self
    
    scnScene = SCNScene(named: "Breaker.scnassets/Scenes/Game.scn")
    scnView.scene = scnScene
    
    scnScene.physicsWorld.contactDelegate = self
  }
  
  func setupNodes() {
    horizontalCameraNode = scnScene.rootNode.childNodeWithName("HorizontalCamera", recursively: true)!
    verticalCameraNode = scnScene.rootNode.childNodeWithName("VerticalCamera", recursively: true)!
    
    scnScene.rootNode.addChildNode(game.hudNode)
    
    ballNode = scnScene.rootNode.childNodeWithName("Ball", recursively: true)!
    
    paddleNode = scnScene.rootNode.childNodeWithName("Paddle", recursively: true)!
    
    ballNode.physicsBody?.contactTestBitMask = ColliderType.Barrier.rawValue |
      ColliderType.Brick.rawValue | ColliderType.Paddle.rawValue
    
    floorNode = scnScene.rootNode.childNodeWithName("Floor", recursively: true)!
    verticalCameraNode.constraints = [SCNLookAtConstraint(target: floorNode)]
    horizontalCameraNode.constraints = [SCNLookAtConstraint(target: floorNode)]
  }
  
  func setupSounds() {
  }
  
  override func shouldAutorotate() -> Bool {
    return true
  }
  
  override func prefersStatusBarHidden() -> Bool {
    return true
  }
  
  // 1
  override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
    // 2
    let deviceOrientation = UIDevice.currentDevice().orientation
    switch(deviceOrientation) {
    case .Portrait:
      scnView.pointOfView = verticalCameraNode
    default:
      scnView.pointOfView = horizontalCameraNode
    }
  }
  
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    for touch in touches {
      let location = touch.locationInView(scnView)
      touchX = location.x
      paddleX = paddleNode.position.x
    }
  }
  
  override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
    for touch in touches {
      // 1
      let location = touch.locationInView(scnView)
      paddleNode.position.x = paddleX + (Float(location.x - touchX) * 0.1)
      
      // 2
      if paddleNode.position.x > 4.5 {
        paddleNode.position.x = 4.5
      } else if paddleNode.position.x < -4.5 {
        paddleNode.position.x = -4.5
      }
    }
    
    verticalCameraNode.position.x = paddleNode.position.x
    horizontalCameraNode.position.x = paddleNode.position.x
  }
}

extension GameViewController: SCNSceneRendererDelegate {
  func renderer(renderer: SCNSceneRenderer, updateAtTime time: NSTimeInterval) {
    game.updateHUD()
  }
}

// 1
extension GameViewController: SCNPhysicsContactDelegate {
  // 2
  func physicsWorld(world: SCNPhysicsWorld, didBeginContact contact: SCNPhysicsContact) {
    // 3
    var contactNode: SCNNode!
    if contact.nodeA.name == "Ball" {
      contactNode = contact.nodeB
    } else {
      contactNode = contact.nodeA
    }
    // 4
    if lastContactNode != nil && lastContactNode == contactNode {
        return
    }
    lastContactNode = contactNode
    
    // 1
    if contactNode.physicsBody?.categoryBitMask == ColliderType.Barrier.rawValue {
      if contactNode.name == "Bottom" {
        game.lives -= 1
        if game.lives == 0 {
          game.saveState()
          game.reset()
        }
      }
    }
    // 2
    if contactNode.physicsBody?.categoryBitMask == ColliderType.Brick.rawValue {
      game.score += 1
      contactNode.hidden = true
      contactNode.runAction(
        SCNAction.waitForDurationThenRunBlock(120) { (node:SCNNode!) -> Void in
          node.hidden = false
        })
    }
    // 3
    if contactNode.physicsBody?.categoryBitMask == ColliderType.Paddle.rawValue {
      if contactNode.name == "Left" {
        ballNode.physicsBody!.velocity.xzAngle -= (convertToRadians(20))
      }
      if contactNode.name == "Right" {
        ballNode.physicsBody!.velocity.xzAngle += (convertToRadians(20))
      }
    }
    // 4
    ballNode.physicsBody?.velocity.length = 5.0
  }
}
