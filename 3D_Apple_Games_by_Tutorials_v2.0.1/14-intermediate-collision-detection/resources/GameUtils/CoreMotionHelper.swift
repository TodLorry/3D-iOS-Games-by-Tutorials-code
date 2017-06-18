import Foundation
import CoreMotion

class CoreMotionHelper {
  
  let motionManager = CMMotionManager()
  
  init() {
  }
  
  func getAccelerometerData(interval: TimeInterval = 0.1, closure: ((x: Double, y: Double, z: Double) -> ())? ){
    
    if motionManager.isAccelerometerAvailable {
      
      motionManager.accelerometerUpdateInterval = interval
      
      motionManager.startAccelerometerUpdates(to: OperationQueue()) {
        (data: CMAccelerometerData?, error: NSError?) -> Void in
        
        if closure != nil{
          closure!(x: data!.acceleration.x,y: data!.acceleration.y,z: data!.acceleration.z)
        }
        
      }
    }
  }
}
