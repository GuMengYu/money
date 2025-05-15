import SwiftData
import SwiftUI

struct AccountsView: View {
  @Environment(\.modelContext) private var modelContext
  @Query(sort: \Account.name) private var accounts: [Account]  // Sort accounts by name

  @State private var showingAddAccountSheet = false

  var body: some View {
    NavigationView {  // Use NavigationView for title and potential navigation links
      List {
        ForEach(accounts) { account in
          NavigationLink(destination: AccountDetailView(account: account)) {
            AccountRow(account: account)
          }
        }
        .onDelete(perform: deleteAccounts)
      }
      .navigationTitle("账户")
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            showingAddAccountSheet = true
          } label: {
            Label("添加账户", systemImage: "plus.circle.fill")
          }
        }
      }
      .sheet(isPresented: $showingAddAccountSheet) {
        AddAccountView()
      }
      // Placeholder for empty state
      .overlay {
        if accounts.isEmpty {
          ContentUnavailableView(
            "暂无账户", systemImage: "creditcard.fill", description: Text("点击右上角" + "按钮添加一个新账户。"))
        }
      }
    }
  }

  private func deleteAccounts(offsets: IndexSet) {
    withAnimation {
      offsets.map { accounts[$0] }.forEach(modelContext.delete)
      // SwiftData automatically saves changes, or you can explicitly save if needed:
      // try? modelContext.save()
    }
  }
}

struct AccountRow: View {
  let account: Account

  var body: some View {
    HStack {
      VStack(alignment: .leading) {
        Text(account.name)
          .font(.headline)
        Text(account.type.rawValue)
          .font(.subheadline)
          .foregroundStyle(.gray)
      }
      Spacer()
      Text(account.balance, format: .currency(code: "CNY"))  // Assuming CNY for now
        .font(.title3)
        .foregroundColor(account.balance >= 0 ? .green : .red)
    }
  }
}

#Preview {
  // For the preview to work correctly with SwiftData, you might need to set up a sample model container.
  // This is a simplified preview.
  AccountsView()
    .modelContainer(for: [Account.self], inMemory: true)  // Basic in-memory container for preview
}
