//
//  MainRouter.swift
//  XPense
//
//  Created by Timothy Alexander on 4/3/23.
//

import Foundation
import SwiftUI

struct MainRouter: View {
  @EnvironmentObject() private var navigationStore: MainRouterStore
  
  var body: some View {
    NavigationStack(path: $navigationStore.path) {
      HomeScreen()
        .navigationDestination(for: MainRoute.self, destination: MainRoute.view(for:))
    }
  }
}
