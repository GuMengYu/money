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
    static func formattedDate(_ date: Date) -> String {
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
}
