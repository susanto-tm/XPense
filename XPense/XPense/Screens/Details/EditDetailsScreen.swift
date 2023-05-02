//
//  EditDetailsScreen.swift
//  XPense
//
//  Created by Timothy Alexander on 4/28/23.
//

import Foundation
import SwiftUI

struct EditDetailsScreen: View {
  @EnvironmentObject private var scanStore: ScannerStore
  
  var receipt: CDReceipt
  
  init(receipt: CDReceipt) {
    self.receipt = receipt
  }
  
  var image: UIImage? {
    if receipt.image != nil {
      return UIImage(data: receipt.image!)
    }
    return UIImage(named: "SampleScan")
  }
  
  var body: some View {
    if image != nil {
      ZStack {
        LiveTextOverlay(image: image!)
        VStack {
          Spacer().frame(height: 20)
          HStack {
            Spacer()
            InteractionOverlay()
            Spacer().frame(width: 20)
          }
          Spacer()
        }
        EditDetailsSheet(receipt: receipt)
      }
      .toolbar(.hidden)
      .disableNavigationGestures()
    }
  }
}

struct EditDetailsSheet: View {
  @EnvironmentObject private var scanStore: ScannerStore
  
  @Environment(\.dismiss) private var dismiss
  @Environment(\.managedObjectContext) private var moc
  @Environment(\.colorScheme) private var colorScheme
  
  @State() private var items: Array<ReceiptItem> = []
  
  var receipt: CDReceipt
  
  init(receipt: CDReceipt) {
    self.receipt = receipt
    self._items = State(
      initialValue: receipt
        .items?
        .allObjects
        .map{ item in
          let item = item as! CDReceiptItem
          return ReceiptItem(
            name: item.name ?? "",
            quantity: item.quantity,
            price: item.price
          )
        } ?? [])
  }
  
  private func onSubmit(data: FieldValues) {
    let restaurant = (data["restaurant"] as! FormTextField).value
    let category = (data["category"] as! FormTextField).value
    let total = (data["total"] as! FormTextField).value
    
    receipt.name = restaurant
    receipt.category = category
    receipt.total = Double(total) ?? 0.0
    
    var updatedItems: [CDReceiptItem] = []
    items.forEach { item in
      let cdReceiptItem = CDReceiptItem(context: moc)
      cdReceiptItem.name = item.name
      cdReceiptItem.price = item.price
      cdReceiptItem.quantity = item.quantity
      
      updatedItems.append(cdReceiptItem)
    }
    
    receipt.items = NSSet(array: updatedItems)
    
    try? moc.save()
  }
  
  var body: some View {
    BottomSheet(
      isOpen: $scanStore.shouldShowEditForm,
      onDismiss: {
        dismiss()
      },
      snapPoints: [.fraction(0.5), .small, .fraction(0.8)],
      color: colorScheme == .dark ? .night : .white
    ) {
      ControlledForm(
        defaultValues: [
          "restaurant": FormTextField(value: receipt.name ?? ""),
          "category": FormTextField(value: receipt.category ?? ""),
          "total": FormTextField(value: String(receipt.total))
        ]
      ) {
        EditForm(items: $items, onSubmit: onSubmit)
      }
    }
  }
}
