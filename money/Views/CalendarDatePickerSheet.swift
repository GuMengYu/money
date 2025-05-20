import SwiftUI

struct CalendarDatePickerSheet: View {
  @Binding var selectedDate: Date
  var onCancel: () -> Void
  var onDone: () -> Void
    
    @State private var selectedCat: TransactionType? = nil

  var body: some View {
    NavigationView {
      VStack(spacing: 0) {
        // 顶部操作栏
        HStack {
          Button("取消") { onCancel() }
            .foregroundColor(.blue)
          Spacer()
          Text("时间轴")
            .font(.headline)
          Spacer()
          Button("完成") {
            onDone()
          }
          .foregroundColor(.blue)
        }
        .padding()
        // 系统日历选择器
        Form {
          Section {
            DatePicker(
              "选择日期",
              selection: $selectedDate,
              in: ...Date(),
              displayedComponents: [.date]
            )
            .datePickerStyle(.graphical)
          } header: {
            HStack {
              Text("选择日期")
              Spacer()

              if !Calendar.current.isDateInToday(selectedDate) {
                Button {
                  // 选择今天
                  selectedDate = Date()
                } label: {
                  HStack(spacing: 2) {
                    Text("跳转到今天")
                      .font(.caption)
                    Image(systemName: "arrow.right.to.line")
                      .resizable()
                      .scaledToFit()
                      .frame(width: 10)
                  }
                }
              }
            }
          }
            Section("按类型筛选") {
                Picker("分类", selection: $selectedCat) {
                    Text("所有").tag(nil as TransactionType?)

                    ForEach(TransactionType.allCases, id: \.self) { type in
                        Text("\(type.rawValue)").tag(type)
                    }
                }
            }
        }

      }
      .background(Color(.systemGroupedBackground))
    }
  }
}

#Preview {
  CalendarDatePickerSheet(selectedDate: .constant(Date()), onCancel: {}, onDone: {})
}
