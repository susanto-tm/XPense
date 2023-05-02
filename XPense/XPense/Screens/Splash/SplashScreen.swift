//
//  SplashScreen.swift
//  XPense
//
//  Created by Timothy Alexander on 4/3/23.
//

import Foundation
import SwiftUI

struct SplashScreen: View {
  var body: some View {
    FluidGradient()
      .overlay {
        VStack {
          Spacer()
          VStack {
            Spacer()
            HStack {
              Text("XPense")
                .font(.system(size: 40, weight: .black).italic())
                .padding(.leading, 20)
              Spacer()
            }
            HStack {
              Text("Organize your expenses with ease")
                .fontWeight(.semibold)
                .font(.system(size: 23))
                .frame(width: 280)
                .padding(.leading, 5)
              Spacer()
            }
            Spacer()
            HStack {
              NavigationLink {
                LoginScreen()
              } label: {
                Text("Get Started")
                  .bold()
                  .frame(maxWidth: .infinity)
                  .padding(.vertical, 13)
              }
              .background(
                RoundedRectangle(cornerRadius: 50)
                  .foregroundColor(.black)
              )
            }
            .padding(.horizontal)
          }
          Spacer().frame(height: 50)
        }
        .foregroundColor(.white)
      }
  }
}

struct SplashScreen_Previews: PreviewProvider {
  static var previews: some View {
    SplashScreen()
  }
}
