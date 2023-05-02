//
//  Scanner.swift
//  XPense
//
//  Created by Timothy Alexander on 4/7/23.
//

import Foundation
import SwiftUI
import VisionKit

struct Scanner: UIViewControllerRepresentable {
  @EnvironmentObject private var scannerStore: ScannerStore
  
  var onSubmit: () -> Void
  var onDismiss: () -> Void
  
  func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
    let vc = VNDocumentCameraViewController()
    
    vc.delegate = context.coordinator
    
    return vc
  }
  
  func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {
  }
  
  func makeCoordinator() -> ScannerCoordinator {
    ScannerCoordinator(self, store: scannerStore)
  }
}
