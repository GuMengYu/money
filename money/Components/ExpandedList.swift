import SwiftUI

// 数据模型
public struct ExpandListItem: Identifiable {
  public let id = UUID()
  public let title: String
  public let content: AnyView
  public let header: AnyView
  public var isOpen: Bool = false
  public var isFirst: Bool = false
  public var isLast: Bool = false

  public init(
    title: String, header: AnyView, content: AnyView, isOpen: Bool = false, isFirst: Bool = false,
    isLast: Bool = false
  ) {
    self.title = title
    self.content = content
    self.isOpen = isOpen
    self.header = header
    self.isFirst = isFirst
    self.isLast = isLast
  }
}

// 展开模式
public enum ExpandMode {
  case single  // 单个展开
  case multiple  // 多个展开
}

// 主组件
public struct ExpandedList: View {
  @State private var items: [ExpandListItem]
  @State private var selectedIndex: Int?
  private let mode: ExpandMode

  public init(items: [ExpandListItem], mode: ExpandMode = .single) {
    self._items = State(initialValue: items)
    self.mode = mode
  }

  public var body: some View {
    VStack(spacing: 0) {
      ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
        ExpandListItemView(
          item: $items[index],
          index: index,
          selectedIndex: $selectedIndex,
          mode: mode,
          onTap: {
            handleTap(index: index)
          }
        )
      }
    }

  }

  private func handleTap(index: Int) {
    withAnimation {
      switch mode {
      case .single:
        if items[index].isOpen {
          items[index].isOpen = false
          selectedIndex = nil
        } else {
          // 关闭之前打开的
          if let selectedIndex = selectedIndex {
            items[selectedIndex].isOpen = false
          }
          items[index].isOpen = true
          selectedIndex = index
        }
      case .multiple:
        items[index].isOpen.toggle()
        if items[index].isOpen {
          selectedIndex = index
        } else if selectedIndex == index {
          selectedIndex = nil
        }
      }
    }
  }
}

// 单个可展开项视图
private struct ExpandListItemView: View {
  @Binding var item: ExpandListItem
  let index: Int
  @Binding var selectedIndex: Int?
  let mode: ExpandMode
  let onTap: () -> Void

  var body: some View {
    VStack(spacing: 0) {
      VStack {
        HStack {
          item.header
          Spacer()
          Image(systemName: "chevron.right")
            .rotationEffect(.degrees(item.isOpen ? 90 : 0))
        }
        .contentShape(Rectangle())  // 确保整个区域都可以点击，包括空白区域
        .onTapGesture {
          onTap()
        }

        if !item.isOpen {
          //          Spacer()
        }
        if item.isOpen {
          item.content
            .fixedSize(horizontal: false, vertical: true)
            .opacity(item.isOpen ? 1 : 0)
        }

      }
      //      .frame(maxHeight: item.isOpen ? .none : 25, alignment: .top)
      .padding()
      .background(
        UnevenRoundedRectangle(
          topLeadingRadius: item.isFirst
            ? 24
            : (index == selectedIndex
              ? 24 : ((selectedIndex ?? -1) + 1 == index ? 24 : 4)),
          bottomLeadingRadius: item.isLast
            ? 24
            : (index == selectedIndex
              ? 24 : ((selectedIndex ?? -1) - 1 == index ? 24 : 4)),
          bottomTrailingRadius: item.isLast
            ? 24
            : (index == selectedIndex
              ? 24 : ((selectedIndex ?? -1) - 1 == index ? 24 : 4)),
          topTrailingRadius: item.isFirst
            ? 24
            : (index == selectedIndex
              ? 24 : ((selectedIndex ?? -1) + 1 == index ? 24 : 4))
        )
        .fill(.ultraThickMaterial)
      )
      .clipped()
    }
    .padding(
      .top,
      (selectedIndex != nil && index == selectedIndex! + 1)
        ? (item.isOpen ? 12 : 0) : (item.isOpen ? 12 : 1)
    )
    .padding(
      .bottom,
      (selectedIndex != nil && index == selectedIndex! - 1)
        ? (item.isOpen ? 12 : 0) : (item.isOpen ? 12 : 1)
    )

  }
}

#Preview {
  VStack {
    // 多个展开模式示例
    ExpandedList(
      items: [
        ExpandListItem(
          title: "Section 1",
          header: AnyView(Text("Section 1").font(.title)),
          content: AnyView(Text("Content 1").padding()),
          isFirst: true
        ),
        ExpandListItem(
          title: "Section 2",
          header: AnyView(Text("Section 2").font(.title2)),
          content: AnyView(Text("Content 2").padding()),
          isLast: false
        ),
        ExpandListItem(
          title: "Section 3",
          header: AnyView(Text("Section 3").font(.title3)),
          content: AnyView(Text("Content 3").padding()),
          isLast: true
        ),
      ],
      mode: .multiple
    )

  }
  .padding()
  .preferredColorScheme(.dark)

}

#Preview {
  VStack {
    // 单个展开模式示例
    ExpandedList(
      items: [
        ExpandListItem(
          title: "Section 1",
          header: AnyView(Text("Section 1").font(.largeTitle)),
          content: AnyView(Text("Content 1").padding()),
          isFirst: true
        ),
        ExpandListItem(
          title: "Section 2",
          header: AnyView(Text("Section 2").font(.title3)),
          content: AnyView(Text("Content 2").padding())

        ),
        ExpandListItem(
          title: "Section 3",
          header: AnyView(Text("Section 3").font(.title3)),
          content: AnyView(Text("Content 3").padding())
        ),
        ExpandListItem(
          title: "Section 4",
          header: AnyView(Text("Section 4").font(.title3)),
          content: AnyView(Text("Content 4").padding()),
          isLast: true
        ),
      ],
      mode: .single
    )
  }
  .padding()
  .preferredColorScheme(.light)
}

