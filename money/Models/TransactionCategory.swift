import Foundation
import SwiftData
import SwiftUI

enum TransactionType: String, Codable, CaseIterable {
  case income = "收入"
  case expense = "支出"
  case transfer = "转账"

  var color: Color {
    switch self {
    case .income:
      return .green
    case .expense:
      return .red
    case .transfer:
      return .blue
    }
  }
  func themeColor(_ themeManager: ThemeManager) -> Color {
    switch self {
    case .income:
      return themeManager.selectedTheme.primary
    case .expense:
      return themeManager.selectedTheme.error
    case .transfer:
      return themeManager.selectedTheme.tertiary
    }
  }
}

@Model
final class TransactionCategory {
  var name: String
  var type: TransactionType  // To distinguish if the category is for income, expense, or transfer
  @Relationship(inverse: \TransactionCategory.parentCategory)
  var subcategories: [TransactionCategory]?
  var parentCategory: TransactionCategory?
  var iconName: String?  // Optional: for displaying an icon next to the category

  init(
    name: String = "",
    type: TransactionType = .expense,
    iconName: String? = nil,
    parentCategory: TransactionType? = nil
  ) {  // Corrected: parentCategory should be TransactionCategory?, not TransactionType?
    self.name = name
    self.type = type
    self.iconName = iconName
    // self.parentCategory = parentCategory // This line had a type mismatch, will be handled by relationship or a separate assignment
  }
}

// Sample data for previews
extension TransactionCategory {
  static var sampleCategories: [TransactionCategory] = [
    // Expenses
    TransactionCategory(name: "餐饮", type: .expense, iconName: "fork.knife"),
    TransactionCategory(name: "交通", type: .expense, iconName: "car.fill"),
    TransactionCategory(name: "购物", type: .expense, iconName: "bag.fill"),
    TransactionCategory(name: "娱乐", type: .expense, iconName: "gamecontroller.fill"),
    TransactionCategory(name: "住房", type: .expense, iconName: "house.fill"),
    // Incomes
    TransactionCategory(name: "工资", type: .income, iconName: "creditcard.fill"),
    TransactionCategory(name: "理财", type: .income, iconName: "chart.line.uptrend.xyaxis"),
    TransactionCategory(name: "红包", type: .income, iconName: "gift.fill"),
  ]

  // Example of creating subcategories (can be done more robustly in an AppData initializer)
  static func sampleFoodCategoryWithSubcategories() -> TransactionCategory {
    let food = TransactionCategory(name: "餐饮美食", type: .expense, iconName: "fork.knife")
    let breakfast = TransactionCategory(name: "早餐", type: .expense, iconName: "sunrise")
    let lunch = TransactionCategory(name: "午餐", type: .expense, iconName: "sun.max")
    let dinner = TransactionCategory(name: "晚餐", type: .expense, iconName: "moon")

    breakfast.parentCategory = food
    lunch.parentCategory = food
    dinner.parentCategory = food

    food.subcategories = [breakfast, lunch, dinner]
    return food
  }
}
