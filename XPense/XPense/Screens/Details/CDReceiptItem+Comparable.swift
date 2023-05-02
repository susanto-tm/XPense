//
//  CDReceiptItem+Equatable.swift
//  XPense
//
//  Created by Timothy Alexander on 4/28/23.
//

import Foundation

extension CDReceiptItem: Comparable {
  public static func < (lhs: CDReceiptItem, rhs: CDReceiptItem) -> Bool {
    lhs.price > rhs.price
  }
}
