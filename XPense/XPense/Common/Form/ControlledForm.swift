//
//  ControlledForm.swift
//  XPense
//
//  Created by Timothy Alexander on 3/30/23.
//

import Foundation
import SwiftUI

enum FormType {
  case text, list, number, selection
}

protocol FormFieldValue : Identifiable {
  associatedtype T
  
  var type: FormType { get set }
  var value: T { get set }
}

struct FormTextField : FormFieldValue {
  var id = UUID()
  var type : FormType = .text
  var value: String
  
  static let empty = FormTextField(type: .text, value: "")
  
  mutating func onChange(newValue: String) {
    value = newValue
  }
}

struct FormListField<T> : FormFieldValue {
  var id = UUID()
  var type = FormType.list
  var value: Array<T>
  
  mutating func onChange(index: Int, newValue: T) {
    value[index] = newValue
  }
  
  mutating func append(newValue: T) {
    value.append(newValue)
  }
}

struct FormSelectionField<T> : FormFieldValue {
  var id = UUID()
  var type = FormType.selection
  var value: T
  
  mutating func onChange(newValue: T) {
    value = newValue
  }
}

typealias FieldValues = [String : any FormFieldValue]

struct ControlledForm<Content>: View where Content : View {
  let content: Content
  
  @State private var fieldValues : FieldValues
  
  init(
    defaultValues initialValue: FieldValues,
    @ViewBuilder content: @escaping () -> Content
  ) {
    self.content = content()
    self._fieldValues = State(initialValue: initialValue)
  }
  
  private func onChangeTextField(name: String, newValue value: String) {
    let fieldValue = self.fieldValues[name]
    
    if fieldValue is FormTextField {
      var newFieldValue = fieldValue as! FormTextField
      newFieldValue.onChange(newValue: value)
      
      self.fieldValues[name] = newFieldValue
    } else {
      fatalError("onChangeTextField requires fieldValue to be of type FormTextField")
    }
  }
  
  private func onChangeListField<T>(name: String, index: Int, newValue value: T) {
    let fieldValue = self.fieldValues[name]
    
    if fieldValue is FormListField<T> {
      var newFieldValue = fieldValue as! FormListField<T>
      newFieldValue.onChange(index: index, newValue: value)
      
      self.fieldValues[name] = newFieldValue
    } else {
      fatalError("onChangeListField requires fieldValue to be of type FormListField")
    }
  }
  
  private func appendListItem<T>(name: String, newValue value: T) {
    let fieldValue = self.fieldValues[name]
    
    if fieldValue != nil {
      var newFieldValue = fieldValue as! FormListField<T>
      newFieldValue.append(newValue: value)
      
      self.fieldValues[name] = newFieldValue
    } else {
      fatalError("\(name) does not exist")
    }
  }
  
  private func onChangeSelection<T>(name: String, newValue value: T) {
    let fieldValue = self.fieldValues[name]
    
    if fieldValue is FormSelectionField<T> {
      var newFieldValue = fieldValue as! FormSelectionField<T>
      newFieldValue.onChange(newValue: value)
      
      self.fieldValues[name] = newFieldValue
    } else {
      fatalError("onChangeSelection required fieldValue to be of type FormPickerField")
    }
  }
  
  var body: some View {
    content
      .environment(\.onChangeText, onChangeTextField)
      .environment(\.onChangeList, onChangeListField)
      .environment(\.onChangeSelection, onChangeSelection)
      .environment(\.appendListItem, appendListItem)
      .environment(\.fieldValues, fieldValues)
  }
}

private struct OnChangeTextFieldKey: EnvironmentKey {
  static let defaultValue: (String, String) -> Void = { _, _ in }
}

private struct OnChangeListFieldKey: EnvironmentKey {
  static let defaultValue: (String, Int, Any) -> Void = { _, _, _ in }
}

private struct OnChangeSelectionFieldKey: EnvironmentKey {
  static let defaultValue: (String, Any) -> Void = { _, _ in }
}

private struct AppendListItemKey: EnvironmentKey {
  static let defaultValue: (String, Any) -> Void = { _, _ in }
}

private struct FieldValuesKey: EnvironmentKey {
  static let defaultValue: FieldValues = [:]
}

extension EnvironmentValues {
  var onChangeText: (String, String) -> Void {
    get { self[OnChangeTextFieldKey.self] }
    set { self[OnChangeTextFieldKey.self] = newValue }
  }
  
  var onChangeList: (String, Int, Any) -> Void {
    get { self[OnChangeListFieldKey.self] }
    set { self[OnChangeListFieldKey.self] = newValue }
  }
  
  var onChangeSelection: (String, Any) -> Void {
    get { self[OnChangeSelectionFieldKey.self] }
    set { self[OnChangeSelectionFieldKey.self] = newValue }
  }
  
  var appendListItem: (String, Any) -> Void {
    get { self[AppendListItemKey.self] }
    set { self[AppendListItemKey.self] = newValue }
  }
  
  var fieldValues: FieldValues {
    get { self[FieldValuesKey.self] }
    set { self[FieldValuesKey.self] = newValue }
  }
}
