import SwiftUI

enum AppTheme: String, CaseIterable {
  case system
  case light
  case dark

  var displayName: LocalizedStringKey {
    switch self {
    case .system: return "theme.system"
    case .light: return "theme.light"
    case .dark: return "theme.dark"
    }
  }
}

struct SettingsView: View {
  @Environment(\.dismiss) private var dismiss
  @State private var showingCloudKitSettings = false

  @EnvironmentObject var themeManager: ThemeManager  // 从环境中获取 ThemeManager

  var body: some View {
    NavigationStack {
      List {
        Section {
          Button {
              if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
              }
          } label: {
              Label("settings.language", systemImage: "globe")
          }
            NavigationLink {
              ThemeSettingsView()
            } label: {
                Label("settings.theme", systemImage: "paintpalette")
            }
        } header: {
          Text("settings.general")
        }

       Section("settings.data") {
              NavigationLink {
                CategoriesView()
              } label: {
                Label("分类", systemImage: "list.dash.header.rectangle")
              }
              NavigationLink {
                ConsumerView()
              } label: {
                Label("消费对象", systemImage: "person.2")
              }
          }

        Section("settings.backup") {
          Button(action: { showingCloudKitSettings = true }) {
              
              Label("settings.icloud", systemImage: "icloud")
          }
        }

        Section("other") {
          NavigationLink {
            AboutView()
          } label: {
            Label("settings.about", systemImage: "info.circle")
          }
        }
      }
      .onAppear { print("Setting View appeared") }
      .onDisappear { print("Setting View disappeared") }
      .navigationTitle("settings.title")
      .sheet(isPresented: $showingCloudKitSettings) {
        CloudKitSettingsView()
      }
    }
  }
}


struct ThemeSettingsView: View {
  @EnvironmentObject var themeManager: ThemeManager
  @AppStorage("colorScheme") private var colorScheme: String = "system"  // 保存主题偏好

  var body: some View {
    List {
        Picker("settings.displayMode", selection: $colorScheme) {
        ForEach(AppTheme.allCases, id: \.self) { _colorScheme in
          Text(_colorScheme.displayName)
            .tag(_colorScheme.rawValue)
        }
      }
      Picker("settings.theme", selection: $themeManager.selectedTheme) {
        ForEach(themeManager.availableThemes) { theme in
          Text(theme.name).tag(theme)
        }
      }
    }
    .navigationTitle("settings.theme")
  }
}

struct AboutView: View {
  var body: some View {
    List {
      Section {
        VStack(spacing: 12) {
          Image(systemName: "dollarsign.circle.fill")
            .font(.system(size: 60))
            .foregroundStyle(.indigo)

          Text("settings.appName")
            .font(.title2)
            .fontWeight(.bold)

          Text("settings.version")
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical)
      }

      Section {
        Link(destination: URL(string: "https://example.com/privacy")!) {
          Label("settings.privacy", systemImage: "hand.raised")
        }

        Link(destination: URL(string: "https://example.com/terms")!) {
          Label("settings.terms", systemImage: "doc.text")
        }
      }
    }
  }
}

#Preview {
  NavigationStack {
    SettingsView()
      .environmentObject(ThemeManager())
  }
}
