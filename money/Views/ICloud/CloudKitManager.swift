import CloudKit
import Foundation
import SwiftData

@Observable
class CloudKitManager {
  static let shared = CloudKitManager()

  private let container = CKContainer.default()
  var syncStatus: String = "未连接"
  var isSyncing: Bool = false
  var isEnabled: Bool {
    get {
      UserDefaults.standard.bool(forKey: "iCloudSyncEnabled")
    }
    set {
      UserDefaults.standard.set(newValue, forKey: "iCloudSyncEnabled")
    }
  }
  var lastSyncDate: Date? {
    get {
      UserDefaults.standard.object(forKey: "lastSyncDate") as? Date
    }
    set {
      UserDefaults.standard.set(newValue, forKey: "lastSyncDate")
    }
  }

  private init() {
    checkAccountStatus()
  }

  func checkAccountStatus() {
    container.accountStatus { [weak self] status, error in
      DispatchQueue.main.async {
        switch status {
        case .available:
          self?.syncStatus = self?.isEnabled == true ? "已连接" : "已禁用"
        case .noAccount:
          self?.syncStatus = "未登录 iCloud"
        case .restricted:
          self?.syncStatus = "iCloud 访问受限"
        case .couldNotDetermine:
          self?.syncStatus = "无法确定状态"
        case .temporarilyUnavailable:
            self?.syncStatus = "iCloud 暂不可用"
        @unknown default:
          self?.syncStatus = "未知状态"
        }
      }
    }
  }

  func toggleSync() {
    isEnabled.toggle()
    checkAccountStatus()
  }

  @MainActor
  func triggerSync(modelContext: ModelContext) async {
    guard !isSyncing && isEnabled else { return }

    isSyncing = true
    syncStatus = "同步中..."

    do {
      try modelContext.save()
      syncStatus = "同步完成"
      lastSyncDate = Date()

      // 3秒后重置状态
      try await Task.sleep(for: .seconds(3))
      syncStatus = "已连接"
    } catch {
      syncStatus = "同步失败: \(error.localizedDescription)"

      // 3秒后重置状态
      try? await Task.sleep(for: .seconds(3))
      syncStatus = "已连接"
    }

    isSyncing = false
  }
}
