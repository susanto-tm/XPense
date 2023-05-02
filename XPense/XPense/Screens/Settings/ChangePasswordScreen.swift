//
//  ChangePasswordScreen.swift
//  XPense
//
//  Created by Timothy Alexander on 4/7/23.
//

import Foundation
import SwiftUI

struct ChangePasswordScreen: View {
  @EnvironmentObject private var authStore: AuthStore
  @Environment(\.dismiss) private var dismiss
  
  var body: some View {
    if authStore.isLoading {
      Loading("Changing Password...")
    } else {
      ControlledForm(
        defaultValues: [
          "oldPassword": FormTextField(value: ""),
          "newPassword": FormTextField(value: "")
        ]
      ) {
        VStack(spacing: 20) {
          Spacer().frame(height: 15)
          ControlledTextField(
            name: "oldPassword",
            placeholder: "Enter old password",
            isSecure: true
          )
          ControlledTextField(
            name: "newPassword",
            placeholder: "Enter new password",
            isSecure: true
          )
          SubmitButton(action: { data in
            let oldPassword = (data["oldPassword"] as! FormTextField).value
            let newPassword = (data["newPassword"] as! FormTextField).value
            
            authStore.changePassword(from: oldPassword, to: newPassword)
            
            dismiss()
          }) {
            Text("Submit")
              .bold()
              .foregroundColor(.white)
              .padding(.vertical, 10)
              .frame(maxWidth: .infinity)
          }
          .background {
            RoundedRectangle(cornerRadius: 10)
              .fill(Color.pinkAccent)
          }
          Spacer()
        }
        .padding(.horizontal)
      }
      .navigationTitle("Change Password")
    }
  }
}

struct ChangePassword_Previews: PreviewProvider {
  static var previews: some View {
    ChangePasswordScreen()
      .environmentObject(AuthStore())
  }
}
