import SwiftUI

enum Tab: String, CaseIterable, Hashable {
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
    
    // 为了 Picker 等需要 Hashable
    func hash(into hasher: inout Hasher) {
      hasher.combine(title)
    }
}

struct AnimatedTab: Identifiable {
  var id: UUID = .init()
  var tab: Tab
  var isAnimating: Bool?
}

struct MainTabView: View {
    @EnvironmentObject var themeManager: ThemeManager
  @State private var activeTab: Tab = .timeline
  @State private var allTabs: [AnimatedTab] = Tab.allCases.compactMap { tab -> AnimatedTab in
    return .init(tab: tab)
  }


  var body: some View {
      VStack(spacing: 0) {
          TabView(selection: $activeTab) {
              
              RecordTimelineView()
                  .tabItem {
                      Label(Tab.timeline.title, systemImage: Tab.timeline.rawValue)
                  }
                  .tag(Tab.timeline)
              StatisticView()
                  .tabItem {
                      Label(Tab.statistic.title, systemImage: Tab.statistic.rawValue)
                  }
                  .tag(Tab.statistic)

              
              AccountsView()
                  .tabItem {
                      Label(Tab.accounts.title, systemImage: Tab.accounts.rawValue)
                  }
                  .tag(Tab.accounts)

              SettingsView()
                  .tabItem {
                      Label(Tab.settings.title, systemImage: Tab.settings.rawValue)
                  }
                  .tag(Tab.settings)

          }
//
//            RecordTimelineView()
//            .setupTab(.timeline)
//
//
//          AccountsView()
//            .setupTab(.accounts)
//
//          StatisticView()
//            .setupTab(.statistic)
//
//          SettingsView()
//            .setupTab(.settings)
//        }
//        CustomTabBar()
      }
      .accentColor(themeManager.selectedTheme.primary)
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
    .background(.clear)
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
      for: [Account.self, TransactionCategory.self, TransactionRecord.self], inMemory: true)
    .environmentObject(ThemeManager())
}
