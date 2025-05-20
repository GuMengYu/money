import CoreLocation  // For location data
import Foundation
import SwiftData

@Model
final class TransactionRecord {
  var amount: Double
  var transactionType: TransactionType  // Enum defined in TransactionCategory.swift
  var date: Date
  var notes: String?

  // Location Data
  var latitude: Double?
  var longitude: Double?

  // Relationships
  var account: Account?  // The account this transaction belongs to
  var toAccount: Account?  // For transfers, the destination account
  var category: TransactionCategory?  // The category of the transaction
  var consumers: [Consumer] = []  // 支持多个消费对象

  init(
    amount: Double = 0.0,
    transactionType: TransactionType = .expense,
    date: Date = Date(),
    notes: String? = nil,
    latitude: Double? = nil,
    longitude: Double? = nil,
    account: Account? = nil,
    toAccount: Account? = nil,  // for transfers
    category: TransactionCategory? = nil,
    consumers: [Consumer] = []  // 新增
  ) {
    self.amount = amount
    self.transactionType = transactionType
    self.date = date
    self.notes = notes
    self.latitude = latitude
    self.longitude = longitude
    self.account = account
    self.toAccount = toAccount
    self.category = category
    self.consumers = consumers  // 新增
  }

  // Computed property to get CLLocationCoordinate2D if lat/lon exist
  var coordinate: CLLocationCoordinate2D? {
    if let lat = latitude, let lon = longitude {
      return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
    return nil
  }
}

// Sample Data for Previews
extension TransactionRecord {
  static var sampleTransactions: [TransactionRecord] = [
    TransactionRecord(
      amount: 50.0, transactionType: .expense, date: Date().addingTimeInterval(-86400 * 5),
      notes: "午餐 - 肯德基", account: Account.sampleAccounts[0],
      category: TransactionCategory.sampleCategories[0]),
    TransactionRecord(
      amount: 1200.0, transactionType: .income, date: Date().addingTimeInterval(-86400 * 10),
      notes: "工资", account: Account.sampleAccounts[0],
      category: TransactionCategory.sampleCategories[5]),
    TransactionRecord(
      amount: 35.0, transactionType: .expense, date: Date().addingTimeInterval(-86400 * 2),
      notes: "地铁票", account: Account.sampleAccounts[1],
      category: TransactionCategory.sampleCategories[1]),
    TransactionRecord(
      amount: 500.0, transactionType: .transfer, date: Date().addingTimeInterval(-86400 * 1),
      notes: "从招行转到支付宝", account: Account.sampleAccounts[0], toAccount: Account.sampleAccounts[1]),
  ]
}
