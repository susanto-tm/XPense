//
//  ReceiptEntity.swift
//  XPense
//
//  Created by Timothy Alexander on 4/12/23.
//

import Foundation

struct ReceiptItem: Identifiable, Decodable {
  var id = UUID()
  var name: String
  var quantity: Double
  var price: Double
  
  enum CodingKeys: CodingKey {
    case name
    case quantity
    case price
  }
  
  init(name: String, quantity: Double, price: Double) {
    self.name = name
    self.quantity = quantity
    self.price = price
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.name = try container.decode(String.self, forKey: .name)
    self.quantity = try container.decodeIfPresent(Double.self, forKey: .quantity) ?? 1
    self.price = try container.decode(Double.self, forKey: .price)
  }
  
}

struct ReceiptEntity: Decodable {
  var name: String
  var category: String
  var total: Double
  var items: [ReceiptItem]
  
  enum CodingKeys: CodingKey {
    case name
    case category
    case total
    case items
  }
  
  init(name: String, category: String, total: Double, items: [ReceiptItem]) {
    self.name = name
    self.category = category
    self.total = total
    self.items = items
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
    self.category = try container.decodeIfPresent(String.self, forKey: .category) ?? ""
    self.items = try container.decodeIfPresent([ReceiptItem].self, forKey: .items) ?? []
    self.total = try container.decodeIfPresent(Double.self, forKey: .total) ?? 0
  }
}

struct ParseReceiptResponse: Decodable {
  var document: ReceiptEntity
  
  enum CodingKeys: CodingKey {
    case document
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.document = try container.decodeIfPresent(ReceiptEntity.self, forKey: .document) ??
      ReceiptEntity(name: "", category: "", total: 0, items: [])
  }
}
