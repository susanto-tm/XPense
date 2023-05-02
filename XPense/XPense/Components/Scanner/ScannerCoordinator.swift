//
//  ScannerCoordinator.swift
//  XPense
//
//  Created by Timothy Alexander on 4/7/23.
//

import Foundation
import VisionKit
import Vision

class ScannerCoordinator : NSObject, VNDocumentCameraViewControllerDelegate {
  var parent: Scanner
  var store: ScannerStore
  
  init(_ parent: Scanner, store: ScannerStore) {
    self.parent = parent
    self.store = store
  }
  
  func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
    self.parent.onDismiss()
  }
  
  func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
    for i in 0..<scan.pageCount {
      let image = scan.imageOfPage(at: i)
      if let cgImage = image.cgImage {
        store.processReceipt(cgImage: cgImage)
      }
    }
    parent.onSubmit()
  }
  func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
    print(error.localizedDescription)
  }
}
