//
//  DetailsScreen.swift
//  XPense
//
//  Created by Timothy Alexander on 4/25/23.
//

import Foundation
import SwiftUI

struct DetailsScreen: View {
  @EnvironmentObject private var router: MainRouterStore
  @Environment(\.colorScheme) private var colorScheme
  @Environment(\.managedObjectContext) private var moc
  
  @FetchRequest private var receiptRequest: FetchedResults<CDReceipt>
  
  var receipt: CDReceipt? {
    if !receiptRequest.isEmpty {
      return receiptRequest.first!
    } else {
      return nil
    }
  }
  
  init(id: UUID) {
    self._receiptRequest = FetchRequest(
      sortDescriptors: [],
      predicate: NSPredicate(format: "id == %@", id as NSUUID)
    )
  }
  
  var total: String {
    if receipt != nil {
      let formatter = NumberFormatter()
      formatter.numberStyle = .currency
      formatter.maximumFractionDigits = 2
      formatter.currencyCode = "USD"
      
      return formatter.string(for: receipt!.total)!
    } else {
      return ""
    }
  }
  
  var body: some View {
    if receipt != nil {
      ScrollView(showsIndicators: false) {
        VStack {
          Header(receipt: receipt!)
            .frame(height: 250)
          Breakdown(receipt: receipt!)
            .padding(.top, 5)
          Rectangle()
            .foregroundColor(
              colorScheme == .light
              ? .black.opacity(0.1)
              : .white
            )
            .frame(maxWidth: .infinity, maxHeight: 1)
            .padding(.horizontal)
          HStack {
            Text("Total")
              .foregroundColor(
                colorScheme == .dark ? .white : .black
              )
              .font(.body)
              .bold()
            Spacer()
            Text(total)
              .foregroundColor(
                colorScheme == .dark ? .white : .black
              )
              .font(.body)
              .fontWeight(.semibold)
          }
          .padding(.horizontal)
        }
        Spacer()
      }
      .onAppear {
        moc.refreshAllObjects()
      }
      .toolbarBackground(.hidden, for: .navigationBar)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          NavigationLink {
            EditDetailsScreen(receipt: receipt!)
          } label: {
            Text("Edit")
              .font(.body)
          }
        }
      }
      .coordinateSpace(name: "scroll")
      .ignoresSafeArea(.all, edges: [.top])
    }
  }
}

struct Header: View {
  @Environment(\.colorScheme) private var colorScheme
  
  var receipt: CDReceipt
  
  private func offset(_ scrollOffset: Double) -> Double {
    scrollOffset > 0 ? -scrollOffset : 0
  }
  
  var body: some View {
    GeometryReader { proxy in
      let minY = proxy.frame(in: .named("scroll")).minY
      let height = minY > 0 ? proxy.size.height + minY : proxy.size.height
      
      Rectangle()
        .fill(Color.salmon.opacity(colorScheme == .dark ? 0.8 : 0.4))
        .frame(
          width: proxy.size.width,
          height: height,
          alignment: .top
        )
        .overlay {
          VStack {
            Spacer()
            HStack {
              ZStack {
                RoundedRectangle(cornerRadius: 8)
                  .frame(width: 40, height: 40)
                  .foregroundColor(.salmon)
                Image(systemName: "fork.knife")
                  .resizable()
                  .scaledToFit()
                  .frame(width: 25, height: 25)
                  .foregroundStyle(.white)
              }
              .offset(y: 13)
              Spacer()
              VStack(alignment: .trailing) {
                Text(receipt.category ?? "")
                  .foregroundColor(.white)
                  .font(.body)
                Text(receipt.name ?? "")
                  .foregroundColor(.white)
                  .font(.title)
                  .multilineTextAlignment(.trailing)
                  .bold()
              }
            }
          }
          .padding(.horizontal)
          .padding(.bottom, 10)
        }
        .clipped()
        .offset(x: 0, y: offset(minY))
    }
  }
}

struct Breakdown: View {
  var receipt: CDReceipt
  
  var items: [CDReceiptItem] {
    receipt.items?.allObjects.map{ $0 as! CDReceiptItem } ?? []
  }
  
  private func qty(for item: CDReceiptItem) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.maximumFractionDigits = 2
    
    return formatter.string(for: item.quantity)!
  }
  
  private func price(for item: CDReceiptItem) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.maximumFractionDigits = 2
    formatter.currencyCode = "USD"
    
    return formatter.string(for: item.price)!
  }
  
  var body: some View {
    VStack(alignment: .leading, spacing: 15) {
      ForEach(items.sorted()) { item in
        HStack(alignment: .center) {
          Text("\(qty(for: item))x")
            .frame(width: 23, alignment: .leading)
            .multilineTextAlignment(.leading)
          Text(item.name ?? "")
            .frame(width: 250, alignment: .leading)
            .multilineTextAlignment(.leading)
          Spacer()
          Text("\(price(for: item))")
        }
        .padding(.horizontal)
      }
    }
  }
}

struct DetailsScreen_Previews: PreviewProvider {
  static var previews: some View {
    DetailsScreen(id: UUID())
      .environmentObject(MainRouterStore())
  }
}
