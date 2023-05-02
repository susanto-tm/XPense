//
//  RootRouter.swift
//  XPense
//
//  Created by Timothy Alexander on 4/3/23.
//

import Foundation
import SwiftUI
import FirebaseAuth

struct RootRouter: View {
  @EnvironmentObject private var authStore: AuthStore
  
  var body: some View {
    if authStore.isAuthenticated {
      MainRouter()
        .transition(.move(edge: .trailing))
    } else {
      AuthRouter()
        .transition(.move(edge: .leading))
    }
  }
}
