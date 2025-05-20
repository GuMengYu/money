import SwiftUI

class SheetManager: ObservableObject {
  @Published var isPresented: Bool = false
  @Published var content: AnyView = AnyView(EmptyView())

  // 显示 Sheet 并传入内容视图
  func showSheet<Content: View>(@ViewBuilder content: @escaping () -> Content) {
    self.content = AnyView(content())
    self.isPresented = true
  }

  // 关闭 Sheet
  func dismissSheet() {
    self.isPresented = false
  }

  func showAlertSheet(title: String, message: String) {
    self.content = AnyView(AlertSheet(title: title, message: message))
    self.isPresented = true
  }
}
