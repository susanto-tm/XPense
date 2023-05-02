//
//  Lottie.swift
//  XPense
//
//  Created by Timothy Alexander on 4/4/23.
//

import Foundation
import SwiftUI
import UIKit
import Lottie

struct Lottie: UIViewRepresentable {
  let animation: String
  let loopMode: LottieLoopMode
  
  init(_ animation: String) {
    self.animation = animation
    self.loopMode = .loop
  }
  
  init(_ animation: String, loopMode: LottieLoopMode) {
    self.animation = animation
    self.loopMode = loopMode
  }
  
  func makeUIView(context: Context) -> some UIView {
    let view = UIView(frame: .zero)
    
    let animationView = LottieAnimationView(name: animation)
    animationView.contentMode = .center
    animationView.loopMode = loopMode
    animationView.translatesAutoresizingMaskIntoConstraints = false
    animationView.play()
    
    view.addSubview(animationView)
    NSLayoutConstraint.activate([
      animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
      animationView.widthAnchor.constraint(equalTo: view.widthAnchor)
    ])
    
    return view
  }
  
  func updateUIView(_ uiView: UIViewType, context: Context) {
  }
}
