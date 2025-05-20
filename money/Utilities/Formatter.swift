//
//  Formatter.swift
//  money
//
//  Created by Yoda on 2025/5/14.
//
import Foundation

struct CoreFormatter {
  // 判断日期是否在当前年份
  static func isCurrentYear(_ date: Date) -> Bool {
    let calendar = Calendar.current
    let dateYear = calendar.component(.year, from: date)
    let currentYear = calendar.component(.year, from: Date())
    return dateYear == currentYear
  }

  // 格式化日期显示
  static func formattedDate(_ date: Date, week: Bool = true) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale.current

    // 获取星期几
    let weekdayFormatter = DateFormatter()
    weekdayFormatter.dateFormat = "EEEE"
    weekdayFormatter.locale = Locale.current
    let weekday = weekdayFormatter.string(from: date)

    // 检查是否是今天或昨天
    let calendar = Calendar.current
    if calendar.isDateInToday(date) {
      return String(localized: "Today") + (week ? " " + weekday : "")
    } else if calendar.isDateInYesterday(date) {
      return String(localized: "Yesterday") + (week ? " " + weekday : "")
    }

    if isCurrentYear(date) {
      // 当年只显示月日
      formatter.dateFormat = String(localized: "MMM d")
    } else {
      // 非当年显示年月日
      formatter.dateFormat = String(localized: "yyyy MMM d")
    }
    return formatter.string(from: date) + (week ? " " + weekday : "")
  }
  static func time(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "zh_CN")
    formatter.dateFormat = "HH:mm"
    return formatter.string(from: date)
  }
  static func formatNumber(_ value: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.minimumFractionDigits = 2
    formatter.maximumFractionDigits = 2
    return formatter.string(from: NSNumber(value: value)) ?? "0.00"
  }
}
