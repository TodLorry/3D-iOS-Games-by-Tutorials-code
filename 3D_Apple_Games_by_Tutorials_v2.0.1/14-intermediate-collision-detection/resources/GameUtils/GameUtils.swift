//
//  GameUtils.swift
//
//  Created by Chris Language on 9/1/15.
//  Copyright (c) 2015 Razeware LLC. All rights reserved.
//

import Foundation
import CoreGraphics

let DegreesPerRadians = Float(M_PI/180)
let RadiansPerDegrees = Float(180/M_PI)

func convertToRadians(angle:Float) -> Float {
  return angle * DegreesPerRadians
}

func convertToRadians(angle:CGFloat) -> CGFloat {
  return CGFloat(CGFloat(angle) * CGFloat(DegreesPerRadians))
}

/// Convert Radians to Degrees
func convertToDegrees(angle:Float) -> Float {
  return angle * RadiansPerDegrees
}

func convertToDegrees(angle:CGFloat) -> CGFloat {
  return CGFloat(CGFloat(angle) * CGFloat(RadiansPerDegrees))
}