//
//  TimelineView.swift
//  money
//
//  Created by Yoda on 2025/5/11.
//

import AudioToolbox
import MapKit
import SwiftData
import SwiftUI

struct RecordTimelineView: View {
  @Environment(\.modelContext) private var modelContext
  // Query for transactions, sorted by date, newest first.
  // Grouping will be handled in the View logic.
  @Query(sort: [SortDescriptor(\TransactionRecord.date, order: .reverse)])
  private var allTransactions: [TransactionRecord]

  @State private var showingAddTransactionSheet = false
  @State private var selectedTransaction: TransactionRecord? = nil

  // Search and Filter State
  @State private var searchText: String = ""
  @State private var selectedTransactionTypeFilter: TransactionType? = nil  // nil for no filter

  // Computed property for filtered and searched transactions
  private var filteredTransactions: [TransactionRecord] {
    let calendar = Calendar.current
    let startOfSelectedDay = calendar.startOfDay(for: selectedDate)
    let endOfSelectedDay = calendar.date(byAdding: .day, value: 1, to: startOfSelectedDay)!
    return allTransactions.filter { transaction in
      transaction.date >= startOfSelectedDay && transaction.date < endOfSelectedDay
    }
  }

  @State private var selectedDate: Date = Date()
  @State private var showCalendar: Bool = true

  @State private var showDeleteAlert = false
  @State private var transactionToDelete: TransactionRecord? = nil

  var body: some View {
    NavigationStack {
      ZStack(alignment: .bottomTrailing) {

        ScrollView {
          VStack {
            CustomWeekCalendar(selectedDate: $selectedDate)
            Divider()
                  .padding(4)
             if filteredTransactions.isEmpty {
              ContentUnavailableView {
                Label(
                  searchText.isEmpty && selectedTransactionTypeFilter == nil ? "暂无交易记录" : "无匹配结果",
                  systemImage: "list.bullet.clipboard"
                )
                .font(.subheadline)
              } description: {
                Text(
                  searchText.isEmpty && selectedTransactionTypeFilter == nil
                    ? "点击右下角的" + "按钮开始记账吧！" : "请尝试更改筛选条件或搜索关键词。")
              }
              .frame(maxHeight: .infinity)
            } else {
              VStack(alignment: .leading) {
                ForEach(filteredTransactions) { transaction in
                  NavigationLink(value: transaction) {
                    TransactionRow(transaction: transaction) {
                      transactionToDelete = transaction
                      showDeleteAlert = true
                    }
                  }
                }
              }
               
            }
          }
          .padding(.horizontal)
        }

        FloatingActionButton(
          action: {
            showingAddTransactionSheet = true
          },
          icon: "plus"
        )
        .padding()
      }
      .navigationTitle("今天")
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button(action: {

          }) {
            Image(systemName: "magnifyingglass")
          }
        }
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {

          } label: {
            Image(systemName: "calendar")
          }
        }
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {

          } label: {
            Image(systemName: "ellipsis.circle")
          }
        }
        //        ToolbarItem(placement: .navigationBarTrailing) {
        //          Picker(
        //            selection: $selectedTransactionTypeFilter,
        //            label: {
        //              Image(systemName: "line.3.horizontal.decrease.circle")
        //            }
        //          ) {
        //            Text("全部").tag(nil as TransactionType?)
        //            ForEach(TransactionType.allCases, id: \.self) {
        //              Text($0.rawValue).tag($0 as TransactionType?)
        //            }
        //          }
        //        }
      }
      .navigationDestination(for: TransactionRecord.self) { transaction in
        TransactionDetailView(transaction: transaction)
      }
      .sheet(isPresented: $showingAddTransactionSheet) {
        AddTransactionView()
      }
      .alert("确定要删除这条记录吗？", isPresented: $showDeleteAlert, presenting: transactionToDelete) {
        transaction in
        Button("删除", role: .destructive) {
          deleteTransaction(transaction)
          // // 播放删除反馈
          // let generator = UINotificationFeedbackGenerator()
          // generator.notificationOccurred(.success)
          // 播放删除声音
          AudioServicesPlaySystemSound(4095)  // 系统删除音效
        }
        Button("取消", role: .cancel) {}
      } message: { _ in
        Text("删除后无法恢复。")
      }
    }
  }

  // Helper function to group transactions by date (ignoring time component for grouping by day)
  private func groupTransactionsByDate(_ transactions: [TransactionRecord]) -> [Date:
    [TransactionRecord]]
  {
    let calendar = Calendar.current
    return Dictionary(grouping: transactions) { transaction in
      calendar.startOfDay(for: transaction.date)
    }
  }

  // 删除交易并更新相关账户余额
  private func deleteTransaction(_ transaction: TransactionRecord) {

    // 在删除交易前，先反向更新相关账户的余额
    reverseAccountBalanceUpdates(for: transaction)

    // 删除交易
    withAnimation {
      modelContext.delete(transaction)
    }
  }

  // 反向更新账户余额（删除交易时使用）
  private func reverseAccountBalanceUpdates(for transaction: TransactionRecord) {
    guard let account = transaction.account else { return }

    switch transaction.transactionType {
    case .income:
      // 删除收入：减少账户余额
      account.balance -= transaction.amount

    case .expense:
      // 删除支出：增加账户余额
      account.balance += transaction.amount

    case .transfer:
      // 删除转账：增加源账户余额，减少目标账户余额
      guard let toAccount = transaction.toAccount else { return }
      account.balance += transaction.amount
      toAccount.balance -= transaction.amount
    }
  }
}

// A simple Floating Action Button View
struct FloatingActionButton: View {
  let action: () -> Void
  let icon: String

  var body: some View {
    Button(action: action) {
      Image(systemName: icon)
        .resizable()
        .scaledToFit()
        .frame(width: 24, height: 24)
        .padding()
    }
    .background(Color.blue)
    .foregroundColor(.white)
    .clipShape(Circle())
    .shadow(radius: 5)
  }
}

// 每日汇总标题视图
struct DailySummaryHeader: View {
  let date: Date
  let transactions: [TransactionRecord]

  // 计算当日收入总额
  private var totalIncome: Double {
    transactions
      .filter { $0.transactionType == .income }
      .reduce(0) { $0 + $1.amount }
  }

  // 计算当日支出总额
  private var totalExpense: Double {
    transactions
      .filter { $0.transactionType == .expense }
      .reduce(0) { $0 + $1.amount }
  }

  // 计算当日结余（收入-支出）
  private var dailyBalance: Double {
    totalIncome - totalExpense
  }

  // 判断日期是否在当前年份
  private func isCurrentYear(_ date: Date) -> Bool {
    let calendar = Calendar.current
    let dateYear = calendar.component(.year, from: date)
    let currentYear = calendar.component(.year, from: Date())
    return dateYear == currentYear
  }

  // 格式化日期显示
  private func formattedDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "zh_CN")

    // 获取星期几
    let weekdayFormatter = DateFormatter()
    weekdayFormatter.dateFormat = "EEEE"  // 使用完整格式，如"星期一"
    weekdayFormatter.locale = Locale(identifier: "zh_CN")
    let weekday = weekdayFormatter.string(from: date)

    if isCurrentYear(date) {
      // 当年只显示月日
      formatter.dateFormat = "MM月dd日"
    } else {
      // 非当年显示年月日
      formatter.dateFormat = "yyyy年MM月dd日"
    }
    return formatter.string(from: date) + " " + weekday
  }

  var body: some View {
    VStack(alignment: .leading) {
      Text(formattedDate(date))
        .font(.caption)
        .foregroundStyle(.primary)

      // 显示收支统计信息
      HStack(spacing: 8) {
        // 收入
        Text("收:")
        Text("\(totalIncome, format: .currency(code: "CNY"))")
          .foregroundColor(.green)

        // 支出
        Text("支:")
        Text("\(totalExpense, format: .currency(code: "CNY"))")
          .foregroundColor(.red)

        // 结余
        Text("余:")
        Text(
          dailyBalance >= 0
            ? "+\(dailyBalance, format: .currency(code: "CNY"))"
            : "\(dailyBalance, format: .currency(code: "CNY"))"
        )
        .foregroundColor(dailyBalance >= 0 ? .green : .red)
      }
      .foregroundColor(.secondary)
      .font(.caption)
    }
  }
}

#Preview {

  let preview = Preview()
  preview.addExamples(TransactionRecord.sampleItems)

  return RecordTimelineView()
    .modelContainer(preview.modelContainer)
    .environmentObject(HapticManager())
}

struct Preview {

  let modelContainer: ModelContainer
  init() {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    do {
      modelContainer = try ModelContainer(for: TransactionRecord.self, configurations: config)
    } catch {
      fatalError("Could not initialize ModelContainer")
    }
  }

  func addExamples(_ examples: [TransactionRecord]) {

    Task { @MainActor in
      examples.forEach { example in
        modelContainer.mainContext.insert(example)
      }
    }

  }
}
