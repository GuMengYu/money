import AnimateText
import SwiftUI

struct AmountDisplay: View {
  var amount: Double
  var size: CGFloat? = nil
  var symbol: String? = nil
  var center: Bool = true

  @State private var intPart: String = ""
  @State private var fractionalPart: String = ""

  func updateText(_ value: Double) {
      let formatted = CoreFormatter.formatNumber(value)
    let parts = formatted.split(separator: ".")
    let intPart = String(parts[0])
    let fractionalPart = parts.count > 1 ? "." + parts[1] : ".00"
    self.intPart = intPart
    self.fractionalPart = fractionalPart
  }

  var body: some View {
    let currencyPart = symbol ?? "$"

    HStack(alignment: .firstTextBaseline, spacing: 0) {

      Text(currencyPart)
        .font(.title2)
        .fontWeight(.medium)
        .padding(.trailing, 2)
        AnimateText<ATOffsetCustomEffect>($intPart, type: .letters)
        .font(.system(size: size ?? 40))
        .fontWeight(.medium)
        AnimateText<ATOffsetCustomEffect>($fractionalPart, type: .letters)
        .font(.title3)
        .foregroundColor(Color.primary.opacity(0.7))
        .fontWeight(.medium)
    }
    .fontDesign(.rounded)

    .frame(maxWidth: .infinity, alignment: center ? .center : .leading)
    .onAppear {
      updateText(amount)
    }
    .onChange(of: amount) { _, newValue in
      updateText(newValue)
    }
  }
}

#Preview {
  struct PreviewWrapper: View {
    @State var amount: Double = 1000
    var body: some View {
      AmountDisplay(amount: amount, size: 40, symbol: "CNY", center: true)
      Button {
          amount = amount == 1000 ? 3000.78 : 1000
      } label: {
        Text("change number")
      }
    }
  }
  return PreviewWrapper()
}

public struct ATOffsetCustomEffect: ATTextAnimateEffect {
    
    public var data: ATElementData
    public var userInfo: Any?
    
    public init(_ data: ATElementData, _ userInfo: Any?) {
        self.data = data
        self.userInfo = userInfo
    }
    
    public func body(content: Content) -> some View {
        content
            .opacity(data.value)
            .offset(x: 0, y: Double.random(in: -60...60) * data.invValue)
            .animation(.easeInOut(duration: 0.3).delay(Double(data.index) * 0.05), value: data.value)
    }
}
