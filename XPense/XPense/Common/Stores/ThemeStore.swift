//
//  ThemeStore.swift
//  XPense
//
//  Created by Timothy Alexander on 4/29/23.
//

import Foundation
import SwiftUI

enum AppTheme: String, CaseIterable, Identifiable {
  var id: RawValue { rawValue }
  
  case automatic, light, dark
  
  var icon: String {
    switch self {
    case .automatic:
      return "SunMoon"
    case .dark:
      return "Moon"
    case .light:
      return "Sun"
    }
  }
}

class ThemeStore: ObservableObject {
  @AppStorage("theme", store: .standard) var theme: AppTheme = .automatic
}
