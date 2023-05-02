//
//  ScanEditScreen.swift
//  XPense
//
//  Created by Timothy Alexander on 4/15/23.
//

import Foundation
import SwiftUI
import CoreData

struct ScanEditScreen: View {
  @EnvironmentObject private var scanStore: ScannerStore
  
  @State private var currentReceipt = 0
  
  @State private var isLoading = false
  @State private var sheetSnap: SnapPoint = .small
  
  var image: UIImage {
    if scanStore.receipts.isEmpty {
      return UIImage(named: "SampleScan")!
    } else {
      return UIImage(cgImage: scanStore.receipts[currentReceipt])
    }
  }
  
  var body: some View {
    ZStack {
      if isLoading {
        Loading("Parsing Receipt...")
      } else {
        LiveTextOverlay(image: image)
        VStack {
          Spacer().frame(height: 20)
          HStack {
            Spacer()
            InteractionOverlay()
            Spacer().frame(width: 20)
          }
          Spacer()
        }
        EditFormSheet(currentReceipt: .constant(0), snap: $sheetSnap)
      }
    }
    .task {
      isLoading = true
      defer { isLoading = false }
      
      do {
        try await scanStore.parseReceipts()
      } catch {
        print(error.localizedDescription)
      }
    }
    .toolbar(.hidden)
  }
}

struct InteractionOverlay: View {
  @EnvironmentObject var scanStore: ScannerStore
  
  var isActive: Bool {
    scanStore.isInteractive
  }
  
  var body: some View {
    Button(action: {
      scanStore.toggleInteractive()
    }) {
      Circle()
        .fill(isActive ? Color.pinkAccent : Color.gray.opacity(0.8))
        .frame(width: 40, height: 40)
        .overlay {
          Image(systemName: isActive ? "hand.point.up.left.fill" : "hand.point.up.left")
            .resizable()
            .scaledToFit()
            .frame(width: 20)
            .foregroundStyle(.white)
        }
    }
  }
}

struct EditFormSheet: View {
  @EnvironmentObject private var scanStore: ScannerStore
  @EnvironmentObject private var router: MainRouterStore
  
  @Binding var currentReceipt: Int
  @Binding var snap: SnapPoint
  
  @State() private var items: Array<ReceiptItem> = []
  
  @Environment(\.managedObjectContext) private var viewContext
  @Environment(\.colorScheme) private var colorScheme
  
  var receipt: ReceiptEntity {
    if scanStore.matchedParsedReceipt.isEmpty {
      return ReceiptEntity(name: "", category: "", total: 0, items: [])
    } else {
      return scanStore.matchedParsedReceipt[currentReceipt]
    }
  }
  
  private func onSubmit(data: FieldValues) {
    let restaurant = (data["restaurant"] as! FormTextField).value
    let category = (data["category"] as! FormTextField).value
    let total = (data["total"] as! FormTextField).value
    
    let cdReceipt = CDReceipt(context: viewContext)
    cdReceipt.id = UUID()
    cdReceipt.name = restaurant
    cdReceipt.category = category
    cdReceipt.total = Double(total) ?? 0.0
    cdReceipt.createdAt = Date()
    
    items.forEach { item in
      let cdReceiptItem = CDReceiptItem(context: viewContext)
      cdReceiptItem.name = item.name
      cdReceiptItem.price = item.price
      cdReceiptItem.quantity = item.quantity
      
      cdReceipt.addToItems(cdReceiptItem)
    }
    
    cdReceipt.image = UIImage(cgImage: scanStore.receipts[currentReceipt]).pngData()
    
    try? viewContext.save()
  }
  
  var body: some View {
    BottomSheet(
      isOpen: $scanStore.shouldShowEditForm,
      onDismiss: {
        router.popAll()
      },
      snapPoints: [.fraction(0.5), .small, .fraction(0.8)],
      activeSnap: $snap,
      color: colorScheme == .dark ? .night : .white
    ) {
      ControlledForm(
        defaultValues: [
          "restaurant": FormTextField(value: receipt.name),
          "category": FormTextField(value: receipt.category),
          "total": FormTextField(value: String(receipt.total))
        ]
      ) {
        EditForm(items: $items, onSubmit: onSubmit)
      }
    }
    .onAppear {
      items = receipt.items
    }
  }
}

struct EditForm: View {
  @Environment(\.dismissSheet) private var dismissSheet
  @Binding var items: Array<ReceiptItem>
  
  var onSubmit: (FieldValues) -> Void
  
  @State private var isDoneEditing = false
  
  var body: some View {
    ScrollView {
      VStack(alignment: .leading) {
        HStack {
          Spacer()
          Button(action: {
            isDoneEditing = true
          }) {
            Text("Done")
              .bold()
              .foregroundColor(.pinkAccent)
          }
        }
        EditFormFields()
        HStack(alignment: .center) {
          Text("Items")
            .bold()
          Spacer()
          Button(action: {
            items.append(ReceiptItem(name: "", quantity: 1, price: 0.0))
          }) {
            Image(systemName: "plus.circle.fill")
              .resizable()
              .scaledToFit()
              .foregroundStyle(.gray.opacity(0.8))
              .frame(width: 20)
          }
        }
        ForEach(0..<items.count, id: \.self) { index in
          ListField(index: index, initialValue: items[index], onChangeList: { idx, value in
            items[idx] = value
          })
//          if index < items.count {
//            Rectangle()
//              .fill(
//                colorScheme == .dark ? .white : .black
//              )
//              .frame(maxWidth: .infinity, maxHeight: 1)
//          }
        }
        Rectangle().frame(height: 500)
          .foregroundColor(.clear)
      }
      .padding(.horizontal)
      .padding(.top)
    }
    .alert("Are you sure?", isPresented: $isDoneEditing) {
      Button("Cancel", role: .cancel, action: {})
      SubmitButton(action: { data in
        onSubmit(data)
        dismissSheet()
      }) {
        Text("Submit")
      }
    } message: {
      Text("Do you want to submit changes?")
    }
  }
}

private struct EditFormFields: View {
  var body: some View {
    Text("Restaurant")
      .bold()
    ControlledTextField(name: "restaurant", placeholder: "Enter restaurant name")
    Spacer().frame(height: 20)
    Text("Category")
      .bold()
    ControlledTextField(name: "category", placeholder: "Enter category")
    Spacer().frame(height: 20)
    Text("Total")
    ControlledTextField(name: "total", placeholder: "Enter total")
      .keyboardType(.decimalPad)
    Spacer().frame(height: 20)
  }
}

private struct ListField: View {
  @State() private var item: String = ""
  @State() private var price: String = "0.0"
  @State() private var quantity: String = "1"
  
  var index: Int
  var onChangeList: (Int, ReceiptItem) -> Void
  
  init(index: Int, initialValue: ReceiptItem, onChangeList: @escaping (Int, ReceiptItem) -> Void) {
    self._item = State(initialValue: initialValue.name)
    self._price = State(initialValue: String(initialValue.price))
    self._quantity = State(initialValue: String(initialValue.quantity))
    
    self.index = index
    self.onChangeList = onChangeList
  }
  
  var body: some View {
    VStack {
      VStack(alignment: .leading, spacing: 5) {
        Text("Name")
        ListTextField("item.\(index)", text: $item, placeholder: "Enter item name")
      }
      HStack {
        VStack(alignment: .leading, spacing: 5) {
          Text("Quantity")
          ListTextField("quantity.\(index)", text: $quantity, placeholder: "Enter quantity")
            .keyboardType(.numberPad)
        }
        VStack(alignment: .leading, spacing: 5) {
          Text("Price")
          ListTextField("price.\(index)", text: $price, placeholder: "Enter price")
            .keyboardType(.decimalPad)
        }
      }
    }
    .onChange(of: item) { _ in
      let priceFormatter = NumberFormatter()
      priceFormatter.numberStyle = .decimal
      priceFormatter.maximumFractionDigits = 2
      
      let newPrice = Double(truncating: priceFormatter.number(from: price) ?? 0.0)
      
      onChangeList(index, ReceiptItem(name: item, quantity: Double(quantity) ?? 1, price: newPrice))
    }
    .onChange(of: price) { _ in
      let priceFormatter = NumberFormatter()
      priceFormatter.numberStyle = .decimal
      priceFormatter.maximumFractionDigits = 2
      
      let newPrice = Double(truncating: priceFormatter.number(from: price) ?? 0.0)
      
      onChangeList(index, ReceiptItem(name: item, quantity: Double(quantity) ?? 1, price: newPrice))
    }
    .onChange(of: quantity) { _ in
      let priceFormatter = NumberFormatter()
      priceFormatter.numberStyle = .decimal
      priceFormatter.maximumFractionDigits = 2
      
      let newPrice = Double(truncating: priceFormatter.number(from: price) ?? 0.0)
      
      onChangeList(index, ReceiptItem(name: item, quantity: Double(quantity) ?? 1, price: newPrice))
    }
  }
}

private struct ListTextField: View {
  @Environment(\.colorScheme) private var colorScheme
  @FocusState private var isFocused: Bool
  
  @Binding private var text: String
  
  var titleKey: String
  var placeholder: String = ""
  
  init(_ titleKey: String, text: Binding<String>, placeholder: String = "") {
    self.titleKey = titleKey
    self._text = text
    self.placeholder = placeholder
  }
  
  var prompt: Text {
    Text(placeholder)
      .foregroundColor(
        colorScheme == .dark ? Color.white.opacity(0.6) : Color.black.opacity(0.6)
      )
  }
  
  var body: some View {
    TextField(titleKey, text: $text, prompt: prompt)
      .focused($isFocused)
      .textFieldStyle(ControlledTextFieldStyle(isFocused: $isFocused))
  }
}

struct ScanEditScreen_Previews: PreviewProvider {
  static var previews: some View {
    ScanEditScreen()
      .environmentObject(ScannerStore(receiptRepo: ReceiptRepository(authStore: AuthStore(), baseUrl: Config.baseUrl)))
  }
}
