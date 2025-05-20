//
//  moneyApp.swift
//  money
//
//  Created by Yoda on 2025/5/11.
//

import SwiftData
import SwiftUI
import TipKit

@main
struct moneyApp: App {
  @StateObject private var hapticManager = HapticManager()
    @StateObject private var sheetManager = SheetManager()
    @StateObject private var themeManager = ThemeManager()
    let sharedModelContainer: ModelContainer
    @AppStorage("colorScheme") private var colorScheme: String = "system"  // 保存主题偏好
    var appColorScheme: ColorScheme? {
      // 返回对应的颜色模式
      switch colorScheme {
      case "light": return .light
      case "dark": return .dark
      default: return nil  // 跟随系统设置
      }
    }
    
    init() {
      do {
        let schema = Schema([Consumer.self,
                              Account.self,
                              TransactionCategory.self,
                              TransactionRecord.self,])
        let isEnabled = UserDefaults.standard.bool(forKey: "iCloudSyncEnabled")
        let modelConfiguration = ModelConfiguration(
          schema: schema,
          isStoredInMemoryOnly: false,
          cloudKitDatabase: isEnabled ? .automatic : .none
        )
          sharedModelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
      } catch {
        fatalError("Could not initialize ModelContainer")
      }
      try? Tips.configure()
    }

  var body: some Scene {
    WindowGroup {
      MainTabView()
        .onAppear {
            let context = sharedModelContainer.mainContext
            insertDefaultDataIfNeeded(context: context)
        }
        .sheet(isPresented: $sheetManager.isPresented) {
          sheetManager.content.environmentObject(sheetManager)
        }
        .preferredColorScheme(appColorScheme)
    }
    .environmentObject(hapticManager)
    .environmentObject(themeManager)
    .environmentObject(sheetManager)
    .modelContainer(sharedModelContainer)
  }

  func insertDefaultDataIfNeeded(context: ModelContext) {
    // 检查是否已有分类、账户、消费对象
    let categoryCount =
      (try? context.fetch(FetchDescriptor<TransactionCategory>())).map { $0.count } ?? 0
    let accountCount = (try? context.fetch(FetchDescriptor<Account>())).map { $0.count } ?? 0
    let consumerCount = (try? context.fetch(FetchDescriptor<Consumer>())).map { $0.count } ?? 0

    if categoryCount == 0 {
      let categories = [
        TransactionCategory(name: "餐饮", type: .expense, iconName: "fork.knife"),
        TransactionCategory(name: "交通", type: .expense, iconName: "car.fill"),
        TransactionCategory(name: "购物", type: .expense, iconName: "bag.fill"),
        TransactionCategory(name: "娱乐", type: .expense, iconName: "gamecontroller.fill"),
        TransactionCategory(name: "工资", type: .income, iconName: "creditcard.fill"),
        TransactionCategory(name: "理财", type: .income, iconName: "chart.line.uptrend.xyaxis"),
        TransactionCategory(name: "转账", type: .transfer, iconName: "arrow.right.arrow.left"),
      ]
      categories.forEach { context.insert($0) }
    }

    if accountCount == 0 {
      let accounts = [
        Account(name: "招商银行储蓄卡", type: .savings, balance: 10000.0),
        Account(name: "支付宝", type: .savings, balance: 5000.0),
      ]
      accounts.forEach { context.insert($0) }
    }

    if consumerCount == 0 {
      let consumers = [
        Consumer(name: "自己", isDefault: true),
        Consumer(name: "妈妈"),
        Consumer(name: "爸爸"),
        Consumer(name: "老婆"),
      ]
      consumers.forEach { context.insert($0) }
    }
  }
}
