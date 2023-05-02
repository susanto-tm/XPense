//
//  MainRouterStore.swift
//  XPense
//
//  Created by Timothy Alexander on 4/15/23.
//

import Foundation
import SwiftUI

enum MainRoute {
  case Home, Settings, Scan, ScanEdit
}

extension MainRoute {
  @ViewBuilder
  static func view(for path: MainRoute) -> some View {
    switch path {
    case .Home:
      HomeScreen()
    case .Settings:
      SettingsScreen()
    case .Scan:
      ScanScreen()
    case .ScanEdit:
      ScanEditScreen()
    }
  }
}

class MainRouterStore: ObservableObject {
  @Published var path: [MainRoute]
  @Published var params: [String : Any]
  
  init() {
    self.path = [MainRoute]()
    self.params = [:]
  }
  
  private func clearParams() {
    self.params = [:]
  }
  
  func popAll() {
    path.removeLast(path.count)
    self.clearParams()
  }
  
  func goBack(steps: Int? = nil) {
    if steps == nil {
      path.removeLast(1)
    } else {
      path.removeLast(steps!)
    }
    self.clearParams()
  }
  
  func goBack(to route: MainRoute) {
    if path.contains(route) {
      let routeIndex = path.lastIndex(of: route)
      if routeIndex != nil {
        // exclude routeIndex
        path.removeLast(path.count - routeIndex! - 1)
        self.clearParams()
      }
    }
  }
  
  func goto(_ route: MainRoute) {
    path.append(route)
    self.clearParams()
  }
}
