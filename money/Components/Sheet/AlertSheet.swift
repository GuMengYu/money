import SwiftUI

struct AlertSheet: View {
  @Environment(\.dismiss) private var dismiss
  @EnvironmentObject private var themeManager: ThemeManager
  @State private var sheetHeight: CGFloat = .zero

  let title: String
  let message: String
  var body: some View {
    VStack {
      Text(title)
        .font(.headline)
        .padding()
        .padding(.top, 30)
      Text(message)
        .font(.body)
        .padding()

      Button(action: {
        dismiss()
      }) {
        Text("确定")
          .fontDesign(.rounded)
          .fontWeight(.semibold)
      }
      .padding()
      .padding(.horizontal, 24)
      .foregroundColor(themeManager.selectedTheme.onSurface)
      .background(themeManager.selectedTheme.surface)
      .cornerRadius(64)
      .overlay(
        RoundedRectangle(cornerRadius: 64)
          .stroke(themeManager.selectedTheme.outline, lineWidth: 1)
      )
      .padding(.top, 20)
    }
    .presentationDragIndicator(.visible)
    .background(HeightReader(height: $sheetHeight))
    .presentationDetents([.height(sheetHeight)])
  }
}

#Preview {
  AlertSheet(title: "关于余额调整", message: "这是内容这是内容这是内容这是内容这是内容这是内容这是内容这是内容这是内容这是内容这是内容这是内容这是内容")
    .environmentObject(ThemeManager())
}

