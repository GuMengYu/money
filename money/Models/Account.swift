import Foundation
import SwiftData

enum AccountType: String, Codable, CaseIterable {
  case savings = "储蓄账户"
  case credit = "信用账户"
}

@Model
final class Account {
  var name: String
  var type: AccountType
  var balance: Double  // For savings accounts, positive. For credit accounts, often negative (representing debt).
  // Consider adding creationDate, currency, etc. later if needed.

  init(
    name: String = "",
    type: AccountType = .savings,
    balance: Double = 0.0
  ) {
    self.name = name
    self.type = type
    self.balance = balance
  }
}

// Sample data for previews
extension Account {
  static var sampleAccounts: [Account] = [
    Account(name: "招商银行储蓄卡", type: .savings, balance: 10000.0),
    Account(name: "支付宝", type: .savings, balance: 5000.0),
    Account(name: "招商银行信用卡", type: .credit, balance: -2500.0),
  ]
}
