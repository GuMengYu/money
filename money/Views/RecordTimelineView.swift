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
import FluidGradient

class RecordTimelineViewModel: ObservableObject {
  @EnvironmentObject var themeManager: ThemeManager

  @Published var transactions: [TransactionRecord] = []
  @Published var isLoading: Bool = false

  private var modelContext: ModelContext?

  func setContextIfNeeded(_ context: ModelContext) {
    if modelContext == nil {
      modelContext = context
    }
  }

  func fetchTransactions(for date: Date) {
    guard let modelContext else { return }
    let calendar = Calendar.current
    let startOfDay = calendar.startOfDay(for: date)
    let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
    let descriptor = FetchDescriptor<TransactionRecord>(
      predicate: #Predicate { $0.date >= startOfDay && $0.date < endOfDay },
      sortBy: [SortDescriptor(\TransactionRecord.date, order: .reverse)]
    )
    var loadingTask: Task<Void, Never>? = nil
    Task {
      // 500ms后才显示loading（只有未被取消时才设置）
      loadingTask = Task { @MainActor in
        try? await Task.sleep(nanoseconds: 500_000_000)
        if !Task.isCancelled {
          self.isLoading = true
        }
      }
      let result = try? modelContext.fetch(descriptor)
      loadingTask?.cancel()
      await MainActor.run {
        self.transactions = result ?? []
        self.isLoading = false
      }
    }
  }
}

struct RecordTimelineView: View {
  @Environment(\.modelContext) private var modelContext
  @Environment(\.colorScheme) private var colorScheme
  @EnvironmentObject var themeManager: ThemeManager
  @StateObject private var viewModel: RecordTimelineViewModel
  @State private var showingAddTransactionSheet = false
  @State private var selectedTransaction: TransactionRecord? = nil
  @State private var searchText: String = ""
  @State private var selectedTransactionTypeFilter: TransactionType? = nil
  @State private var selectedDate: Date = Date()
  @State private var showCalendar: Bool = true
  @State private var showDeleteAlert = false
  @State private var transactionToDelete: TransactionRecord? = nil
  @State private var showCalendarSheet = false
  @State private var tempSelectedDate: Date = Date()

  init() {
    _viewModel = StateObject(wrappedValue: RecordTimelineViewModel())
  }
    
    var theme: Theme {
        themeManager.selectedTheme
    }

  var body: some View {
    NavigationStack {
      ZStack(alignment: .topLeading) {
        // 渐变背景
        LinearGradient(
          gradient: Gradient(colors: [
            themeManager.selectedTheme.primary.opacity(colorScheme == .dark ? 0.2 : 0.3),
            themeManager.selectedTheme.primary.opacity(0.15),
            themeManager.selectedTheme.primary.opacity(0.1),
          ]),
          startPoint: .topLeading,
          endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        // 主要内容
        ZStack(alignment: .bottomTrailing) {
          VStack {
            CustomWeekCalendar(selectedDate: $selectedDate)
            Divider()
              .padding(4)
            if viewModel.isLoading {
              ProgressView("加载中...")
                .frame(maxWidth: .infinity, minHeight: 200)
            } else if viewModel.transactions.isEmpty {
              ContentUnavailableView {
                Label(
                  searchText.isEmpty && selectedTransactionTypeFilter == nil ? "暂无交易记录" : "无匹配结果",
                  systemImage: "list.bullet.clipboard"
                )
                .font(.subheadline)
              }
              .frame(maxHeight: .infinity)
            } else {
              ScrollView {

                VStack(alignment: .leading) {
                  ForEach(viewModel.transactions) { transaction in
                    NavigationLink(value: transaction) {
                      TransactionRow(transaction: transaction) {
                        transactionToDelete = transaction
                        showDeleteAlert = true
                      }
                    }
                  }
                }
              }
              .scrollIndicators(.hidden)
            }
          }
          .padding(.horizontal)

          FloatingActionButton(
            action: {
              showingAddTransactionSheet = true
            },
            icon: "plus"
          )
          .padding()
        }
      }
      .navigationTitle(CoreFormatter.formattedDate(selectedDate, week: false))
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button(action: {
          }) {
            Image(systemName: "magnifyingglass")
          }
        }
        #if DEBUG
          ToolbarItem(placement: .navigationBarTrailing) {
            NavigationLink(value: "playground") {
              Image(systemName: "apple.image.playground")
            }
          }
        #endif
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            tempSelectedDate = selectedDate
            showCalendarSheet = true
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
      }
      .navigationDestination(for: TransactionRecord.self) { transaction in
        TransactionDetailView(transaction: transaction)
      }
      .navigationDestination(for: String.self) { target in
        if target == "playground" {
          PlaygroundView()
        }
      }
      .sheet(isPresented: $showingAddTransactionSheet) {
        AddTransactionView(onComplete: {
          viewModel.fetchTransactions(for: selectedDate)
        })
      }
      .sheet(isPresented: $showCalendarSheet) {
        CalendarDatePickerSheet(
          selectedDate: $tempSelectedDate,
          onCancel: { showCalendarSheet = false },
          onDone: {
            selectedDate = tempSelectedDate
            showCalendarSheet = false
          }
        )
      }
      .alert("确定要删除这条记录吗？", isPresented: $showDeleteAlert, presenting: transactionToDelete) {
        transaction in
        Button("删除", role: .destructive) {
          deleteTransaction(transaction)
          AudioServicesPlaySystemSound(4095)
        }
        Button("取消", role: .cancel) {}
      } message: { _ in
        Text("删除后无法恢复。")
      }
    }
    .onAppear {
      viewModel.setContextIfNeeded(modelContext)
      viewModel.fetchTransactions(for: selectedDate)
    }
    .onChange(of: selectedDate) { _, newDate in
      viewModel.fetchTransactions(for: newDate)
    }
  }

  private func deleteTransaction(_ transaction: TransactionRecord) {
    reverseAccountBalanceUpdates(for: transaction)
    withAnimation {
      modelContext.delete(transaction)
    }
    viewModel.fetchTransactions(for: selectedDate)
  }

  private func reverseAccountBalanceUpdates(for transaction: TransactionRecord) {
    guard let account = transaction.account else { return }
    switch transaction.transactionType {
    case .income:
      account.balance -= transaction.amount
    case .expense:
      account.balance += transaction.amount
    case .transfer:
      guard let toAccount = transaction.toAccount else { return }
      account.balance += transaction.amount
      toAccount.balance -= transaction.amount
    }
  }
}

// A simple Floating Action Button View
struct FloatingActionButton: View {
  @EnvironmentObject var themeManager: ThemeManager

  let action: () -> Void
  let icon: String

  var body: some View {
    Button(action: action) {
      Image(systemName: icon)
        .resizable()
        .scaledToFit()
        .frame(width: 20, height: 20)
    }
    .padding()
    .background(themeManager.selectedTheme.primaryContainer)
    .foregroundColor(themeManager.selectedTheme.onPrimaryContainer)
    .cornerRadius(16)
    .shadow(color: themeManager.selectedTheme.primaryContainer, radius: 4)

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

  let preview = RecordTimelinePreview()
  preview.addExamples(TransactionRecord.sampleItems)

  return RecordTimelineView()
    .modelContainer(preview.modelContainer)
    .environmentObject(HapticManager())
    .environmentObject(ThemeManager())
}

struct RecordTimelinePreview {

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
