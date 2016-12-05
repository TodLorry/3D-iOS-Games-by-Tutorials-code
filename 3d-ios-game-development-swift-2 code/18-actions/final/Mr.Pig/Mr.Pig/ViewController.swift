/*
* Copyright (c) 2013-2016 Razeware LLC
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
import SpriteKit

class ViewController: UIViewController {

  let game = GameHelper.sharedInstance
  var scnView: SCNView!
  var gameScene: SCNScene!
  var splashScene: SCNScene!
  
  var pigNode: SCNNode!
  var cameraNode: SCNNode!
  var cameraFollowNode: SCNNode!
  var lightFollowNode: SCNNode!
  var trafficNode: SCNNode!
  
  var driveLeftAction: SCNAction!
  var driveRightAction: SCNAction!
  
  var jumpLeftAction: SCNAction!
  var jumpRightAction: SCNAction!
  var jumpForwardAction: SCNAction!
  var jumpBackwardAction: SCNAction!
  
  var triggerGameOver: SCNAction!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupScenes()
    setupNodes()
    setupActions()
    setupTraffic()
    setupGestures()
    setupSounds()
    game.state = .TapToPlay
  }
  
  func setupScenes() {
    scnView = SCNView(frame: self.view.frame)
    self.view.addSubview(scnView)
    
    gameScene = SCNScene(named: "/MrPig.scnassets/GameScene.scn")
    splashScene = SCNScene(named: "/MrPig.scnassets/SplashScene.scn")
    scnView.scene = splashScene
  }
  
  func setupNodes() {
    pigNode = gameScene.rootNode.childNodeWithName("MrPig", recursively: true)!
    cameraNode = gameScene.rootNode.childNodeWithName("camera", recursively: true)!
    cameraNode.addChildNode(game.hudNode)
    cameraFollowNode = gameScene.rootNode.childNodeWithName("FollowCamera", recursively: true)!
    lightFollowNode = gameScene.rootNode.childNodeWithName("FollowLight", recursively: true)!
    trafficNode = gameScene.rootNode.childNodeWithName("Traffic", recursively: true)!
  }
  
  func setupActions() {
    driveLeftAction = SCNAction.repeatActionForever(SCNAction.moveBy(SCNVector3Make(-2.0, 0, 0), duration: 1.0))
    driveRightAction = SCNAction.repeatActionForever(SCNAction.moveBy(SCNVector3Make(2.0, 0, 0), duration: 1.0))
    
    let duration = 0.2
    let bounceUpAction = SCNAction.moveByX(0, y: 1.0, z: 0, duration: duration * 0.5)
    let bounceDownAction = SCNAction.moveByX(0, y: -1.0, z: 0, duration: duration * 0.5)
    bounceUpAction.timingMode = .EaseOut
    bounceDownAction.timingMode = .EaseIn
    let bounceAction = SCNAction.sequence([bounceUpAction, bounceDownAction])
    let moveLeftAction = SCNAction.moveByX(-1.0, y: 0, z: 0, duration: duration)
    let moveRightAction = SCNAction.moveByX(1.0, y: 0, z: 0, duration: duration)
    let moveForwardAction = SCNAction.moveByX(0, y: 0, z: -1.0, duration: duration)
    let moveBackwardAction = SCNAction.moveByX(0, y: 0, z: 1.0, duration: duration)
    let turnLeftAction = SCNAction.rotateToX(0, y: convertToRadians(-90), z: 0, duration: duration, shortestUnitArc: true)
    let turnRightAction = SCNAction.rotateToX(0, y: convertToRadians(90), z: 0, duration: duration, shortestUnitArc: true)
    let turnForwardAction = SCNAction.rotateToX(0, y: convertToRadians(180), z: 0, duration: duration, shortestUnitArc: true)
    let turnBackwardAction = SCNAction.rotateToX(0, y: convertToRadians(0), z: 0, duration: duration, shortestUnitArc: true)
    jumpLeftAction = SCNAction.group([turnLeftAction, bounceAction, moveLeftAction])
    jumpRightAction = SCNAction.group([turnRightAction, bounceAction, moveRightAction])
    jumpForwardAction = SCNAction.group([turnForwardAction, bounceAction, moveForwardAction])
    jumpBackwardAction = SCNAction.group([turnBackwardAction, bounceAction, moveBackwardAction])
    
    let spinAround = SCNAction.rotateByX(0, y: convertToRadians(720), z: 0, duration: 2.0)
    let riseUp = SCNAction.moveByX(0, y: 10, z: 0, duration: 2.0)
    let fadeOut = SCNAction.fadeOpacityTo(0, duration: 2.0)
    let goodByePig = SCNAction.group([spinAround, riseUp, fadeOut])
    let gameOver = SCNAction.runBlock { (node:SCNNode) -> Void in
      self.pigNode.position = SCNVector3(x:0, y:0, z:0)
      self.pigNode.opacity = 1.0
      self.startSplash()
    }
    triggerGameOver = SCNAction.sequence([goodByePig, gameOver])
  }
  
  func setupTraffic() {
    for n in trafficNode.childNodes {
      if n.name?.containsString("Bus") == true {
        driveLeftAction.speed = 1.0
        driveRightAction.speed = 1.0
      } else {
        driveLeftAction.speed = 2.0
        driveRightAction.speed = 2.0
      }
      if n.eulerAngles.y > 0 {
        n.runAction(driveLeftAction)
      } else {
        n.runAction(driveRightAction)
      }
    }
  }
  
  func setupGestures() {
    let swipeRight:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.handleGesture(_:)))
    swipeRight.direction = .Right
    scnView.addGestureRecognizer(swipeRight)
    
    let swipeLeft:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.handleGesture(_:)))
    swipeLeft.direction = .Left
    scnView.addGestureRecognizer(swipeLeft)
    
    let swipeForward:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.handleGesture(_:)))
    swipeForward.direction = .Up
    scnView.addGestureRecognizer(swipeForward)
    
    let swipeBackward:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.handleGesture(_:)))
    swipeBackward.direction = .Down
    scnView.addGestureRecognizer(swipeBackward)
  }

  func handleGesture(sender:UISwipeGestureRecognizer){
    guard game.state == .Playing else {
      return
    }
    switch sender.direction {
    case UISwipeGestureRecognizerDirection.Up:
      pigNode.runAction(jumpForwardAction)
    case UISwipeGestureRecognizerDirection.Down:
      pigNode.runAction(jumpBackwardAction)
    case UISwipeGestureRecognizerDirection.Left:
      if pigNode.position.x >  -15 {
        pigNode.runAction(jumpLeftAction)
      }
    case UISwipeGestureRecognizerDirection.Right:
      if pigNode.position.x < 15 {
        pigNode.runAction(jumpRightAction)
      }
    default:
      break
    }
  }
  
  func setupSounds() {
  }
  
  func startSplash() {
    gameScene.paused = true
    let transition = SKTransition.doorsOpenVerticalWithDuration(1.0)
    scnView.presentScene(splashScene, withTransition: transition, incomingPointOfView: nil, completionHandler: {
      self.game.state = .TapToPlay
      self.setupSounds()
      self.splashScene.paused = false
    })
  }
  
  func startGame() {
    splashScene.paused = true
    let transition = SKTransition.doorsOpenVerticalWithDuration(1.0)
    scnView.presentScene(gameScene, withTransition: transition, incomingPointOfView: nil, completionHandler: {
      self.game.state = .Playing
      self.setupSounds()
      self.gameScene.paused = false
    })
  }
  
  func stopGame() {
    game.state = .GameOver
    game.reset()
    pigNode.runAction(triggerGameOver)
  }
  
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    if game.state == .TapToPlay {
      startGame()
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  override func prefersStatusBarHidden() -> Bool {
    return true
  }
  
  override func shouldAutorotate() -> Bool {
    return false
  }
}