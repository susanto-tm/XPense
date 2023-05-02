//
//  ContentView.swift
//  XPense
//
//  Created by Timothy Alexander on 3/28/23.
//

import SwiftUI
import CoreData

struct ContentView: View {
  @EnvironmentObject() private var authStore: AuthStore
  @EnvironmentObject() private var themeStore: ThemeStore
  @Environment(\.managedObjectContext) private var viewContext
  
  @FetchRequest(
    sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
    animation: .default)
  private var items: FetchedResults<Item>
  
  var body: some View {
    RootRouter()
      .onAppear {
        authStore.listenAuth()
      }
      .preferredColorScheme(
        themeStore.theme == .automatic
        ? nil
        : themeStore.theme == .dark
        ? .dark
        : .light
      )
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
  }
}
