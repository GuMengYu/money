import CoreLocation  // For location
import MapKit  // For map display in detail view, but CLLocationCoordinate2D is useful here too
import SwiftData
import SwiftUI

struct AddTransactionView: View {
  @Environment(\.modelContext) private var modelContext
  @Environment(\.dismiss) var dismiss

  // Location Manager
  @StateObject private var locationManager = LocationManager()

  // Form State
  @State private var amount: Double = 0.00
  @State private var transactionType: TransactionType = .expense  // Default to expense
  @State private var selectedAccountId: PersistentIdentifier?  // Use optional PersistentIdentifier
  @State private var selectedToAccountId: PersistentIdentifier?  // For transfers
  @State private var selectedCategoryId: PersistentIdentifier?
  @State private var transactionDate: Date = Date()
  @State private var notes: String = ""
  // Location (optional)
  @State private var includeLocation: Bool = false
  // locationCoordinate is now managed by locationManager

  // Fetching data for pickers
  @Query(sort: \Account.name) private var accounts: [Account]
  @Query(sort: \TransactionCategory.name) private var allCategories: [TransactionCategory]

  // Filtered categories based on transaction type
  private var filteredCategories: [TransactionCategory] {
    allCategories.filter { $0.type == transactionType }
  }

  // Form validation
  private var isFormValid: Bool {
    guard amount > 0 else { return false }
    guard selectedAccountId != nil else { return false }
    if transactionType == .transfer {
      guard selectedToAccountId != nil, selectedAccountId != selectedToAccountId else {
        return false
      }
    }
    // Category is optional for transfers, but required for income/expense (can be adjusted)
    if transactionType != .transfer && selectedCategoryId == nil {
      return false
    }
    return true
  }

  var body: some View {
    NavigationView {
      Form {
        Section("主要信息") {
          Picker("交易类型", selection: $transactionType) {
            ForEach(TransactionType.allCases, id: \.self) {
              Text($0.rawValue)
            }
          }
          .onChange(of: transactionType) { _, _ in
            // Reset category when type changes, as categories are type-specific
            selectedCategoryId = nil
            if transactionType != .transfer {
              selectedToAccountId = nil  // Clear toAccount if not a transfer
            }
          }

          HStack {
            Text("金额")
            Spacer()
            TextField("0.00", value: $amount, format: .currency(code: "CNY"))
              .keyboardType(.decimalPad)
              .multilineTextAlignment(.trailing)
          }

          Picker("账户", selection: $selectedAccountId) {
            Text("选择账户").tag(nil as PersistentIdentifier?)
            ForEach(accounts) {
              Text($0.name).tag($0.id as PersistentIdentifier?)
            }
          }

          if transactionType == .transfer {
            Picker("转入账户", selection: $selectedToAccountId) {
              Text("选择转入账户").tag(nil as PersistentIdentifier?)
              ForEach(accounts.filter { $0.id != selectedAccountId }) {  // Exclude the 'from' account
                Text($0.name).tag($0.id as PersistentIdentifier?)
              }
            }
          }

          if transactionType != .transfer {
            Picker("分类", selection: $selectedCategoryId) {
              Text("选择分类").tag(nil as PersistentIdentifier?)
              ForEach(filteredCategories) {
                Text($0.name).tag($0.id as PersistentIdentifier?)
              }
                
                Button {
                    
                } label: {
                HStack {
                  Image(systemName: "plus.circle.fill")
                  Text("新增分类")
                }
              }
                .buttonStyle(.plain)
            }
          }
        }

        Section("可选信息") {
          DatePicker("日期", selection: $transactionDate, displayedComponents: .date)
          TextField("备注 (例如: 和朋友聚餐)", text: $notes, axis: .vertical)

          // Basic Location Toggle (more advanced would involve a map & search)
          Toggle("记录位置", isOn: $includeLocation)
            .onChange(of: includeLocation) { _, newValue in
              if newValue {
                locationManager.requestLocationPermission()  // Request permission if not already handled
                // If permission is already granted, request location directly
                if locationManager.authorizationStatus == .authorizedWhenInUse
                  || locationManager.authorizationStatus == .authorizedAlways
                {
                  locationManager.requestLocation()
                }
              } else {
                // User toggled off, clear any fetched location if desired
                // locationManager.locationCoordinate = nil // Or just don't use it
              }
            }

          if includeLocation {
            VStack(alignment: .leading) {
              if locationManager.isLoading {
                HStack {
                  ProgressView()
                  Text("正在获取位置...")
                }
              } else if let coordinate = locationManager.locationCoordinate {
                Text(
                  "纬度: \(coordinate.latitude, specifier: "%.4f"), 经度: \(coordinate.longitude, specifier: "%.4f")"
                )
                .font(.caption)
              } else if locationManager.locationError != nil {
                Text("获取位置失败。请检查定位服务设置。")
                  .font(.caption)
                  .foregroundColor(.red)
              } else if locationManager.authorizationStatus == .denied
                || locationManager.authorizationStatus == .restricted
              {
                Text("位置权限被拒绝。请在设置中开启。")
                  .font(.caption)
                  .foregroundColor(.orange)
              } else if locationManager.authorizationStatus == .notDetermined {
                Button("授权并获取位置") {
                  locationManager.requestLocationPermission()  // Should trigger request, then requestLocation if granted
                }
                .font(.caption)
              } else {
                Text("点击开关以获取当前位置。")
                  .font(.caption)
                  .foregroundColor(.gray)
              }
            }
          }
        }
      }
      .navigationTitle("添加交易")
      .navigationBarTitleDisplayMode(.inline)
      
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button("取消") { dismiss() }
        }
        ToolbarItem(placement: .navigationBarTrailing) {
          Button("保存") {
            saveTransaction()
            dismiss()
          }
          .disabled(!isFormValid)
        }
      }
    }
  }

  private func saveTransaction() {
    guard let fromAccountID = selectedAccountId,
      let fromAccount = accounts.first(where: { $0.id == fromAccountID })
    else {
      print("Error: From account not found or not selected.")
      return
    }

    var toAccountValue: Account? = nil
    if transactionType == .transfer {
      guard let toAccID = selectedToAccountId,
        let fetchedToAccount = accounts.first(where: { $0.id == toAccID })
      else {
        print("Error: To account not found or not selected for transfer.")
        return
      }
      toAccountValue = fetchedToAccount
    }

    var categoryValue: TransactionCategory? = nil
    if transactionType != .transfer, let catID = selectedCategoryId,
      let fetchedCategory = allCategories.first(where: { $0.id == catID })
    {
      categoryValue = fetchedCategory
    }

    // 创建新交易记录
    let newTransaction = TransactionRecord(
      amount: amount,
      transactionType: transactionType,
      date: transactionDate,
      notes: notes.isEmpty ? nil : notes,
      latitude: includeLocation ? locationManager.locationCoordinate?.latitude : nil,
      longitude: includeLocation ? locationManager.locationCoordinate?.longitude : nil,
      account: fromAccount,
      toAccount: toAccountValue,
      category: categoryValue
    )

    // 更新账户余额
    updateAccountBalances(for: newTransaction)

    // 保存交易记录
    modelContext.insert(newTransaction)
  }

  // 根据交易类型更新相关账户的余额
  private func updateAccountBalances(for transaction: TransactionRecord) {
    guard let fromAccount = transaction.account else { return }

    switch transaction.transactionType {
    case .income:
      // 收入：增加账户余额
      fromAccount.balance += transaction.amount

    case .expense:
      // 支出：减少账户余额
      fromAccount.balance -= transaction.amount

    case .transfer:
      // 转账：减少源账户余额，增加目标账户余额
      guard let toAccount = transaction.toAccount else { return }
      fromAccount.balance -= transaction.amount
      toAccount.balance += transaction.amount
    }

    // SwiftData会自动保存对象的更改，不需要显式调用保存
  }
}

#Preview {
  AddTransactionView()
    .modelContainer(
      for: [Account.self, TransactionCategory.self, TransactionRecord.self], inMemory: true)
}
