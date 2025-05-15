import MapKit  // 导入 MapKit
import SwiftUI

// 1. PreferenceKey 用于从 GeometryReader 向上传递滚动偏移量
struct ScrollOffsetPreferenceKey: PreferenceKey {
  static var defaultValue: CGFloat = 0
  static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
    value = nextValue()
  }
}

struct StickyMapHeaderView: View {
  // 2. 地图相关状态 (iOS 17+ 使用 MapCameraPosition)
  @State private var cameraPosition: MapCameraPosition = .region(
    MKCoordinateRegion(
      center: CLLocationCoordinate2D(latitude: 35.6895, longitude: 139.6917),  // 东京的坐标
      span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    ))

  // 如果需要兼容 iOS 17 以下版本，使用 MKCoordinateRegion
  // @State private var region = MKCoordinateRegion(...)

  // 3. 存储滚动偏移量
  @State private var scrollOffset: CGFloat = 0

  // 4. 定义地图的最大和最小高度
  private let mapMaxHeight: CGFloat = 350  // 地图完全展开时的高度
  private let mapMinHeight: CGFloat = 90  // 地图收起后，类似导航栏的高度（可以根据需要调整，例如设为0让其完全消失）

  var body: some View {
    NavigationStack {  // 使用 NavigationStack 以便更好地控制 Toolbar 和标题
      ZStack(alignment: .top) {
        // --- 可滚动内容区域 ---
        ScrollView(showsIndicators: false) {
          VStack(spacing: 0) {  // 使用 VStack 包裹 GeometryReader 和实际内容
            // GeometryReader 用于获取滚动位置
            GeometryReader { proxy in
              Color.clear  // 透明视图，仅用于获取坐标
                .preference(
                  key: ScrollOffsetPreferenceKey.self,
                  // "scrollViewCoordinateSpace" 是下面 .coordinateSpace 定义的命名空间
                  value: proxy.frame(in: .named("scrollViewCoordinateSpace")).minY
                )
            }
            .frame(height: 0)  // 本身不占用布局空间

            // 这个 Spacer 用于在初始状态下将实际内容推到完全展开的地图下方
            Spacer().frame(height: mapMaxHeight)

            // 你的实际滚动内容
            ForEach(0..<30) { i in
              VStack(alignment: .leading) {
                Text("内容条目 \(i)")
                  .font(.headline)
                Text("这里是一些详细描述文本，可以有很多行。")
                  .font(.subheadline)
                  .foregroundColor(.gray)
              }
              .padding()
              .frame(maxWidth: .infinity, alignment: .leading)
              .background(i % 2 == 0 ? Color(.systemGray6) : Color(.systemGray5))
              Divider()
            }
          }
        }
        .coordinateSpace(name: "scrollViewCoordinateSpace")  // 定义坐标空间
        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { offset in
          // 当滚动时，Preference 会将 minY 的值传递过来
          self.scrollOffset = offset
        }
        // 如果希望ScrollView的内容在地图完全透明时也能“顶”到最上面（状态栏区域），可以开启这个
        // .ignoresSafeArea(edges: .top)

        // --- 粘性地图头部 ---
          Map(position: $cameraPosition, interactionModes: MapInteractionModes([]))
          // Map(coordinateRegion: $region) // 适用于 iOS 17 以下
          .frame(height: currentMapHeight)
          .opacity(currentMapOpacity)  // 根据滚动调整透明度
          .animation(.easeOut(duration: 0.1), value: currentMapHeight)  // 高度变化动画
          .animation(.easeOut(duration: 0.1), value: currentMapOpacity)  // 透明度变化动画
          .clipped()  // 防止地图内容在缩放时超出其 frame
          // 让地图本身忽略顶部安全区域，从而延伸到状态栏后方
          .ignoresSafeArea(edges: .top)

        // --- （可选）在地图顶部添加一个渐变或其他遮罩，使状态栏文字更清晰 ---
        // LinearGradient(
        //     gradient: Gradient(colors: [Color.black.opacity(0.3), Color.clear]),
        //     startPoint: .top,
        //     endPoint: .bottom
        // )
        // .frame(height: mapMinHeight) // 大概是状态栏+导航栏的高度
        // .opacity(headerElementsOpacity) // 根据滚动调整
        // .allowsHitTesting(false) // 不阻挡地图交互
        // .ignoresSafeArea(edges: .top)

      }
      // 让整个 ZStack 布局忽略顶部安全区域，实现沉浸式效果
      .ignoresSafeArea(edges: .top)
      // --- NavigationStack 的 Toolbar 设置 ---
      .toolbar {
        // 导航栏左侧按钮 (例如，当头部收起时显示)
        ToolbarItem(placement: .navigationBarLeading) {
          Button {
            // 返回操作或其他
          } label: {
            Image(systemName: "arrow.backward.circle.fill")
              .font(.title2)
              .foregroundColor(.primary)  // 使用 primary 保证颜色适应深色/浅色模式
              .padding(4)
              .background(.regularMaterial, in: Circle())
          }
          .opacity(headerElementsOpacity)  // 根据滚动控制显隐
          .animation(.easeOut, value: headerElementsOpacity)
        }

        // 导航栏标题 (例如，当头部收起时显示)
        ToolbarItem(placement: .principal) {
          Text("页面标题")
            .font(.headline)
            .opacity(headerElementsOpacity)
            .animation(.easeOut, value: headerElementsOpacity)
        }
      }
      // .navigationBarTitleDisplayMode(.inline) // 根据需要设置
      //  关键：使导航栏背景透明或隐藏，让地图透出来
      .toolbarBackground(.hidden, for: .navigationBar)
      // 你也可以尝试 .toolbarBackground(.ultraThinMaterial, for: .navigationBar) 等材质效果
      // 如果地图颜色较浅，可能需要强制状态栏文字为深色，反之亦然
      // .toolbarColorScheme(.dark, for: .navigationBar) // 如果地图内容总是浅色
    }
  }

  // 5. 计算属性，根据滚动动态改变地图高度
  private var currentMapHeight: CGFloat {
    // scrollOffset 向上滚动时为负值
    let newHeight = mapMaxHeight + scrollOffset
    // 限制地图高度在 mapMinHeight 和 mapMaxHeight 之间
    return max(mapMinHeight, min(newHeight, mapMaxHeight))
  }

  // 6. 计算属性，根据滚动动态改变地图透明度 (可选)
  private var currentMapOpacity: Double {
    // 当地图高度接近最小值时，开始让它变透明直至消失
    let fadeStartHeight = mapMinHeight + 50  // 比最小高度略高时开始渐变
    if currentMapHeight < fadeStartHeight {
      return max(0, (currentMapHeight - mapMinHeight) / (fadeStartHeight - mapMinHeight))
    }
    return 1.0  // 完全不透明
  }

  // 7. 计算属性，用于控制导航栏上元素（如标题、返回按钮）的透明度
  private var headerElementsOpacity: Double {
    // 当地图快要完全收起到 mapMinHeight 时，导航栏元素完全显示
    let transitionRange: CGFloat = 50  // 在 mapMinHeight 之上 50pt 的范围内进行过渡
    let showTriggerHeight = mapMinHeight + transitionRange

    if currentMapHeight < showTriggerHeight {
      // 计算过渡进度 (0.0 到 1.0)
      let progress = (showTriggerHeight - currentMapHeight) / transitionRange
      return min(1.0, max(0.0, progress))
    }
    return 0.0  // 默认隐藏
  }
}

#Preview {
  StickyMapHeaderView()
}
