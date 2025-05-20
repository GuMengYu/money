import SwiftUI

/// 折叠卡片的展开模式
enum CollapsibleMode {
  /// 只能展开一个
  case single
  /// 可以同时展开多个
  case multiple
}

/// 通用折叠卡片组
struct CollapsibleGroup<ID: Hashable, HeaderContent: View, Content: View>: View {
  let mode: CollapsibleMode
  @Binding var expandedIds: Set<ID>  // multiple 模式使用
  @Binding var expandedId: ID?  // single 模式使用

  let items: [ID]
  let headerContent: (ID) -> HeaderContent
  let content: (ID) -> Content

  init(
    mode: CollapsibleMode = .single,
    expandedIds: Binding<Set<ID>> = .constant([]),
    expandedId: Binding<ID?> = .constant(nil),
    items: [ID],
    @ViewBuilder headerContent: @escaping (ID) -> HeaderContent,
    @ViewBuilder content: @escaping (ID) -> Content
  ) {
    self.mode = mode
    self._expandedIds = expandedIds
    self._expandedId = expandedId
    self.items = items
    self.headerContent = headerContent
    self.content = content
  }

  var body: some View {
    VStack(spacing: 0) {
      ForEach(items, id: \.self) { id in
        CollapsibleCard(
          isExpanded: mode == .single
            ? Binding(
              get: { expandedId == id },
              set: { isExpanded in
                if isExpanded {
                  expandedId = id
                } else if expandedId == id {
                  expandedId = nil
                }
              }
            )
            : Binding(
              get: { expandedIds.contains(id) },
              set: { isExpanded in
                if isExpanded {
                  expandedIds.insert(id)
                } else {
                  expandedIds.remove(id)
                }
              }
            ),
          header: { headerContent(id) },
          content: { content(id) }
        )
      }
    }
  }
}

/// 单个折叠卡片
struct CollapsibleCard<HeaderContent: View, Content: View>: View {
  @Binding var isExpanded: Bool
  let header: () -> HeaderContent
  let content: () -> Content

  init(
    isExpanded: Binding<Bool>,
    @ViewBuilder header: @escaping () -> HeaderContent,
    @ViewBuilder content: @escaping () -> Content
  ) {
    self._isExpanded = isExpanded
    self.header = header
    self.content = content
  }

  var body: some View {
    VStack(spacing: 0) {
      Button(action: {
        withAnimation(.spring(duration: 0.5, bounce: isExpanded ?  0.1 : 0.4)) {
          isExpanded.toggle()
        }
      }) {
        header()
      }

      if isExpanded {
        content()
      }
    }
  }
}
