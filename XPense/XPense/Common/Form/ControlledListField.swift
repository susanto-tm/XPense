//
//  ControlledListField.swift
//  XPense
//
//  Created by Timothy Alexander on 4/15/23.
//

import Foundation
import SwiftUI

struct ControlledListField<T, Content>: View where T : Identifiable, Content : View {
  @Environment(\.fieldValues) private var fieldValues
  
  var name: String
  let content: (T, Int) -> Content
 
  var items: Array<T> {
    print(fieldValues[name]!)
    return Array((fieldValues[name]! as! FormListField<T>).value)
  }
  
  init(name: String, @ViewBuilder content: @escaping (T, Int) -> Content) {
    self.name = name
    self.content = content
  }
  
  var body: some View {
    ForEach(0..<items.count, id: \.self) { index in
      content(items[index], index)
    }
  }
}
