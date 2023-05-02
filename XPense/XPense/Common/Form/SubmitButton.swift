//
//  SubmitButton.swift
//  XPense
//
//  Created by Timothy Alexander on 4/3/23.
//

import Foundation
import SwiftUI

struct SubmitButton<Label>: View where Label : View {
  var action: (FieldValues) -> Void
  var label: () -> Label
  
  @Environment(\.fieldValues) private var fieldValues
  
  init(action: @escaping (FieldValues) -> Void, @ViewBuilder label: @escaping () -> Label) {
    self.action = action
    self.label = label
  }
  
  var body: some View {
    Button(action: { action(fieldValues) }, label: label)
  }
}

struct SubmitButton_Previews: PreviewProvider {
  static var previews: some View {
    SubmitButton(action: { data in  }) {
      Text("Submit")
    }
  }
}
