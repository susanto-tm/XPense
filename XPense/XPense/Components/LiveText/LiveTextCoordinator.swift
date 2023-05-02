//
//  LiveTextCoordinator.swift
//  XPense
//
//  Created by Timothy Alexander on 4/18/23.
//

import Foundation
import VisionKit

class LiveTextCoordinator: NSObject, ImageAnalysisInteractionDelegate {
  var parent: LiveTextOverlay
  
  init(_ parent: LiveTextOverlay) {
    self.parent = parent
  }
}
