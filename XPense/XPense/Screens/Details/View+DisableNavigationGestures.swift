//
//  View+DisableNavigationGestures.swift
//  XPense
//
//  Created by Timothy Alexander on 4/28/23.
//

import Foundation
import UIKit
import SwiftUI

extension View {
  func disableNavigationGestures() -> some View {
    self.background {
      DisableNavigationGestures()
    }
  }
}

struct DisableNavigationGestures: UIViewControllerRepresentable {
  typealias UIViewControllerType = DisableNavigationGesturesController
  
  func makeUIViewController(context: Context) -> UIViewControllerType {
    UIViewControllerType()
  }
  
  func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    
  }
}

class DisableNavigationGesturesController: UIViewController {
  override func didMove(toParent parent: UIViewController?) {
    super.didMove(toParent: parent)
    if let parent = parent?.parent,
       let navigationController = parent.navigationController,
       let interactivePopGestureRecognizer = navigationController.interactivePopGestureRecognizer {
      navigationController.view.removeGestureRecognizer(interactivePopGestureRecognizer)
    }
  }
}
