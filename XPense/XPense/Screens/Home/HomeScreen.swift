//
//  HomeScreen.swift
//  XPense
//
//  Created by Timothy Alexander on 4/4/23.
//

import Foundation
import SwiftUI
import FirebaseAuth

struct HomeScreen: View {
  @EnvironmentObject() private var router: MainRouterStore
  @EnvironmentObject() private var authStore: AuthStore
  
  @Environment(\.managedObjectContext) private var moc
  
  @FetchRequest(
    sortDescriptors: [
      SortDescriptor(\CDReceipt.createdAt, order: .reverse)
    ]
  ) private var receipts: FetchedResults<CDReceipt>
  
  var body: some View {
    ZStack {
      VStack {
        HomeScreenToolbar()
          .padding(.horizontal)
        if receipts.isEmpty {
          Placeholder()
        } else {
          SummaryChart(receipts: Array(receipts))
            .frame(width: 350, height: 200)
          LastTransaction(receipts: receipts)
        }
        Spacer()
      }
      
      VStack {
        Spacer()
        HStack {
          Spacer()
          Button(action: {
            router.goto(.Scan)
          }) {
            Circle()
              .fill(Color.pinkAccent)
              .frame(width: 60, height: 60)
              .shadow(color: Color.black.opacity(0.2), radius: 5, x: 2, y: 2)
              .overlay {
                Image(systemName: "camera.fill")
                  .resizable()
                  .scaledToFit()
                  .frame(width: 25)
                  .foregroundStyle(.white)
              }
          }
        }
        .padding(.horizontal, 25)
      }
      .padding(.bottom, 8)
      .onAppear {
        moc.refreshAllObjects()
      }
    }
  }
}

private struct Placeholder: View {
  var body: some View {
    Spacer()
    Image(systemName: "camera")
      .resizable()
      .scaledToFit()
      .frame(width: 80)
      .foregroundStyle(.gray.opacity(0.8))
    Text("Tap on the icon to add a new receipt")
      .font(.title)
      .fontWeight(.medium)
      .foregroundColor(.gray.opacity(0.9))
      .multilineTextAlignment(.center)
    Spacer()
  }
}

private struct LastTransaction: View {
  @EnvironmentObject private var router: MainRouterStore
  
  var receipts: FetchedResults<CDReceipt>
  
  var body: some View {
    ScrollView {
      Spacer().frame(height: 5)
      VStack(spacing: 20) {
        ForEach(receipts) { receipt in
          NavigationLink {
            DetailsScreen(id: receipt.id!)
          } label: {
            Transaction(receipt: receipt)
          }
          .padding(.horizontal)
        }
      }
    }
  }
}

struct Transaction: View {
  var receipt: CDReceipt
  
  var total: String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.maximumFractionDigits = 2
    formatter.currencyCode = "USD"
    
    return formatter.string(for: receipt.total)!
  }
  
  var body: some View {
    HStack(alignment: .center) {
      TransactionIcon()
      Spacer().frame(width: 10)
      Text(receipt.name ?? "")
        .foregroundColor(.black)
        .font(.body)
        .fontWeight(.bold)
        .multilineTextAlignment(.leading)
      Spacer()
      Text(total)
        .foregroundColor(.black)
        .font(.body)
        .fontWeight(.semibold)
    }
    .padding(.vertical, 15)
    .padding(.horizontal, 15)
    .background {
      RoundedRectangle(cornerRadius: 10)
        .fill(Color.white)
        .shadow(color: Color.black.opacity(0.1), radius: 4, y: 0)
    }
  }
}

struct TransactionIcon: View {
  var body: some View {
    ZStack {
      LinearGradient(
        colors: [.pinkAccent, .orangeAccent],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
      )
      .frame(width: 38, height: 38)
      .clipShape(RoundedRectangle(cornerRadius: 8))
      
      Image(systemName: "fork.knife")
        .resizable()
        .scaledToFit()
        .frame(width: 22, height: 22)
        .foregroundStyle(.white)
    }
  }
}

struct HomeScreen_Previews: PreviewProvider {
  static var previews: some View {
    HomeScreen()
      .environmentObject(AuthStore())
      .environmentObject(MainRouterStore())
  }
}
