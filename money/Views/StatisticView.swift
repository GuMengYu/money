//
//  StatisticView.swift
//  money
//
//  Created by Yoda on 2025/5/14.
//

import Charts
import SwiftData
import SwiftUI

// 统计时间范围类型
enum TimeRange: String, CaseIterable, Identifiable {
  case day = "日"
  case week = "周"
  case month = "月"
  case year = "年"

  var id: Self { self }
}

// 交易类型过滤
enum TransactionFilter: String, CaseIterable, Identifiable {
  case income = "收入"
  case expense = "支出"

  var id: Self { self }
}

struct StatisticView: View {
  @Environment(\.modelContext) private var modelContext

  // 查询所有交易记录
  @Query private var allTransactions: [TransactionRecord]

  // 状态变量
  @State private var selectedTimeRange: TimeRange = .month
  @State private var selectedTransactionType: TransactionFilter = .expense
  @State private var currentDate = Date()
  @State private var selectedCategory: TransactionCategory? = nil

  // 格式化当前显示的时间范围
  private var formattedTimeRange: String {
    let formatter = DateFormatter()

    switch selectedTimeRange {
    case .day:
      formatter.dateFormat = "yyyy年MM月dd日"
      return formatter.string(from: currentDate)
    case .week:
      // 获取当前日期所在周的开始和结束
      let calendar = Calendar.current
      let weekStart = calendar.date(
        from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: currentDate))!
      let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart)!

      formatter.dateFormat = "MM月dd日"
      return "\(formatter.string(from: weekStart)) - \(formatter.string(from: weekEnd))"
    case .month:
      formatter.dateFormat = "yyyy年MM月"
      return formatter.string(from: currentDate)
    case .year:
      formatter.dateFormat = "yyyy年"
      return formatter.string(from: currentDate)
    }
  }

  // 根据当前选择过滤后的交易记录
  private var filteredTransactions: [TransactionRecord] {
    let calendar = Calendar.current

    return allTransactions.filter { transaction in
      // 过滤交易类型（收入/支出）
      let typeMatch: Bool
      switch selectedTransactionType {
      case .income:
        typeMatch = transaction.transactionType == .income
      case .expense:
        typeMatch = transaction.transactionType == .expense
      }

      // 如果类型不匹配，直接返回false
      if !typeMatch {
        return false
      }

      // 过滤时间范围
      let transactionDate = transaction.date

      switch selectedTimeRange {
      case .day:
        // 同一天
        return calendar.isDate(transactionDate, inSameDayAs: currentDate)

      case .week:
        // 同一周
        let currentWeekStart = calendar.date(
          from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: currentDate))!
        let currentWeekEnd = calendar.date(byAdding: .day, value: 6, to: currentWeekStart)!
        return transactionDate >= currentWeekStart && transactionDate <= currentWeekEnd

      case .month:
        // 同一月
        return calendar.component(.year, from: transactionDate)
          == calendar.component(.year, from: currentDate)
          && calendar.component(.month, from: transactionDate)
            == calendar.component(.month, from: currentDate)

      case .year:
        // 同一年
        return calendar.component(.year, from: transactionDate)
          == calendar.component(.year, from: currentDate)
      }
    }
  }

  // 根据分类统计的数据
  private var categoryStats: [(category: TransactionCategory, amount: Double)] {
    // 创建一个字典用于汇总每个分类的金额
    var categorySums: [TransactionCategory: Double] = [:]

    // 进一步过滤选中的分类
    let transactions =
      selectedCategory == nil
      ? filteredTransactions : filteredTransactions.filter { $0.category == selectedCategory }

    // 汇总每个分类的金额
    for transaction in transactions {
      if let category = transaction.category {
        categorySums[category, default: 0] += transaction.amount
      }
    }

    // 将字典转换为数组并按金额排序
    return categorySums.map { (category: $0.key, amount: $0.value) }
      .sorted { $0.amount > $1.amount }
  }

  // 计算总金额
  private var totalAmount: Double {
    filteredTransactions.reduce(0) { $0 + $1.amount }
  }

  // 前进到下一个时间段
  private func moveForward() {
    let calendar = Calendar.current
    switch selectedTimeRange {
    case .day:
      currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
    case .week:
      currentDate = calendar.date(byAdding: .weekOfYear, value: 1, to: currentDate)!
    case .month:
      currentDate = calendar.date(byAdding: .month, value: 1, to: currentDate)!
    case .year:
      currentDate = calendar.date(byAdding: .year, value: 1, to: currentDate)!
    }
  }

  // 后退到上一个时间段
  private func moveBackward() {
    let calendar = Calendar.current
    switch selectedTimeRange {
    case .day:
      currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!
    case .week:
      currentDate = calendar.date(byAdding: .weekOfYear, value: -1, to: currentDate)!
    case .month:
      currentDate = calendar.date(byAdding: .month, value: -1, to: currentDate)!
    case .year:
      currentDate = calendar.date(byAdding: .year, value: -1, to: currentDate)!
    }
  }

  // 重置到当前时间
  private func resetToCurrentDate() {
    currentDate = Date()
  }

  var body: some View {
    ScrollView {
      VStack(spacing: 16) {
        // 顶部控制栏
        HStack {
          // 时间范围选择（日、周、月、年）
          Picker("时间范围", selection: $selectedTimeRange) {
            ForEach(TimeRange.allCases) { range in
              Text(range.rawValue).tag(range)
            }
          }
          .pickerStyle(SegmentedPickerStyle())
          .frame(maxWidth: 220)

          Spacer()

          // 收入/支出切换
          Picker("交易类型", selection: $selectedTransactionType) {
            ForEach(TransactionFilter.allCases) { type in
              Text(type.rawValue).tag(type)
            }
          }
          .pickerStyle(SegmentedPickerStyle())
          .frame(maxWidth: 140)
        }
        .padding(.horizontal)
        .padding(.top, 60)  // 为状态栏留出空间

        // 时间导航控制
        HStack {
          Button(action: moveBackward) {
            Image(systemName: "chevron.left")
              .font(.title3)
          }

          Spacer()

          // 显示当前时间范围
          Text(formattedTimeRange)
            .font(.headline)
            .onTapGesture {
              resetToCurrentDate()
            }

          Spacer()

          Button(action: moveForward) {
            Image(systemName: "chevron.right")
              .font(.title3)
          }
        }
        .padding(.horizontal)

        // 总金额显示
        VStack {
          Text(selectedTransactionType == .income ? "总收入" : "总支出")
            .font(.subheadline)
            .foregroundColor(.secondary)

          Text(totalAmount, format: .currency(code: "CNY"))
            .font(.title.bold())
            .foregroundColor(selectedTransactionType == .income ? .green : .red)
        }
        .padding(.vertical, 8)

        // 分类饼图
        if categoryStats.isEmpty {
          ContentUnavailableView {
            Label("暂无数据", systemImage: "chart.pie")
          } description: {
            Text("当前时间范围内没有\(selectedTransactionType == .income ? "收入" : "支出")记录")
          }
          .frame(height: 300)
        } else {
          VStack(alignment: .leading) {
            Text("分类占比")
              .font(.headline)
              .padding(.horizontal)

            Chart {
              ForEach(categoryStats, id: \.category.id) { item in
                SectorMark(
                  angle: .value("金额", item.amount),
                  innerRadius: .ratio(0.5),
                  angularInset: 1.5
                )
                .foregroundStyle(by: .value("分类", item.category.name))
                .cornerRadius(5)
                .opacity(
                  selectedCategory == item.category ? 1.0 : (selectedCategory == nil ? 1.0 : 0.3))
              }
            }
            .frame(height: 220)
            .chartLegend(position: .bottom, spacing: 20)
            .padding()

            // 分类列表
            ScrollView {
              LazyVStack(alignment: .leading, spacing: 12) {
                ForEach(categoryStats, id: \.category.id) { item in
                  HStack {
                    // 分类名称
                    Text(item.category.name)
                      .font(.subheadline)

                    Spacer()

                    // 金额
                    Text(item.amount, format: .currency(code: "CNY"))
                      .font(.subheadline)
                      .foregroundColor(selectedTransactionType == .income ? .green : .red)

                    // 百分比
                    Text(String(format: "%.1f%%", item.amount / totalAmount * 100))
                      .font(.caption)
                      .foregroundColor(.secondary)
                  }
                  .padding(.vertical, 8)
                  .padding(.horizontal, 16)
                  .background(
                    RoundedRectangle(cornerRadius: 8)
                      .fill(
                        selectedCategory == item.category ? Color.gray.opacity(0.2) : Color.clear)
                  )
                  .contentShape(Rectangle())
                  .onTapGesture {
                    if selectedCategory == item.category {
                      // 再次点击取消选择
                      selectedCategory = nil
                    } else {
                      // 选择该分类
                      selectedCategory = item.category
                    }
                  }
                }
              }
              .padding(.horizontal)
            }
            .frame(maxHeight: 200)
          }
        }

        Spacer()
      }
    }
    .ignoresSafeArea(edges: .top)  // 让内容延伸到状态栏下面
    .navigationTitle("统计分析")
    .navigationBarTitleDisplayMode(.inline)
    .toolbarBackground(.hidden, for: .navigationBar)
    .onAppear {
      // 初始时将时间设为当前时间
      currentDate = Date()
    }
  }
}

#Preview {
  NavigationView {
    StatisticView()
      .modelContainer(
        for: [TransactionRecord.self, Account.self, TransactionCategory.self], inMemory: true)
  }
}
