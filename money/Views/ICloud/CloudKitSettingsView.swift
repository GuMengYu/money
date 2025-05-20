import SwiftData
import SwiftUI

struct CloudKitSettingsView: View {
  @State private var cloudKitManager = CloudKitManager.shared
  @Environment(\.dismiss) private var dismiss
  @Environment(\.modelContext) private var modelContext

  var body: some View {
    NavigationStack {
      Form {
        Section {
          HStack {
            Text("iCloud 同步")
            Spacer()
            Toggle(
              "",
              isOn: Binding(
                get: { cloudKitManager.isEnabled },
                set: { _ in cloudKitManager.toggleSync() }
              ))
          }

          HStack {
            Text("iCloud 状态")
            Spacer()
            Text(cloudKitManager.syncStatus)
              .foregroundColor(.secondary)
          }

          if let lastSync = cloudKitManager.lastSyncDate {
            HStack {
              Text("上次同步")
              Spacer()
              Text(lastSync, format: .dateTime)
                .foregroundColor(.secondary)
            }
          }

          if cloudKitManager.isEnabled {
            Button(action: {
              Task {
                  await cloudKitManager.triggerSync(modelContext: modelContext)
              }
            }) {
              HStack {
                Text("立即同步")
                Spacer()
                if cloudKitManager.isSyncing {
                  ProgressView()
                    .controlSize(.small)
                } else {
                  Image(systemName: "arrow.triangle.2.circlepath")
                }
              }
            }
            .disabled(cloudKitManager.isSyncing)
          }
        } header: {
          Text("iCloud 设置")
        } footer: {
          if cloudKitManager.isEnabled {
            Text("icloud.sync.tip.confirm")
          } else {
            Text("icloud.sync.tip.disable")
          }
        }
      }
      .navigationTitle("iCloud 设置")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button("完成") {
            dismiss()
          }
        }
      }
      .onAppear {
        cloudKitManager.checkAccountStatus()
      }
    }
  }
}

#Preview {
  CloudKitSettingsView()
}
