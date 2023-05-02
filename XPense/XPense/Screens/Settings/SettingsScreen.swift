//
//  SettingsScreen.swift
//  XPense
//
//  Created by Timothy Alexander on 4/6/23.
//

import Foundation
import SwiftUI


struct SettingsScreen: View {
  @AppStorage("theme", store: .standard) var theme: AppTheme = .automatic
  
  @EnvironmentObject() private var authStore: AuthStore
  
  var body: some View {
    VStack(spacing: 0) {
      Toolbar()
      
      HStack {
        Text("Theme")
          .font(.system(size: 20, weight: .bold))
          .padding(.bottom, 5)
        Spacer()
      }
      .padding(.top)
      
      PickerGroup(selection: $theme, items: AppTheme.self, withDivider: true) { data, index in
        Group {
          SettingIcon(data.icon)
          Spacer().frame(width: 10)
          Text(data.rawValue.capitalized)
            .bold()
        }
      }
      .overlay {
        RoundedRectangle(cornerRadius: 10)
          .stroke(.gray.opacity(0.4), lineWidth: 3)
      }
      
      HStack {
        Text("Account")
          .font(.system(size: 20, weight: .bold))
          .padding(.bottom, 5)
        Spacer()
      }
      .padding(.top)
      
      VStack(spacing: 15) {
        AccountOption("Profile", icon: "person.fill") {
          UserProfileScreen()
        }
        Rectangle()
          .foregroundColor(.gray.opacity(0.4))
          .frame(height: 3)
        AccountOption("Change Password", icon: "lock") {
          ChangePasswordScreen()
        }
      }
      .padding(.vertical)
      .overlay {
        RoundedRectangle(cornerRadius: 10)
          .stroke(.gray.opacity(0.4), lineWidth: 3)
      }
      
      Button(action: authStore.signOut) {
        Text("Logout")
          .bold()
          .foregroundColor(.white)
          .padding(.vertical, 10)
      }
      .frame(maxWidth: .infinity)
      .background(
        RoundedRectangle(cornerRadius: 10)
          .fill(Color.pinkAccent)
      )
      .padding(.top)
      Spacer()
    }
    .padding(.horizontal)
  }
}

private struct Toolbar: View {
  var body: some View {
    HStack {
      Text("Settings")
        .font(.system(size: 40, weight: .bold))
      Spacer()
    }
  }
}

private struct AccountOption<Link>: View where Link : View {
  @Environment(\.colorScheme) private var colorScheme
  
  var label: String
  var icon: String
  var to: Link
  
  init(_ titleKey: String, icon: String, @ViewBuilder to: @escaping () -> Link) {
    self.label = titleKey
    self.icon = icon
    self.to = to()
  }
  
  var body: some View {
    NavigationLink {
      to
    } label: {
      HStack {
        SettingIconBase {
          Image(systemName: icon)
            .resizable()
            .foregroundStyle(.white)
            .frame(width: 15, height: 17)
        }
        Spacer().frame(width: 10)
        Text(label)
          .bold()
        Spacer()
        Image(systemName: "arrow.forward")
          .resizable()
          .scaledToFit()
          .frame(height: 13)
      }
      .padding(.horizontal, 15)
    }
    .foregroundColor(colorScheme == .dark ? .white : .black)
  }
}

private struct SettingIconBase<Icon>: View where Icon : View {
  var icon: Icon
  
  init(@ViewBuilder icon: @escaping () -> Icon) {
    self.icon = icon()
  }
  
  var body: some View {
    ZStack {
      LinearGradient(
        colors: [.orangeAccent, .pinkAccent],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
      )
      .frame(width: 33, height: 33)
      .clipShape(RoundedRectangle(cornerRadius: 8))
      
      icon
    }
  }
}

private struct SettingIcon: View {
  var icon: String
  
  init(_ icon: String) {
    self.icon = icon
  }
  
  var body: some View {
    SettingIconBase {
      Image(icon)
        .resizable()
        .frame(width: 20, height: 20)
    }
  }
}

struct SettingsScreen_Previews: PreviewProvider {
  static var previews: some View {
    SettingsScreen()
      .environmentObject(AuthStore())
  }
}
