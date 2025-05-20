import SwiftData
import SwiftUI

struct AddAccountView: View {
  @Environment(\.modelContext) private var modelContext
  @Environment(\.dismiss) var dismiss

  @State private var accountName: String = ""
  @State private var accountType: AccountType = .savings  // Default to savings
  @State private var initialBalance: Double = 0.0

  // Form validation can be added here
  private var isFormValid: Bool {
    !accountName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
  }

  var body: some View {
    NavigationView {  // To show a title and a cancel/save button in the navigation bar
      Form {
        Section(header: Text("账户信息")) {
          TextField("账户名称 (例如: 招商银行储蓄卡)", text: $accountName)

          Picker("账户类型", selection: $accountType) {
            ForEach(AccountType.allCases, id: \.self) {
              Text($0.rawValue)
            }
          }

          HStack {
            Text("初始余额")
            Spacer()
            TextField("0.00", value: $initialBalance, format: .currency(code: "CNY"))
              .keyboardType(.decimalPad)
              .multilineTextAlignment(.trailing)
          }
        }
      }
      .navigationTitle("添加新账户")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button("取消") {
            dismiss()
          }
        }
        ToolbarItem(placement: .navigationBarTrailing) {
          Button("保存") {
            saveAccount()
            dismiss()
          }
          .disabled(!isFormValid)  // Disable save if form is not valid
        }
      }
    }
  }

  private func saveAccount() {
    let newAccount = Account(name: accountName, type: accountType, balance: initialBalance)
    modelContext.insert(newAccount)
    // SwiftData auto-saves, or explicitly:
    // try? modelContext.save()
  }
}

#Preview {
  AddAccountView()
    .modelContainer(for: [Account.self], inMemory: true)
}
