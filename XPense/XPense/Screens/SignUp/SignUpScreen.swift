//
//  SignUpScreen.swift
//  XPense
//
//  Created by Timothy Alexander on 4/4/23.
//

import Foundation
import SwiftUI

struct SignUpScreen: View {
  @EnvironmentObject() private var authStore: AuthStore
  
  var body: some View {
    ZStack {
      Color.black
      ControlledForm(
        defaultValues: [
          "firstName": FormTextField.empty,
          "lastName": FormTextField.empty,
          "email": FormTextField.empty,
          "password": FormTextField.empty
        ]
      ) {
        VStack(spacing: 20) {
          HStack {
            Text("Sign Up.")
              .font(.system(size: 40, weight: .black))
              .foregroundColor(.white)
            Spacer()
          }
          ControlledTextField(name: "firstName", placeholder: "Enter first name")
            .autocapitalization(.words)
          ControlledTextField(name: "lastName", placeholder: "Enter last name")
            .autocapitalization(.words)
          ControlledTextField(name: "email", placeholder: "Enter email")
            .autocorrectionDisabled(true)
            .autocapitalization(.none)
            .keyboardType(.emailAddress)
          ControlledTextField(name: "password", placeholder: "Enter password", isSecure: true)
          SubmitButton(action: { data in
            authStore.signUp(
              withEmail: data["email"]!.value as! String,
              password: data["password"]!.value as! String,
              user: NewUser(
                firstName: data["firstName"]!.value as! String,
                lastName: data["lastName"]!.value as! String
              )
            )
          }) {
            Text("Submit")
              .bold()
              .foregroundColor(.white)
              .frame(maxWidth: .infinity)
              .padding(.vertical, 13)
          }
          .background(
            RoundedRectangle(cornerRadius: 10)
              .foregroundColor(.pinkAccent)
          )
        }
        .padding(.horizontal)
      }
      if authStore.isLoading {
        Loading("Creating User...")
      }
    }
    .preferredColorScheme(.dark)
    .ignoresSafeArea()
  }
}

struct SignUpScreen_Previews: PreviewProvider {
  static var previews: some View {
    SignUpScreen()
      .environmentObject(AuthStore())
  }
}
