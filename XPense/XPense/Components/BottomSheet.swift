//
//  BottomSheet.swift
//  XPense
//
//  Created by Timothy Alexander on 4/16/23.
//

import Foundation
import SwiftUI

enum SnapPoint: Equatable {
  case small, medium, large
  case fraction(_ fraction: CGFloat)
  
  var factor: CGFloat {
    switch self {
    case .small: return 0.75
    case .medium: return 0.35
    case .large: return 0.1
    case .fraction(let t): return 1 - t
    }
  }
  
  static func toSnap(_ factor: CGFloat) -> SnapPoint {
    switch factor {
    case 0.75: return .small
    case 0.35: return .medium
    case 0.1: return .large
    default: return .fraction(factor)
    }
  }
}

struct BottomSheet<Content>: View where Content : View {
  let minHeight: CGFloat
  let maxHeight: CGFloat
  var snapPoints: [SnapPoint]
  let content: Content
  let onDismiss: (() -> Void)?
  var color: Color = Color.white
  
  @GestureState private var dragTranslation: CGFloat = 0
  @State private var snap: SnapPoint {
    didSet {
      activeSnap = snap
    }
  }
  @Binding private var isOpen: Bool
  
  @Binding var activeSnap: SnapPoint
  
  init(
    isOpen: Binding<Bool>,
    onDismiss: (() -> Void)? = nil,
    minHeight: CGFloat = 130.0,
    maxHeight: CGFloat = UIScreen.main.bounds.height,
    snapPoints: [SnapPoint] = [.medium],
    activeSnap: Binding<SnapPoint>? = nil,
    color: Color = Color.white,
    @ViewBuilder content: () -> Content
  ) {
    self.minHeight = minHeight
    self.maxHeight = maxHeight
    self.snapPoints = snapPoints.sorted { $0.factor > $1.factor }
    self.content = content()
    self.onDismiss = onDismiss
    self.color = color
    
    self._snap = State(initialValue: snapPoints.first!)
    self._isOpen = isOpen
    
    self._activeSnap = activeSnap ?? .constant(.small)
  }
  
  private var handle: some View {
    RoundedRectangle(cornerRadius: 24)
      .foregroundColor(.gray.opacity(0.7))
      .frame(width: 40, height: 5)
  }
  
  private var offset: CGFloat {
    isOpen ? maxHeight * snap.factor : maxHeight
  }
  
  var body: some View {
    GeometryReader { proxy in
      let width = proxy.size.width
      VStack {
        handle.padding(.top, 13)
        content
          .environment(\.dismissSheet, onDismiss ?? {})
      }
      .frame(width: width, height: maxHeight, alignment: .top)
      .background(color)
      .cornerRadius(12)
      .frame(height: proxy.size.height, alignment: .bottom)  // avoids using Spacer()
      .offset(y: max(offset + dragTranslation, 0))
      .shadow(
        color: .black.opacity(0.15),
        radius: 8,
        x: 0,
        y: 5
      )
      .animation(.interactiveSpring(), value: isOpen)
      .animation(.interactiveSpring(), value: dragTranslation)
      .gesture(
        DragGesture().updating($dragTranslation) { value, state, _ in
          state = value.translation.height
        }.onEnded { value in
          if value.location.y > UIScreen.main.bounds.height * Double(SnapPoint.small.factor) {
            if onDismiss != nil {
              onDismiss!()
              isOpen = false
            }
            return
          }

          // find the closest distance to a snap point
          let closestSnap = snapPoints
            .map { maxHeight * $0.factor }
            .map { abs(value.predictedEndLocation.y - $0) }
            .enumerated()
            .min { $0.element < $1.element }

          if closestSnap != nil {
            snap = snapPoints[closestSnap!.offset]
          }
        }
      )
    }
  }
}

private struct DismissSheetKey: EnvironmentKey {
  static let defaultValue: () -> Void = {}
}

private struct SnapToKey: EnvironmentKey {
  static let defaultValue: (SnapPoint) -> Void = {_ in }
}

extension EnvironmentValues {
  var dismissSheet: () -> Void {
    get { self[DismissSheetKey.self] }
    set { self[DismissSheetKey.self] = newValue }
  }
  
  var snapTo: (SnapPoint) -> Void {
    get { self[SnapToKey.self] }
    set { self[SnapToKey.self] = newValue }
  }
}

struct BottomSheet_Previews: PreviewProvider {
  static var previews: some View {
    ZStack {
      Color.black
      BottomSheet(isOpen: .constant(true), onDismiss: {}) {
        Color.white
      }
    }
    .ignoresSafeArea()
  }
}
