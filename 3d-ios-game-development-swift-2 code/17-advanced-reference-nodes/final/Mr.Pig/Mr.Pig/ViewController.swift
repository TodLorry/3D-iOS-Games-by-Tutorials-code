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
  }
  
  func setupTraffic() {
  }
  
  func setupGestures() {
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