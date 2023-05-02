//
//  BlobLayer.swift
//  XPense
//
//  Created by Timothy Alexander on 4/3/23.
//

import Foundation
import SwiftUI
import UIKit

struct Blobs: View {
  private let pink = Color(red: 255 / 255, green: 108 / 255, blue: 249 / 255)
  private let salmon = Color(red: 255 / 255, green: 124 / 255, blue: 132 / 255)
  private let orange = Color(red: 255 / 255, green: 153 / 255, blue: 34 / 255)
  private let indigo = Color(red: 139 / 255, green: 109 / 255, blue: 255 / 255)
  private let sharpRed = Color(red: 241 / 255, green: 85 / 255, blue: 141 / 255)
  
  private func createRefPoint(using point: CGSize) -> (CGFloat, CGFloat) -> CGPoint {
    return { x, y in CGPoint(x: x * point.width, y: y * point.height) }
  }
  
  var body: some View {
    GeometryReader { proxy in
      let ref = createRefPoint(using: proxy.size)
      
      BlobLayer(color: indigo, position: ref(0, 0.33), radius: ref(0.33, 0.2))
      BlobLayer(color: salmon, position: ref(0.3, 0.57), radius: ref(0.2, 0.1))
      BlobLayer(color: sharpRed, position: ref(0.5, 0.7), radius: ref(0.26, 0.15))
      BlobLayer(color: orange, position: ref(0, 0), radius: ref(0.28, 0.2))
      BlobLayer(color: orange, position: ref(0.5, 0.33), radius: ref(0.3, 0.2))
      BlobLayer(color: pink, position: ref(0, 0.7), radius: ref(0.26, 0.15))
      
      BlobLayer(color: salmon, position: ref(0.25, 0), radius: ref(0.25, 0.125))
      BlobLayer(color: salmon, position: ref(0.28, 0.22), radius: ref(0.22, 0.1))
      BlobLayer(color: pink, position: ref(0.57, 0), radius: ref(0.24, 0.18))
    }
  }
}

struct BlobLayer: View {
  var color: Color
  var position: CGPoint
  var radius: CGPoint
  
  var body: some View {
    BlobPath(position: position, radius: radius)
      .fill(color)
      .blur(radius: 50.0)
  }
}

struct BlobPath: Shape {
  var position: CGPoint
  var radius: CGPoint
  
  func path(in rect: CGRect) -> Path {
    var path = Path()
    
    path.addEllipse(
      in: CGRect(
        origin: position,
        size: CGSize(
          width: radius.x * 2,
          height: radius.y * 2
        )
      )
    )
    
    return path
  }
}

struct Blobs_Previews: PreviewProvider {
  static var previews: some View {
    Blobs()
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .ignoresSafeArea()
  }
}

