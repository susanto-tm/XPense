//
//  UserProfileScreen.swift
//  XPense
//
//  Created by Timothy Alexander on 4/7/23.
//

import Foundation
import SwiftUI
import FirebaseAuth

struct UserProfileScreen: View {
  @EnvironmentObject() private var authStore: AuthStore
  
  var user: User? {
    Auth.auth().currentUser
  }
  
  var firstName: String {
    if user != nil {
      return String(
        user!.displayName!.split(separator: " ").first!
      )
    } else {
      return ""
    }
  }
  
  var lastName: String {
    if user != nil {
      return String(
        user!.displayName!.split(separator: " ")[1]
      )
    } else {
      return ""
    }
  }
  
  var body: some View {
    if user != nil && !authStore.isLoadingUpdateDisplayName {
      ControlledForm(
        defaultValues: [
          "firstName": FormTextField(value: firstName),
          "lastName": FormTextField(value: lastName)
        ]
      ) {
        VStack(spacing: 20) {
          Spacer().frame(height: 15)
          ControlledTextField(name: "firstName", placeholder: "Enter first name")
          ControlledTextField(name: "lastName", placeholder: "Enter last name")
          SubmitButton(action: { data in
            let firstName = data["firstName"]!.value as! String
            let lastName = data["lastName"]!.value as! String
            
            authStore.updateDisplayName(
              with: "\(firstName) \(lastName)"
            )
          }) {
            Text("Save")
              .bold()
              .foregroundColor(.white)
              .padding(.vertical, 10)
              .frame(maxWidth: .infinity)
          }
          .background(
            RoundedRectangle(cornerRadius: 10)
              .foregroundColor(.pinkAccent)
          )
          Spacer()
        }
      }
      .padding(.horizontal)
      .navigationTitle("Edit Profile")
    } else if authStore.isLoadingUpdateDisplayName {
      Loading("Updating user data...")
    } else {
      Loading("Fetching user data...")
    }
  }
}

struct UserProfileScreen_Previews: PreviewProvider {
  static var previews: some View {
    UserProfileScreen()
      .environmentObject(AuthStore())
  }
}
