//
//  moneyApp.swift
//  money
//
//  Created by Yoda on 2025/5/11.
//

import SwiftData
import SwiftUI

@main
struct moneyApp: App {
  @StateObject private var hapticManager = HapticManager()
  var sharedModelContainer: ModelContainer = {
    let schema = Schema([
      Account.self,
      TransactionCategory.self,
      TransactionRecord.self,
    ])
    let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

    do {
      return try ModelContainer(for: schema, configurations: [modelConfiguration])
    } catch {
      fatalError("Could not create ModelContainer: \(error)")
    }
  }()

  var body: some Scene {
    WindowGroup {
      MainTabView()
    }
    .environmentObject(hapticManager)
    .modelContainer(sharedModelContainer)
  }
}
