import SwiftData
import SwiftUI

struct AccountDetailView: View {
  // The account to display details for.
  // Using @Bindable for potential edits directly on this view in the future.
  @Bindable var account: Account

  var body: some View {
    // TODO: Implement account detail view content
    // For now, just display the account name and type as a placeholder.
    Form {
      Section("账户详情") {
        LabeledContent("账户名称", value: account.name)
        LabeledContent("账户类型", value: account.type.rawValue)
        LabeledContent("当前余额") {
          Text(account.balance, format: .currency(code: "CNY"))
            .foregroundColor(account.balance >= 0 ? .green : .red)
        }
      }

      // Placeholder for future transaction list related to this account
      Section("最近交易 (待实现)") {
        Text("此处将显示与此账户相关的交易列表。")
          .foregroundStyle(.gray)
      }
    }
    .navigationTitle(account.name)
    .navigationBarTitleDisplayMode(.inline)  // Or .large, depending on preference
  }
}

// Preview requires a sample account.
#Preview {
  // Create a dummy model container for the preview
  let config = ModelConfiguration(isStoredInMemoryOnly: true)
  let container = try! ModelContainer(for: Account.self, configurations: config)

  // Create a sample account to pass to the detail view
  let sampleAccount = Account(name: "示例银行卡", type: .savings, balance: 12345.67)
  // It's good practice to insert it into the context if your view might interact with it,
  // though for a simple display like this, it might not be strictly necessary for the preview to run.
  // container.mainContext.insert(sampleAccount)

  return NavigationView {  // Wrap in NavigationView for title display in preview
    AccountDetailView(account: sampleAccount)
  }
  .modelContainer(container)  // Provide the container to the preview environment

}
