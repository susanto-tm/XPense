//
//  XPenseApp.swift
//  XPense
//
//  Created by Timothy Alexander on 3/28/23.
//

import SwiftUI
import FirebaseCore

class AppDelegate : NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main
struct XPenseApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

  @ObservedObject var authStore: AuthStore
  @ObservedObject var mainRouterStore: MainRouterStore
  @ObservedObject var scannerStore: ScannerStore
  @ObservedObject var themeStore: ThemeStore
  
  @Environment(\.colorScheme) private var colorScheme
  
  let persistenceController = PersistenceController.shared
  
  let receiptRepository: ReceiptRepository
  
  init() {
    let _authStore = AuthStore()
    let _receiptRepo = ReceiptRepository(authStore: _authStore, baseUrl: Config.baseUrl)
    
    self.authStore = _authStore
    self.mainRouterStore = MainRouterStore()
    
    self.receiptRepository = _receiptRepo
    self.scannerStore = ScannerStore(receiptRepo: _receiptRepo)
    
    self.themeStore = ThemeStore()
  }
  
  var body: some Scene {
    WindowGroup {
      ContentView()
        .environment(\.managedObjectContext, persistenceController.container.viewContext)
        .environmentObject(authStore)
        .environmentObject(scannerStore)
        .environmentObject(mainRouterStore)
        .environmentObject(themeStore)
    }
  }
}
