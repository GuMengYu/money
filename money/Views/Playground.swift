import FluidGradient
import SwiftUI

struct PlaygroundView: View {
    @EnvironmentObject var themeManager: ThemeManager
  let columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 4)
  @State private var isOn = false
    
    var theme: Theme {
        themeManager.selectedTheme
    }
  var body: some View {

    ZStack {
      FluidGradient(
        blobs: [theme.primary, theme.secondary, theme.tertiary],
        highlights: [theme.tertiaryContainer, theme.primaryContainer, theme.secondaryContainer],
        speed: 0.2,
        blur: 0.85
      )
      .background(.quaternary)
      .ignoresSafeArea()

        VStack {
            Text("Hello world")
        }
    }
  }
}

#Preview {
    NavigationView {
        PlaygroundView()
            .environmentObject(ThemeManager())

    }
}
