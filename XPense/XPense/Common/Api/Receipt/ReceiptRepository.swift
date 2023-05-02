//
//  ReceiptRepository.swift
//  XPense
//
//  Created by Timothy Alexander on 4/12/23.
//

import Foundation

class ReceiptRepository {
  private let _authStore: AuthStore
  private let _endpoint: URL
  
  init(authStore: AuthStore, baseUrl: String) {
    self._authStore = authStore
    self._endpoint = URL(string: baseUrl)!.appendingPathComponent("receipts")
  }
  
  public func parseReceipt(document: String) async throws -> ReceiptEntity {
    let token = try await _authStore.getIdToken();
    
    var request = URLRequest(url: _endpoint.appendingPathComponent("parse"))
    
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("application/json", forHTTPHeaderField: "Accept")
    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    request.httpBody = try JSONSerialization.data(withJSONObject: ["context": document])
    
    let (data, _) = try await URLSession.shared.data(for: request)
    let resp = try JSONDecoder().decode(ParseReceiptResponse.self, from: data)
    
    return resp.document
  }
}
