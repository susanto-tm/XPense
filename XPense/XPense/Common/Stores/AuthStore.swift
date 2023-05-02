//
//  AuthStore.swift
//  XPense
//
//  Created by Timothy Alexander on 4/3/23.
//

import Foundation
import FirebaseAuth
import SwiftUI

struct NewUser {
  var firstName: String
  var lastName: String
}

class AuthStore: ObservableObject {
  var handler: AuthStateDidChangeListenerHandle?
  
  @Published var isAuthenticated: Bool = false
  @Published var isLoading: Bool = false
  @Published var isLoadingUpdateDisplayName = false
  
  deinit {
    if handler != nil {
      Auth.auth().removeStateDidChangeListener(handler!)
    }
  }
  
  func listenAuth() {
    handler = Auth.auth().addStateDidChangeListener { [weak self] auth, user in
      guard let `self` = self else { return }
      if user != nil {
        withAnimation(.linear(duration: 0.25)) {
          self.isAuthenticated = true
        }
      } else {
        withAnimation(.linear(duration: 0.25)) {
          self.isAuthenticated = false
        }
      }
    }
  }
  
  func getIdToken() async -> String {
    guard let currentUser = Auth.auth().currentUser else { return "" }
    
    do {
      return try await currentUser.getIDToken()
    } catch {
      print(error.localizedDescription)
      return ""
    }
  }
  
  func signUp(withEmail email: String, password: String, user: NewUser) {
    self.isLoading = true
    Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
      guard error == nil else {
        print(error!.localizedDescription)
        return
      }
      
      guard let `self` = self else { return }
      
      let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
      changeRequest?.displayName = "\(user.firstName) \(user.lastName)"
      changeRequest?.commitChanges { error in
        if error != nil {
          print(error!.localizedDescription)
        }
        
        DispatchQueue.main.async {
          self.isLoading = false
        }
      }
    }
  }
  
  func signIn(withEmail email: String, password: String) {
    self.isLoading = true
    Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
      guard error == nil else {
        print(error!.localizedDescription)
        return
      }
      
      guard let `self` = self else { return }
      
      DispatchQueue.main.async {
        self.isLoading = false
      }
    }
  }
  
  func changePassword(from oldPassword: String, to newPassword: String) {
    self.isLoading = true
    let user = Auth.auth().currentUser
    
    guard user != nil else { return }
    
    let credential = EmailAuthProvider.credential(withEmail: user!.email!, password: oldPassword)
    
    self.isLoading = true
    
    user?.reauthenticate(with: credential) { _, error in
      if let error = error {
        print(error.localizedDescription)
        
        DispatchQueue.main.async {
          self.isLoading = false
        }
      } else {
        user?.updatePassword(to: newPassword) { error in
          if let error = error {
            print(error.localizedDescription)
          }
          DispatchQueue.main.async {
            self.isLoading = false
            
          }
        }
      }
    }
  }
  
  func signOut() {
    do {
      try Auth.auth().signOut()
    } catch {
      print(error.localizedDescription)
    }
  }
  
  func updateDisplayName(with name: String) {
    if Auth.auth().currentUser != nil {
      self.isLoadingUpdateDisplayName = true
      let changeRequest = Auth.auth().currentUser!.createProfileChangeRequest()
      changeRequest.displayName = name
      changeRequest.commitChanges { [weak self] error in
        guard error == nil else {
          print(error!.localizedDescription)
          return
        }
        
        guard let `self` = self else { return }
        
        DispatchQueue.main.async {
          self.isLoadingUpdateDisplayName = false
        }
      }
    }
  }
}
