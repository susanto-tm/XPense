//
//  ControlledPicker.swift
//  XPense
//
//  Created by Timothy Alexander on 4/6/23.
//

import Foundation
import SwiftUI

struct PickerGroup<T, Label>: View where T : Equatable, T : Identifiable, T : CaseIterable, Label : View, Divider : View {
  
  @Environment(\.colorScheme) private var colorScheme
  
  @Binding var selection: T
  var items: T.AllCases
  var label: (T, Int) -> Label
  var withDivider: Bool = false
  
  
  init(selection: Binding<T>, items: T.Type, withDivider: Bool = false, @ViewBuilder label: @escaping (T, Int) -> Label) {
    self._selection = selection
    self.items = items.allCases
    self.label = label
    self.withDivider = withDivider
  }
  
  var body: some View {
    VStack(spacing: 15) {
      ForEach(0..<Array(items).count, id: \.self) { index in
        Button(action: {
          selection = Array(items)[index]
        }) {
          HStack(alignment: .center) {
            label(Array(items)[index], index)
            Spacer()
            RadioButton(
              isSelected: selection == Array(items)[index]
            )
            .frame(width: 18, height: 18)
          }
          .foregroundColor(colorScheme == .dark ? .white : .black)
          .padding(.horizontal, 15)
        }
        if withDivider && index < 2 {
          Rectangle()
            .frame(height: 3)
            .foregroundColor(.gray.opacity(0.4))
        }
      }
    }
    .padding(.vertical, 15)
  }
}

private struct RadioButton: View {
  var isSelected: Bool
  
  @Environment(\.colorScheme) private var colorScheme
  
  var borderColor: Color {
    colorScheme == .dark ? .white : .gray.opacity(0.4)
  }
  
  var body: some View {
    GeometryReader { proxy in
      Circle()
        .foregroundColor(borderColor)
        .overlay {
          Circle()
            .foregroundColor(.white)
            .frame(
              width: proxy.size.width * 0.8,
              height: proxy.size.height * 0.8
            )
            .overlay {
              Circle()
                .foregroundColor(.pinkAccent)
                .frame(
                  width: proxy.size.width * 0.6,
                  height: proxy.size.height * 0.6
                )
                .opacity(isSelected ? 1.0 : 0.0)
            }
        }
    }
  }
}

struct ControlledPicker_Previews: PreviewProvider {
  enum PickerTest : String, Identifiable, CaseIterable {
    var id: RawValue { rawValue }
    case picker1, picker2, picker3
  }
  
  static var previews: some View {
    PickerGroup(
      selection: .constant(PickerTest.picker1),
      items: PickerTest.self,
      withDivider: true
    ) { data, _ in
      Text(data.rawValue)
    }
  }
}
