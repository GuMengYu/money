//
//  TransactionSamples.swift
//  money
//
//  Created by Yoda on 2025/5/16.
//

import Foundation

extension TransactionRecord {
  static var sampleItems: [TransactionRecord] {
    [
      TransactionRecord(
        amount: 3412.0,
        transactionType: .expense,
        date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
        notes: "10月的房租",
        latitude: 40.826344,
        longitude: 111.757935,  // for transfers
        account: Account(name: "微信", type: .savings, balance: 31200.89),
        category: TransactionCategory(
          name: "住房", type: TransactionType.expense, iconName: "house.fill")
      ),
      TransactionRecord(
        amount: 10002.68,
        transactionType: .income,
        date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
        notes: "10月的工资",
        latitude: 40.826344,
        longitude: 111.757935,  // for transfers
        account: Account(name: "微信", type: .savings, balance: 31200.89),
        category: TransactionCategory(
          name: "工资", type: TransactionType.expense, iconName: "dollarsign")
      ),
      TransactionRecord(
        amount: 56.0,
        transactionType: .expense,
        date: Date(),
        latitude: 40.826344,
        longitude: 111.757935,  // for transfers
        category: TransactionCategory(
          name: "晚餐", type: TransactionType.expense, iconName: "fork.knife")
      ),
      TransactionRecord(
        amount: 6.0,
        transactionType: .expense,
        date: Date(),
        latitude: 40.826344,
        longitude: 111.757935,  // for transfers
        category: TransactionCategory(
          name: "早餐", type: TransactionType.expense, iconName: "fork.knife")
      ),
      TransactionRecord(
        amount: 100.0,
        transactionType: .income,
        date: Date(),
        notes: "出差交通补贴, 长文本 长文本 长文本 长文本 长文本 长文本 长文本 长文本",
        latitude: 40.826344,
        longitude: 111.757935,  // for transfers
        category: TransactionCategory(
          name: "补贴", type: TransactionType.expense, iconName: "gift")
      ),
      TransactionRecord(
        amount: 15239.0,
        transactionType: .income,
        date: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(),
        notes: "5月工资+奖金",
        latitude: 40.826344,
        longitude: 111.757935,  // for transfers
        category: TransactionCategory(
          name: "工资", type: TransactionType.expense, iconName: "dollarsign")
      ),
      TransactionRecord(
        amount: 15239.0,
        transactionType: .income,
        date: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(),
        notes: "5月工资+奖金",
        latitude: 40.826344,
        longitude: 111.757935,  // for transfers
        category: TransactionCategory(
          name: "工资", type: TransactionType.expense, iconName: "dollarsign")
      ),
    ]
  }
}
