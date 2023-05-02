//
//  Toolbar.swift
//  XPense
//
//  Created by Timothy Alexander on 4/4/23.
//

import Foundation
import SwiftUI
import FirebaseAuth

struct HomeScreenToolbar : View {
  @EnvironmentObject() private var router: MainRouterStore
  
  var user: User? {
    Auth.auth().currentUser
  }
  
  var body: some View {
    HStack {
      Text("Expenses")
        .font(.largeTitle)
        .bold()
      Spacer()
      NavigationLink {
        SettingsScreen()
      } label: {
        Image(systemName: "person.circle")
          .resizable()
          .scaledToFit()
          .foregroundStyle(Color.pinkAccent)
          .frame(width: 30)
      }
    }
    .padding(.top, 10)
  }
}
