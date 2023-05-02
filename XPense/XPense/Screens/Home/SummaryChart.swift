//
//  SummaryChart.swift
//  XPense
//
//  Created by Timothy Alexander on 4/30/23.
//

import Foundation
import SwiftUI
import Charts

struct ChartData: Identifiable {
  var id = UUID()
  var day: String
  var total: Double
}

struct SummaryChart: View {
  @Environment(\.colorScheme) private var colorScheme
  
  var receipts: [CDReceipt]
  var calendar: Calendar
  
  init(receipts: [CDReceipt]) {
    let _calendar = Calendar(identifier: .iso8601)
    let (startOfWeek, endOfWeek) = _calendar.currentWeekBoundary() ?? (Date(), Date())
    
    self.receipts = receipts
      .filter { $0.createdAt! >= startOfWeek! && $0.createdAt! <= endOfWeek! }
      .sorted { $0.createdAt! < $1.createdAt! }
    self.calendar = _calendar
  }
  
  var receiptsByDay: [ChartData] {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEEE"
    
    let byDay: [String:Double] = receipts.reduce(into: [:]) { acc, curr in
      let day = formatter.string(from: curr.createdAt!)
      
      if acc.keys.contains(day) {
        acc[day] = acc[day]! + curr.total
      } else {
        acc[day] = curr.total
      }
    }
    
    return byDay.keys.map{
      ChartData(
        day: $0,
        total: byDay[$0]!
      )
    }
  }
  
  var body: some View {
    if !receipts.isEmpty {
      Chart {
        ForEach(receiptsByDay) { data in
          BarMark(
            x: .value("Day", data.day),
            y: .value("Total", data.total)
          )
          .foregroundStyle(
            Color.pinkAccent
          )
        }
      }
    }
  }
}

extension Calendar {
  typealias WeekBoundary = (startOfWeek: Date?, endOfWeek: Date?)
  
  func currentWeekBoundary() -> WeekBoundary? {
    return weekBoundary(for: Date())
  }
  
  func weekBoundary(for date: Date) -> WeekBoundary? {
    let components = dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
    
    guard let startOfWeek = self.date(from: components) else {
      return nil
    }
    
    let endOfWeekOffset = weekdaySymbols.count - 1
    let endOfWeekComponents = DateComponents(day: endOfWeekOffset, hour: 23, minute: 59, second: 59)
    guard let endOfWeek = self.date(byAdding: endOfWeekComponents, to: startOfWeek) else {
      return nil
    }
    
    return (startOfWeek, endOfWeek)
  }
}

struct SummaryChart_Previews: PreviewProvider {
  static var previews: some View {
    SummaryChart(receipts: [])
  }
}
