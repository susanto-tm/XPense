//
//  ControlledTextField.swift
//  XPense
//
//  Created by Timothy Alexander on 4/2/23.
//

import Foundation
import SwiftUI

struct ControlledTextField: View {
  var name: String
  var placeholder: String
  var isSecure: Bool = false
 
  @Environment(\.fieldValues) private var fieldValues
  @Environment(\.onChangeText) private var onChangeText
  @Environment(\.colorScheme) private var colorScheme
  
  @State private var value: String = ""
  @FocusState private var isFocused: Bool
  
  init(name: String, placeholder: String = "") {
    self.name = name
    self.placeholder = placeholder
  }
  
  init(name: String, placeholder: String = "", isSecure: Bool) {
    self.name = name
    self.placeholder = placeholder
    self.isSecure = isSecure
  }
  
  var prompt: Text? {
    Text(placeholder)
      .foregroundColor(
        colorScheme == .dark ? Color.white.opacity(0.6) : Color.black.opacity(0.6)
      )
  }
  
  var body: some View {
    Group {
      if isSecure {
        SecureField(name, text: $value, prompt: prompt)
      } else {
        TextField(name, text: $value, prompt: prompt)
      }
    }
      .focused($isFocused)
      .onAppear {
        if fieldValues[name] != nil && fieldValues[name]! is FormTextField {
          value = (fieldValues[name]! as! FormTextField).value
        }
      }
      .onChange(of: value) { _ in
        onChangeText(name, value)
      }
      .textFieldStyle(ControlledTextFieldStyle(isFocused: $isFocused))
  }
}

struct ControlledTextFieldStyle: TextFieldStyle {
  var isFocused: FocusState<Bool>.Binding
  
  @Environment(\.colorScheme) private var colorScheme
  
  private var borderGradient: LinearGradient {
    LinearGradient(
      colors: [.pinkAccent, .orangeAccent],
      startPoint: .topLeading,
      endPoint: .bottomTrailing
    )
  }
  
  var border: some View {
    let regularBorder = colorScheme == .dark ? Color.white : Color.black.opacity(0.8)
    
    return RoundedRectangle(cornerRadius: 10)
      .strokeBorder(
        LinearGradient(
          colors: isFocused.wrappedValue
          ? [.pinkAccent, .orangeAccent]
          : [regularBorder, regularBorder],
          startPoint: .topLeading,
          endPoint: .bottomTrailing
        ),
        lineWidth: isFocused.wrappedValue ? 4 : 2
      )
  }
  
  var fill: some View {
    RoundedRectangle(cornerRadius: 10)
      .fill(colorScheme == .dark ? .black : .white)
  }
  
  func _body(configuration: TextField<_Label>) -> some View {
    configuration
      .padding(.vertical, 15)
      .padding(.horizontal, 10)
      .foregroundColor(colorScheme == .dark ? .white : .black)
      .background(
        border
          .background(fill)
      )
  }
}

struct ControlledTextField_Previews: PreviewProvider {
  static var previews: some View {
    ControlledForm(defaultValues: ["email": FormTextField(type: .text, value: "")]) {
      ControlledTextField(name: "email", placeholder: "Enter Email")
    }
  }
}
