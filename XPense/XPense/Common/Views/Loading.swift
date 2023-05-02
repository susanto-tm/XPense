//
//  Loading.swift
//  XPense
//
//  Created by Timothy Alexander on 4/4/23.
//

import Foundation
import SwiftUI

struct Loading: View {
  var message: String
  
  @Environment(\.colorScheme) private var colorScheme
  
  init(_ message: String) {
    self.message = message
  }
  
  var background: some View {
    colorScheme == .dark ? Color.black : Color.white
  }
  
  var body: some View {
    ZStack {
      background
      VStack {
        Lottie("Loading")
          .frame(width: 150, height: 150)
        Text(message)
          .font(.system(size: 25, weight: .bold))
      }
    }
  }
}

struct Loading_Previews: PreviewProvider {
  static var previews: some View {
    Loading("Waiting to load...")
  }
}
