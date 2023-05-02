//
//  LiveTextOverlay.swift
//  XPense
//
//  Created by Timothy Alexander on 4/18/23.
//

import Foundation
import SwiftUI
import VisionKit
import Vision

struct LiveTextOverlay: UIViewRepresentable {
  var image: UIImage
  
  let analyzer = ImageAnalyzer()
  
  func makeUIView(context: Context) -> UIImageView {
    let imageView = UIImageView()
    imageView.image = image
    imageView.contentMode = .scaleAspectFit
    
    imageView.setContentHuggingPriority(.defaultLow, for: .vertical)
    imageView.setContentHuggingPriority(.defaultLow, for: .horizontal)
    imageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
    imageView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    
    let interaction = ImageAnalysisInteraction()
    interaction.preferredInteractionTypes = .textSelection
    interaction.delegate = context.coordinator
    
    imageView.addInteraction(interaction)
   
    return imageView
  }
  
  func updateUIView(_ uiView: UIImageView, context: Context) {
    if !uiView.interactions.isEmpty && uiView.interactions.first != nil && uiView.interactions.first! is ImageAnalysisInteraction {
      let interaction = uiView.interactions.first! as! ImageAnalysisInteraction
      
      Task {
        let configuration = ImageAnalyzer.Configuration([.text])
        do {
          if let image = uiView.image {
            let analysis = try await analyzer.analyze(image, configuration: configuration)
            
            DispatchQueue.main.async {
              interaction.analysis = nil
              interaction.preferredInteractionTypes = []
              
              interaction.analysis = analysis
              interaction.preferredInteractionTypes = .automatic
            }
          }
        } catch {
          print(error.localizedDescription)
        }
      }
    }
  }
  
  func makeCoordinator() -> LiveTextCoordinator {
    LiveTextCoordinator(self)
  }
}
