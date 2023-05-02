//
//  ControlledPicker.swift
//  XPense
//
//  Created by Timothy Alexander on 4/6/23.
//

import Foundation
import SwiftUI

struct ControlledPicker<T, Label>: View where T : Equatable, T : Identifiable, T : CaseIterable, Label : View {
  var name: String
  var items: T.Type
  var label: (T, Int) -> Label
  
  @State private var selection: T
  
  @Environment(\.fieldValues) private var fieldValues
  @Environment(\.onChangeSelection) private var onChangeSelection
  
  init(_ name: String, items: T.Type, initialValue: T, @ViewBuilder label: @escaping (T, Int) -> Label) {
    self.name = name
    self.items = items
    self.label = label
    self._selection = State(initialValue: initialValue)
  }
  
  var body: some View {
    PickerGroup(selection: $selection, items: items, label: label)
      .onAppear {
        if fieldValues.keys.contains(name) && fieldValues[name] is FormSelectionField<T> {
          selection = (fieldValues[name] as! FormSelectionField<T>).value
        }
      }
      .onChange(of: selection) { [prevSelection = selection] newSelection in
        if newSelection != prevSelection {
          onChangeSelection(name, newSelection as T)
        }
      }
  }
}
