import SwiftUI

struct CustomWeekCalendar: View {
  @State var displayedWeek: Date = Calendar.current.startOfWeek(for: Date())
  @EnvironmentObject var hapticManager: HapticManager

  let calendar = Calendar.current
  @Binding var selectedDate: Date
  var body: some View {
    VStack {
      ScrollViewReader { proxy in
        ScrollView(.horizontal) {
          HStack(spacing: 4) {
            ForEach(weeks, id: \.self) { weekStart in
              let days = weekGrid(for: weekStart)
              VStack {
                LazyVGrid(
                  columns: Array(repeating: GridItem(.flexible(), spacing: 5), count: 7), spacing: 2
                ) {
                  ForEach(days, id: \.self) { date in
                    // 检查该日期是否为当前选中的日期
                    let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
                    // 检查该日期是否为今天
                    let isToday = calendar.isDateInToday(date)
                    // 获取星期缩写
                    let symbol = weekdaySymbol(for: date)
                    VStack(spacing: 0) {
                      Text("\(calendar.component(.day, from: date))")
                        .font(.system(size: 18).bold())
                        .fontDesign(.rounded)
                        .frame(maxWidth: .infinity)
                      Text(symbol)
                        .font(.system(size: 8))

                        .frame(maxWidth: .infinity)
                    }
                    .padding(.vertical, 8)
                    .opacity(isSelected || isToday ? 1 : 1)
                    .background(
                      isSelected ? .blue.opacity(0.2) : .gray.opacity(0.1),
                      in: .rect(cornerRadius: 14)
                    )
                    .overlay(
                      RoundedRectangle(cornerRadius: 14).stroke(lineWidth: 1.5)
                        // 现在所有日期都有边框线，但我只想让当天有。只为当天加线，方便用户识别今天。
                        .foregroundStyle(isToday ? Color.accentColor : .clear)
                        .padding(1)
                    )
                    .onTapGesture {
                        hapticManager.selectionChanged()

                      selectedDate = date
                    }
                  }
                }.containerRelativeFrame(.horizontal)
              }
              .id(weekStart)
            }
          }
          .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
              proxy.scrollTo(displayedWeek, anchor: .center)
            }
          }
          .scrollTargetLayout()

        }
        .scrollTargetBehavior(.viewAligned)
        .scrollIndicators(.hidden)
      }
    }
  }

  // This function returns a short uppercase string for the weekday of a given date.
  // Example: If the date is a Monday, it returns "MON".
  private func weekdaySymbol(for date: Date) -> String {
    // Extract the weekday component from the given date.
    // .weekday returns an Int from 1 (Sunday) to 7 (Saturday).
    let weekdayIndex = calendar.component(.weekday, from: date) - 1
    // calendar.shortWeekdaySymbols is an array like ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"].
    // We use 'weekdayIndex' to get the symbol for the date.
    // .prefix(3) ensures we only get the first 3 letters (e.g., "Mon"), though this is often already 3.
    // .uppercased() converts it to uppercase for display style (e.g., "MON").
    return calendar.shortWeekdaySymbols[weekdayIndex].prefix(3).uppercased()
  }

  // This computed property returns an array of `Date` values,
  // each representing the starting date of a week.
  // It creates a range of weeks around the current week (past 12 and next 12 weeks).
  private var weeks: [Date] {
    // Get the current date.
    let current = Date()

    // Initialize an empty array to store the week's start dates.
    var result: [Date] = []

    // Loop through -12 to +12, representing 12 weeks before and after today.
    for i in -12...12 {
      // For each value of `i`, calculate the date that is `i` weeks away from the current week's start.
      // `calendar.date(byAdding:to:)` adds time components (like weeks) to a date.
      // `calendar.startOfWeek(for:)` gives the Monday (or Sunday based on locale) of that week.
      if let weekStart = calendar.date(
        byAdding: .weekOfYear, value: i, to: calendar.startOfWeek(for: current))
      {
        // Append the calculated week start date to the result array.
        result.append(weekStart)
      }
    }

    // Return the list of week start dates.
    return result
  }

  // This function creates a readable title for a week based on a date.
  // Example output: "April 23"
  private func weekTitle(for date: Date) -> String {
    // Create an instance of DateFormatter, which converts dates into strings.
    let formatter = DateFormatter()
    // Set the format to show the full month name and day number.
    // "MMMM" = full month name (e.g., "April")
    // "d" = day of the month (e.g., "23")
    formatter.dateFormat = "MMMM d"
    // Convert the given date into a string using the formatter and return it.
    return formatter.string(from: date)
  }

  // This function returns an array of 7 dates starting from the given `weekStart` date.
  // This represents all the days of that week.
  private func weekGrid(for weekStart: Date) -> [Date] {
    // Create a range from 0 to 6 (representing 7 days in a week).
    // For each number `i`, add `i` days to the `weekStart` date.
    return (0..<7).compactMap {
      // Use the Calendar to calculate each day of the week.
      calendar.date(byAdding: .day, value: $0, to: weekStart)
    }
  }

}

// 扩展内置 Calendar 类型，添加自定义辅助函数
extension Calendar {
  // 返回包含指定日期的那一周的起始日（通常是周一或周日，取决于地区设置）
  func startOfWeek(for date: Date) -> Date {
    // 提取指定日期的年份和周数
    // .yearForWeekOfYear 表示该周对应的年份（ISO 8601 风格）
    // .weekOfYear 表示该日期在当年的第几周
    let components = dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
    // 用这些组件构造一个新的日期，表示该周的起始日
    // 如果失败（极少见），则返回原始日期
    return self.date(from: components) ?? date
  }
}

#Preview {
  @Previewable @State var selection: Date = Date()

  CustomWeekCalendar(selectedDate: $selection)
}
