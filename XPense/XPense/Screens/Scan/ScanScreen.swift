//
//  ScanScreen.swift
//  XPense
//
//  Created by Timothy Alexander on 4/7/23.
//

import Foundation
import SwiftUI

struct ScanScreen: View {
  @EnvironmentObject private var router: MainRouterStore

  var body: some View {
    Scanner(
      onSubmit: {
        router.goto(.ScanEdit)
      },
      onDismiss: {
        router.goBack()
      }
    )
    .ignoresSafeArea()
    .toolbar(.hidden)
  }
}

struct ScanScreen_Previews: PreviewProvider {
  static var previews: some View {
    ScanScreen()
      .environmentObject(MainRouterStore())
  }
}
