//
//  LoginScreen.swift
//  XPense
//
//  Created by Timothy Alexander on 3/30/23.
//

import SwiftUI

struct LoginScreen: View {
  @EnvironmentObject() private var authStore: AuthStore
  @Environment(\.colorScheme) private var colorScheme
  
  var body: some View {
    ZStack {
      Color.black
      VStack {
        Spacer()
        Text("Login.")
          .font(.system(size: 45, weight: .black))
          .foregroundColor(.white)
          .frame(maxWidth: .infinity, alignment: .leading)
        ControlledForm(
          defaultValues: [
            "email": FormTextField(type: .text, value: ""),
            "password": FormTextField(type: .text, value: "")
          ]
        ) {
          ControlledTextField(name: "email", placeholder: "Enter email")
            .keyboardType(.emailAddress)
            .autocapitalization(.none)
            .autocorrectionDisabled(true)
          Spacer().frame(height: 20)
          ControlledTextField(name: "password", placeholder: "Enter password", isSecure: true)
          Spacer().frame(height: 20)
          SubmitButton(action: { data in
            authStore.signIn(
              withEmail: data["email"]!.value as! String,
              password: data["password"]!.value as! String
            )
          }) {
            Text("Submit")
              .bold()
              .foregroundColor(.white)
              .frame(maxWidth: .infinity)
              .padding(.vertical, 10)
          }
          .background(
            RoundedRectangle(cornerRadius: 15)
              .foregroundColor(.pinkAccent)
          )
          HStack {
            Text("Don't have an account?")
              .foregroundColor(.white)
            NavigationLink {
              SignUpScreen()
            } label: {
              Text("Sign Up")
                .bold()
                .foregroundColor(.pinkAccent)
            }
            Spacer()
          }
          .padding(.top, 5)
        }
        Spacer()
      }
      .padding(.horizontal)
      
      if authStore.isLoading {
        Loading("Logging in...")
      }
    }
    .preferredColorScheme(.dark)
    .ignoresSafeArea()
  }
}

struct LoginScreen_Previews: PreviewProvider {
  static var previews: some View {
    LoginScreen()
  }
}
