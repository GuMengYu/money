import Combine  // For ObservableObject
import SwiftUI

class ThemeManager: ObservableObject {
    @Published var selectedTheme: Theme = Theme.greenDay  // 默认主题
  let availableThemes: [Theme] = [
    Theme.defaultTheme, Theme.defaultThemeHighContrast, Theme.greenDay, Theme.blueFlower,
    Theme.yellowSun,
  ]  // 所有预设主题

  // (可选) 如果需要持久化存储用户选择的主题
  private var cancellable: AnyCancellable?
  private let themeKey = "selectedThemeName"

  init() {
    loadTheme()

    // 监听 selectedTheme 的变化并保存
    cancellable =
      $selectedTheme
      .sink { [weak self] theme in
        self?.saveTheme(theme)
      }
  }

  private func loadTheme() {
    if let savedThemeName = UserDefaults.standard.string(forKey: themeKey),
      let theme = availableThemes.first(where: { $0.name == savedThemeName })
    {
      selectedTheme = theme
    } else {
      selectedTheme = Theme.greenDay  // 回退到默认
    }
  }

  private func saveTheme(_ theme: Theme) {
    UserDefaults.standard.set(theme.name, forKey: themeKey)
  }
}
