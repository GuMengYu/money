import SwiftUI

enum Tab: String, CaseIterable {
  case timeline = "calendar.day.timeline.left"
  case statistic = "chart.bar"
  case accounts = "chart.line.text.clipboard"
  case settings = "gearshape"
  var title: String {
    switch self {
    case .timeline: return "时间轴"
    case .accounts: return "账户"
    case .statistic: return "统计"
    case .settings: return "设置"
    }
  }
}

struct AnimatedTab: Identifiable {
  var id: UUID = .init()
  var tab: Tab
  var isAnimating: Bool?
}

struct MainTabView: View {
  @State private var activeTab: Tab = .timeline
  @State private var allTabs: [AnimatedTab] = Tab.allCases.compactMap { tab -> AnimatedTab in
    return .init(tab: tab)
  }

  // 用于沉浸式状态栏的透明度
  @State private var toolbarBackgroundVisibility: Visibility = .automatic

  var body: some View {
    NavigationStack {
      VStack(spacing: 0) {
        TabView(selection: $activeTab) {
            RecordTimelineView()
            .setupTab(.timeline)
            .onAppear { toolbarBackgroundVisibility = .automatic }

          AccountsView()
            .setupTab(.accounts)
            .onAppear { toolbarBackgroundVisibility = .automatic }

          StatisticView()
            .setupTab(.statistic)
            .onAppear { toolbarBackgroundVisibility = .hidden }

          SettingsView()
            .setupTab(.settings)
            .onAppear { toolbarBackgroundVisibility = .automatic }
        }
        CustomTabBar()
      }
    }
  }

  @ViewBuilder
  func CustomTabBar() -> some View {
    HStack {
      ForEach($allTabs) { $animatedTab in
        let tab = animatedTab.tab
        VStack(spacing: 4) {
          Image(systemName: tab.rawValue)
            .font(.title2)
            .symbolEffect(.bounce.down.byLayer, value: animatedTab.isAnimating)
          Text(tab.title)
            .font(.caption)
        }
        .frame(maxWidth: .infinity)
        .foregroundColor(
          activeTab == tab ? Color.accentColor : Color.primary
        )
        .padding(.top, 15)
        .padding(.bottom, 10)
        .contentShape(.rect)
        .onTapGesture {
          withAnimation(
            .bouncy, completionCriteria: .logicallyComplete,
            {
              activeTab = tab
              animatedTab.isAnimating = true

              // 切换到统计视图时使用沉浸式状态栏
              if tab == .statistic {
                toolbarBackgroundVisibility = .hidden
              } else {
                toolbarBackgroundVisibility = .automatic
              }
            },
            completion: {
              var transaction = Transaction()
              transaction.disablesAnimations = true
              withTransaction(transaction) {
                animatedTab.isAnimating = nil
              }
            })
        }
      }
    }
    .background(.bar)
  }
}

extension View {
  @ViewBuilder
  func setupTab(_ tab: Tab) -> some View {
    self.frame(maxWidth: .infinity, maxHeight: .infinity)
      .tag(tab)
      .toolbar(.hidden, for: .tabBar)
  }
}

#Preview {
  MainTabView()
    .modelContainer(
      for: [Account.self, TransactionCategory.self, TransactionRecord.self], inMemory: true)  // Add necessary models for previews of contained views
}
