//
//  ScannerStore.swift
//  XPense
//
//  Created by Timothy Alexander on 4/13/23.
//

import Foundation
import Vision
import CoreGraphics

class ScannerStore: ObservableObject {
  @Published() var receipts: [CGImage] = []
  @Published() var matchedReceiptBBox: [[(CGRect, String)]] = []
  @Published() var matchedReceiptText: [String] = []
  @Published() var matchedParsedReceipt: [ReceiptEntity] = []
  
  // States for managing interaction with image through LiveText
  @Published() var shouldShowEditForm: Bool = true
  @Published() var isInteractive: Bool = false {
    didSet {
      shouldShowEditForm = !isInteractive
    }
  }
  
  private let _receiptRepo: ReceiptRepository
  
  init(receiptRepo: ReceiptRepository) {
    self._receiptRepo = receiptRepo
  }
  
  func toggleInteractive(isInteractive: Bool? = nil) {
    if isInteractive == nil {
      self.isInteractive.toggle()
    } else {
      self.isInteractive = isInteractive!
    }
  }
  
  private func extractBoundingBox(
    for image: CGImage,
    using observations: [VNRecognizedTextObservation]
  ) {
    let boundingRects: [(CGRect, String)] = observations.compactMap { observation in
      guard let candidate = observation.topCandidates(1).first else { return (.zero, "") }
      
      let stringRange = candidate.string.startIndex..<candidate.string.endIndex
      let boxObservation = try? candidate.boundingBox(for: stringRange)
      
      let boundingBox = boxObservation?.boundingBox ?? .zero
      
      return (VNImageRectForNormalizedRect(boundingBox, Int(image.width), Int(image.height)), candidate.string)
    }
    
    matchedReceiptBBox.append(boundingRects.filter { $0.0 != .zero || $0.1 != "" })
  }
  
  private func recognizeTextHandler(image: CGImage, request: VNRequest, error: Error?) {
    guard let observations = request.results as? [VNRecognizedTextObservation] else {
      return
    }
    
    let recognizedStrings = observations.compactMap { observation in
      observation.topCandidates(1).first?.string
    }
    
    matchedReceiptText.append(recognizedStrings.joined(separator: " "))
    
    extractBoundingBox(for: image, using: observations)
  }
  
  private func recognizeTextCompletionHandler(image: CGImage) -> (VNRequest, Error?) -> Void {
    return { request, error in self.recognizeTextHandler(image: image, request: request, error: error) }
  }
  
  private func recognizeReceiptText(for image: CGImage) {
    let requestHandler = VNImageRequestHandler(cgImage: image)
    let request = VNRecognizeTextRequest(completionHandler: recognizeTextCompletionHandler(image: image))
    
    do {
      try requestHandler.perform([request])
    } catch {
      print(error.localizedDescription)
    }
  }
  
  func processReceipt(cgImage image: CGImage) {
    receipts.append(image)
    recognizeReceiptText(for: image)
  }
  
  func parseReceipts() async throws {
    matchedParsedReceipt = try await withThrowingTaskGroup(of: ReceiptEntity.self) { group in
      for text in matchedReceiptText {
        group.addTask {
          return try await self._receiptRepo.parseReceipt(document: text)
        }
      }
      
      var receipts = [ReceiptEntity]()
      
      for try await text in group {
        receipts.append(text)
      }
      
      return receipts
    }
  }
}
