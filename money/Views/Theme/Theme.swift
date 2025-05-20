import SwiftUI


extension UIColor {
  convenience init(hex: String) {
    let hex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#")).uppercased()
    var rgb: UInt64 = 0
    Scanner(string: hex).scanHexInt64(&rgb)

    let red = CGFloat((rgb >> 16) & 0xFF) / 255.0
    let green = CGFloat((rgb >> 8) & 0xFF) / 255.0
    let blue = CGFloat(rgb & 0xFF) / 255.0

    self.init(red: red, green: green, blue: blue, alpha: 1.0)
  }
}

extension Color {

  init(rgba: (red: Int, green: Int, blue: Int, alpha: Double)) {
    self.init(
      red: Double(rgba.red) / 255.0,
      green: Double(rgba.green) / 255.0,
      blue: Double(rgba.blue) / 255.0,
      opacity: rgba.alpha
    )
  }

  init(hex: String) {
    let hex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#")).uppercased()
    var rgb: UInt64 = 0
    Scanner(string: hex).scanHexInt64(&rgb)

    let red: Double
    let green: Double
    let blue: Double
    let alpha: Double

    switch hex.count {
    case 3:  // #RGB
      red = Double((rgb >> 8) & 0xF) / 15.0
      green = Double((rgb >> 4) & 0xF) / 15.0
      blue = Double(rgb & 0xF) / 15.0
      alpha = 1.0
    case 6:  // #RRGGBB
      red = Double((rgb >> 16) & 0xFF) / 255.0
      green = Double((rgb >> 8) & 0xFF) / 255.0
      blue = Double(rgb & 0xFF) / 255.0
      alpha = 1.0
    case 8:  // #RRGGBBAA
      red = Double((rgb >> 24) & 0xFF) / 255.0
      green = Double((rgb >> 16) & 0xFF) / 255.0
      blue = Double((rgb >> 8) & 0xFF) / 255.0
      alpha = Double(rgb & 0xFF) / 255.0
    default:
      red = 0.0
      green = 0.0
      blue = 0.0
      alpha = 1.0  // 默认黑色不透明
    }

    self.init(red: red, green: green, blue: blue, opacity: alpha)
  }
}


struct Theme: Identifiable, Hashable {
  let id = UUID()  // 用于 Identifiable
  let name: String

  // 定义自适应颜色
  let primary: Color
  let onPrimary: Color
  let primaryContainer: Color
  let onPrimaryContainer: Color
  let secondary: Color
  let onSecondary: Color
  let secondaryContainer: Color
  let onSecondaryContainer: Color
  let tertiary: Color
  let onTertiary: Color
  let tertiaryContainer: Color
  let onTertiaryContainer: Color
  let error: Color
  let onError: Color
  let errorContainer: Color
  let onErrorContainer: Color
  let surface: Color
  let surfaceDim: Color
  let surfaceBright: Color
  let surfaceContainerLowest: Color
  let surfaceContainerLow: Color
  let surfaceContainer: Color
  let surfaceContainerHigh: Color
  let surfaceContainerHighest: Color
  let onSurface: Color
  let onSurfaceVariant: Color
  let outline: Color
  let outlineVariant: Color
  let inverseSurface: Color
  let inverseOnSurface: Color
  let inversePrimary: Color
  let scrim: Color
  let shadow: Color

  // 为了 Picker 等需要 Hashable
  func hash(into hasher: inout Hasher) {
    hasher.combine(name)
  }

  static func == (lhs: Theme, rhs: Theme) -> Bool {
    lhs.name == rhs.name
  }
}

// MARK: - Predefined Themes (在这里定义你的主题颜色)

extension Theme {
  static let defaultTheme = Theme(
    name: "默认",
    primary: Color(light: Color(hex: "#8F4C38"), dark: Color(hex: "#FFB5A0")),
    onPrimary: Color(light: Color(hex: "#FFFFFF"), dark: Color(hex: "#561F0F")),
    primaryContainer: Color(light: Color(hex: "#FFDBD1"), dark: Color(hex: "#723523")),
    onPrimaryContainer: Color(light: Color(hex: "#723523"), dark: Color(hex: "#FFDBD1")),
    secondary: Color(light: Color(hex: "#77574E"), dark: Color(hex: "#E7BDB2")),
    onSecondary: Color(light: Color(hex: "#FFFFFF"), dark: Color(hex: "#442A22")),
    secondaryContainer: Color(light: Color(hex: "#FFDBD1"), dark: Color(hex: "#5D4037")),
    onSecondaryContainer: Color(light: Color(hex: "#5D4037"), dark: Color(hex: "#FFDBD1")),
    tertiary: Color(light: Color(hex: "#6C5D2F"), dark: Color(hex: "#D8C58D")),
    onTertiary: Color(light: Color(hex: "#FFFFFF"), dark: Color(hex: "#3B2F05")),
    tertiaryContainer: Color(light: Color(hex: "#F5E1A7"), dark: Color(hex: "#534619")),
    onTertiaryContainer: Color(light: Color(hex: "#534619"), dark: Color(hex: "#F5E1A7")),
    error: Color(light: Color(hex: "#BA1A1A"), dark: Color(hex: "#FFB4AB")),
    onError: Color(light: Color(hex: "#FFFFFF"), dark: Color(hex: "#690005")),
    errorContainer: Color(light: Color(hex: "#FFDAD6"), dark: Color(hex: "#93000A")),
    onErrorContainer: Color(light: Color(hex: "#93000A"), dark: Color(hex: "#FFDAD6")),
    surface: Color(light: Color(hex: "#FFF8F6"), dark: Color(hex: "#1A110F")),
    surfaceDim: Color(light: Color(hex: "#E8D6D2"), dark: Color(hex: "#1A110F")),
    surfaceBright: Color(light: Color(hex: "#FFF8F6"), dark: Color(hex: "#423734")),
    surfaceContainerLowest: Color(light: Color(hex: "#FFFFFF"), dark: Color(hex: "#140C0A")),
    surfaceContainerLow: Color(light: Color(hex: "#FFF1ED"), dark: Color(hex: "#231917")),
    surfaceContainer: Color(light: Color(hex: "#FCEAE5"), dark: Color(hex: "#271D1B")),
    surfaceContainerHigh: Color(light: Color(hex: "#F7E4E0"), dark: Color(hex: "#322825")),
    surfaceContainerHighest: Color(light: Color(hex: "#F1DFDA"), dark: Color(hex: "#3D322F")),
    onSurface: Color(light: Color(hex: "#231917"), dark: Color(hex: "#F1DFDA")),
    onSurfaceVariant: Color(light: Color(hex: "#53433F"), dark: Color(hex: "#D8C2BC")),
    outline: Color(light: Color(hex: "#85736E"), dark: Color(hex: "#A08C87")),
    outlineVariant: Color(light: Color(hex: "#D8C2BC"), dark: Color(hex: "#53433F")),
    inverseSurface: Color(light: Color(hex: "#392E2B"), dark: Color(hex: "#F1DFDA")),
    inverseOnSurface: Color(light: Color(hex: "#FFEDE8"), dark: Color(hex: "#392E2B")),
    inversePrimary: Color(light: Color(hex: "#FFB5A0"), dark: Color(hex: "#8F4C38")),
    scrim: Color(light: Color(hex: "#000000"), dark: Color(hex: "#000000")),
    shadow: Color(light: Color(hex: "#000000"), dark: Color(hex: "#000000"))
  )

  static let defaultThemeHighContrast = Theme(
    name: "默认(高对比)",
    primary: Color(light: Color(hex: "#501B0B"), dark: Color(hex: "#FFECE7")),
    onPrimary: Color(light: Color(hex: "#FFFFFF"), dark: Color(hex: "#000000")),
    primaryContainer: Color(light: Color(hex: "#753725"), dark: Color(hex: "#FFAF98")),
    onPrimaryContainer: Color(light: Color(hex: "#FFFFFF"), dark: Color(hex: "#1E0300")),
    secondary: Color(light: Color(hex: "#3F261E"), dark: Color(hex: "#FFECE7")),
    onSecondary: Color(light: Color(hex: "#FFFFFF"), dark: Color(hex: "#000000")),
    secondaryContainer: Color(light: Color(hex: "#60423A"), dark: Color(hex: "#E3B9AE")),
    onSecondaryContainer: Color(light: Color(hex: "#FFFFFF"), dark: Color(hex: "#190603")),
    tertiary: Color(light: Color(hex: "#362B02"), dark: Color(hex: "#FFEFC4")),
    onTertiary: Color(light: Color(hex: "#FFFFFF"), dark: Color(hex: "#000000")),
    tertiaryContainer: Color(light: Color(hex: "#55481C"), dark: Color(hex: "#D4C289")),
    onTertiaryContainer: Color(light: Color(hex: "#FFFFFF"), dark: Color(hex: "#100B00")),
    error: Color(light: Color(hex: "#600004"), dark: Color(hex: "#FFECE9")),
    onError: Color(light: Color(hex: "#FFFFFF"), dark: Color(hex: "#000000")),
    errorContainer: Color(light: Color(hex: "#98000A"), dark: Color(hex: "#FFAEA4")),
    onErrorContainer: Color(light: Color(hex: "#FFFFFF"), dark: Color(hex: "#220001")),
    surface: Color(light: Color(hex: "#FFF8F6"), dark: Color(hex: "#1A110F")),
    surfaceDim: Color(light: Color(hex: "#C6B5B1"), dark: Color(hex: "#1A110F")),
    surfaceBright: Color(light: Color(hex: "#FFF8F6"), dark: Color(hex: "#5A4D4A")),
    surfaceContainerLowest: Color(light: Color(hex: "#FFFFFF"), dark: Color(hex: "#000000")),
    surfaceContainerLow: Color(light: Color(hex: "#FFEDE8"), dark: Color(hex: "#271D1B")),
    surfaceContainer: Color(light: Color(hex: "#F1DFDA"), dark: Color(hex: "#392E2B")),
    surfaceContainerHigh: Color(light: Color(hex: "#E2D1CC"), dark: Color(hex: "#443936")),
    surfaceContainerHighest: Color(light: Color(hex: "#D4C3BE"), dark: Color(hex: "#504441")),
    onSurface: Color(light: Color(hex: "#000000"), dark: Color(hex: "#FFFFFF")),
    onSurfaceVariant: Color(light: Color(hex: "#000000"), dark: Color(hex: "#FFFFFF")),
    outline: Color(light: Color(hex: "#372925"), dark: Color(hex: "#FFECE7")),
    outlineVariant: Color(light: Color(hex: "#554641"), dark: Color(hex: "#D4BEB8")),
    inverseSurface: Color(light: Color(hex: "#392E2B"), dark: Color(hex: "#F1DFDA")),
    inverseOnSurface: Color(light: Color(hex: "#FFFFFF"), dark: Color(hex: "#000000")),
    inversePrimary: Color(light: Color(hex: "#743624"), dark: Color(hex: "#743624")),
    scrim: Color(light: Color(hex: "#000000"), dark: Color(hex: "#000000")),
    shadow: Color(light: Color(hex: "#000000"), dark: Color(hex: "#000000"))
  )

  static let greenDay = Theme(
    name: "绿日",
    primary: Color(light: Color(hex: "#4C662B"), dark: Color(hex: "#B1D18A")),
    onPrimary: Color(light: Color(hex: "#FFFFFF"), dark: Color(hex: "#1F3701")),
    primaryContainer: Color(light: Color(hex: "#CDEDA3"), dark: Color(hex: "#354E16")),
    onPrimaryContainer: Color(light: Color(hex: "#354E16"), dark: Color(hex: "#CDEDA3")),
    secondary: Color(light: Color(hex: "#586249"), dark: Color(hex: "#BFCBAD")),
    onSecondary: Color(light: Color(hex: "#FFFFFF"), dark: Color(hex: "#2A331E")),
    secondaryContainer: Color(light: Color(hex: "#DCE7C8"), dark: Color(hex: "#404A33")),
    onSecondaryContainer: Color(light: Color(hex: "#404A33"), dark: Color(hex: "#DCE7C8")),
    tertiary: Color(light: Color(hex: "#386663"), dark: Color(hex: "#A0D0CB")),
    onTertiary: Color(light: Color(hex: "#FFFFFF"), dark: Color(hex: "#003735")),
    tertiaryContainer: Color(light: Color(hex: "#BCECE7"), dark: Color(hex: "#1F4E4B")),
    onTertiaryContainer: Color(light: Color(hex: "#1F4E4B"), dark: Color(hex: "#BCECE7")),
    error: Color(light: Color(hex: "#BA1A1A"), dark: Color(hex: "#FFB4AB")),
    onError: Color(light: Color(hex: "#FFFFFF"), dark: Color(hex: "#690005")),
    errorContainer: Color(light: Color(hex: "#FFDAD6"), dark: Color(hex: "#93000A")),
    onErrorContainer: Color(light: Color(hex: "#93000A"), dark: Color(hex: "#FFDAD6")),
    surface: Color(light: Color(hex: "#F9FAEF"), dark: Color(hex: "#12140E")),
    surfaceDim: Color(light: Color(hex: "#DADBD0"), dark: Color(hex: "#12140E")),
    surfaceBright: Color(light: Color(hex: "#F9FAEF"), dark: Color(hex: "#383A32")),
    surfaceContainerLowest: Color(light: Color(hex: "#FFFFFF"), dark: Color(hex: "#0C0F09")),
    surfaceContainerLow: Color(light: Color(hex: "#F3F4E9"), dark: Color(hex: "#1A1C16")),
    surfaceContainer: Color(light: Color(hex: "#EEEFE3"), dark: Color(hex: "#1E201A")),
    surfaceContainerHigh: Color(light: Color(hex: "#E8E9DE"), dark: Color(hex: "#282B24")),
    surfaceContainerHighest: Color(light: Color(hex: "#E2E3D8"), dark: Color(hex: "#33362E")),
    onSurface: Color(light: Color(hex: "#1A1C16"), dark: Color(hex: "#E2E3D8")),
    onSurfaceVariant: Color(light: Color(hex: "#44483D"), dark: Color(hex: "#C5C8BA")),
    outline: Color(light: Color(hex: "#75796C"), dark: Color(hex: "#8F9285")),
    outlineVariant: Color(light: Color(hex: "#C5C8BA"), dark: Color(hex: "#44483D")),
    inverseSurface: Color(light: Color(hex: "#2F312A"), dark: Color(hex: "#E2E3D8")),
    inverseOnSurface: Color(light: Color(hex: "#F1F2E6"), dark: Color(hex: "#2F312A")),
    inversePrimary: Color(light: Color(hex: "#B1D18A"), dark: Color(hex: "#4C662B")),
    scrim: Color(light: Color(hex: "#000000"), dark: Color(hex: "#000000")),
    shadow: Color(light: Color(hex: "#000000"), dark: Color(hex: "#000000"))
  )

  static let blueFlower = Theme(
    name: "兰花",
    primary: Color(light: Color(hex: "#415F91"), dark: Color(hex: "#AAC7FF")),
    onPrimary: Color(light: Color(hex: "#FFFFFF"), dark: Color(hex: "#0A305F")),
    primaryContainer: Color(light: Color(hex: "#D6E3FF"), dark: Color(hex: "#284777")),
    onPrimaryContainer: Color(light: Color(hex: "#284777"), dark: Color(hex: "#D6E3FF")),
    secondary: Color(light: Color(hex: "#565F71"), dark: Color(hex: "#BEC6DC")),
    onSecondary: Color(light: Color(hex: "#FFFFFF"), dark: Color(hex: "#283141")),
    secondaryContainer: Color(light: Color(hex: "#DAE2F9"), dark: Color(hex: "#3E4759")),
    onSecondaryContainer: Color(light: Color(hex: "#3E4759"), dark: Color(hex: "#DAE2F9")),
    tertiary: Color(light: Color(hex: "#705575"), dark: Color(hex: "#DDBCE0")),
    onTertiary: Color(light: Color(hex: "#FFFFFF"), dark: Color(hex: "#3F2844")),
    tertiaryContainer: Color(light: Color(hex: "#FAD8FD"), dark: Color(hex: "#573E5C")),
    onTertiaryContainer: Color(light: Color(hex: "#573E5C"), dark: Color(hex: "#FAD8FD")),
    error: Color(light: Color(hex: "#BA1A1A"), dark: Color(hex: "#FFB4AB")),
    onError: Color(light: Color(hex: "#FFFFFF"), dark: Color(hex: "#690005")),
    errorContainer: Color(light: Color(hex: "#FFDAD6"), dark: Color(hex: "#93000A")),
    onErrorContainer: Color(light: Color(hex: "#93000A"), dark: Color(hex: "#FFDAD6")),
    surface: Color(light: Color(hex: "#F9F9FF"), dark: Color(hex: "#111318")),
    surfaceDim: Color(light: Color(hex: "#D9D9E0"), dark: Color(hex: "#111318")),
    surfaceBright: Color(light: Color(hex: "#F9F9FF"), dark: Color(hex: "#37393E")),
    surfaceContainerLowest: Color(light: Color(hex: "#FFFFFF"), dark: Color(hex: "#0C0E13")),
    surfaceContainerLow: Color(light: Color(hex: "#F3F3FA"), dark: Color(hex: "#191C20")),
    surfaceContainer: Color(light: Color(hex: "#EDEDF4"), dark: Color(hex: "#1D2024")),
    surfaceContainerHigh: Color(light: Color(hex: "#E7E8EE"), dark: Color(hex: "#282A2F")),
    surfaceContainerHighest: Color(light: Color(hex: "#E2E2E9"), dark: Color(hex: "#33353A")),
    onSurface: Color(light: Color(hex: "#191C20"), dark: Color(hex: "#E2E2E9")),
    onSurfaceVariant: Color(light: Color(hex: "#44474E"), dark: Color(hex: "#C4C6D0")),
    outline: Color(light: Color(hex: "#74777F"), dark: Color(hex: "#8E9099")),
    outlineVariant: Color(light: Color(hex: "#C4C6D0"), dark: Color(hex: "#44474E")),
    inverseSurface: Color(light: Color(hex: "#2E3036"), dark: Color(hex: "#E2E2E9")),
    inverseOnSurface: Color(light: Color(hex: "#F0F0F7"), dark: Color(hex: "#2E3036")),
    inversePrimary: Color(light: Color(hex: "#AAC7FF"), dark: Color(hex: "#415F91")),
    scrim: Color(light: Color(hex: "#000000"), dark: Color(hex: "#000000")),
    shadow: Color(light: Color(hex: "#000000"), dark: Color(hex: "#000000"))
  )

  static let yellowSun = Theme(
    name: "旭日",
    primary: Color(light: Color(hex: "#6D5E0F"), dark: Color(hex: "#DBC66E")),
    onPrimary: Color(light: Color(hex: "#FFFFFF"), dark: Color(hex: "#3A3000")),
    primaryContainer: Color(light: Color(hex: "#F8E287"), dark: Color(hex: "#534600")),
    onPrimaryContainer: Color(light: Color(hex: "#534600"), dark: Color(hex: "#F8E287")),
    secondary: Color(light: Color(hex: "#665E40"), dark: Color(hex: "#D1C6A1")),
    onSecondary: Color(light: Color(hex: "#FFFFFF"), dark: Color(hex: "#363016")),
    secondaryContainer: Color(light: Color(hex: "#EEE2BC"), dark: Color(hex: "#4E472A")),
    onSecondaryContainer: Color(light: Color(hex: "#4E472A"), dark: Color(hex: "#EEE2BC")),
    tertiary: Color(light: Color(hex: "#43664E"), dark: Color(hex: "#A9D0B3")),
    onTertiary: Color(light: Color(hex: "#FFFFFF"), dark: Color(hex: "#143723")),
    tertiaryContainer: Color(light: Color(hex: "#C5ECCE"), dark: Color(hex: "#2C4E38")),
    onTertiaryContainer: Color(light: Color(hex: "#2C4E38"), dark: Color(hex: "#C5ECCE")),
    error: Color(light: Color(hex: "#BA1A1A"), dark: Color(hex: "#FFB4AB")),
    onError: Color(light: Color(hex: "#FFFFFF"), dark: Color(hex: "#690005")),
    errorContainer: Color(light: Color(hex: "#FFDAD6"), dark: Color(hex: "#93000A")),
    onErrorContainer: Color(light: Color(hex: "#93000A"), dark: Color(hex: "#FFDAD6")),
    surface: Color(light: Color(hex: "#FFF9EE"), dark: Color(hex: "#15130B")),
    surfaceDim: Color(light: Color(hex: "#E0D9CC"), dark: Color(hex: "#15130B")),
    surfaceBright: Color(light: Color(hex: "#FFF9EE"), dark: Color(hex: "#3C3930")),
    surfaceContainerLowest: Color(light: Color(hex: "#FFFFFF"), dark: Color(hex: "#100E07")),
    surfaceContainerLow: Color(light: Color(hex: "#FAF3E5"), dark: Color(hex: "#1E1B13")),
    surfaceContainer: Color(light: Color(hex: "#F4EDDF"), dark: Color(hex: "#222017")),
    surfaceContainerHigh: Color(light: Color(hex: "#EEE8DA"), dark: Color(hex: "#2D2A21")),
    surfaceContainerHighest: Color(light: Color(hex: "#E8E2D4"), dark: Color(hex: "#38352B")),
    onSurface: Color(light: Color(hex: "#1E1B13"), dark: Color(hex: "#E8E2D4")),
    onSurfaceVariant: Color(light: Color(hex: "#4B4739"), dark: Color(hex: "#CDC6B4")),
    outline: Color(light: Color(hex: "#7C7767"), dark: Color(hex: "#969080")),
    outlineVariant: Color(light: Color(hex: "#CDC6B4"), dark: Color(hex: "#4B4739")),
    inverseSurface: Color(light: Color(hex: "#333027"), dark: Color(hex: "#E8E2D4")),
    inverseOnSurface: Color(light: Color(hex: "#F7F0E2"), dark: Color(hex: "#333027")),
    inversePrimary: Color(light: Color(hex: "#DBC66E"), dark: Color(hex: "#6D5E0F")),
    scrim: Color(light: Color(hex: "#000000"), dark: Color(hex: "#000000")),
    shadow: Color(light: Color(hex: "#000000"), dark: Color(hex: "#000000"))
  )
}

// MARK: - Color Extension for Light/Dark and Hex

extension Color {
  // 初始化器，方便定义明暗模式颜色
  init(light: Color, dark: Color) {
    self.init(
      uiColor: UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
      })
  }
}
