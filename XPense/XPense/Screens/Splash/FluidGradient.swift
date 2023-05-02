//
//  FluidGradient.swift
//  XPense
//
//  Created by Timothy Alexander on 4/3/23.
//

import Foundation
import SwiftUI

struct FluidGradient: View {
  var body: some View {
    Blobs()
      .scaleEffect(1.5)
      .ignoresSafeArea()
  }
}

struct FluidGradient_Previews: PreviewProvider {
  static var previews: some View {
    FluidGradient()
  }
}
