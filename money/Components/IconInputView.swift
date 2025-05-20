import SwiftUI

enum IconType: String, CaseIterable {
  case buildIn
  case SFSymbol
  case emoji
}

enum SFSymbolIcon: String, CaseIterable {
  case square_and_arrow_up = "square.and.arrow.up"
  case checkmark_seal_text_page = "checkmark.seal.text.page"
  case person_crop_square_on_square_angled_fill = "person.crop.square.on.square.angled.fill"
  case display = "display"
  case xserve = "xserve"
  case creditcard = "creditcard"
  case bitcoinsign_circle = "bitcoinsign.circle"

  var value: String {
    "system_\(self.rawValue)"
  }
}

enum EmojiIcon: String, CaseIterable {
  case 💰
  case 🤔
  case 😀
  case 😂
  case 😍
  case 😘
  case 😭
  case 😡
  case 😢

  var value: String {
    "emoji_\(self)"
  }
}

struct IconInputView: View {

  @Binding var value: String
  @State private var input = ""
  @State private var selectedType: IconType = .buildIn
  @Environment(\.dismiss) private var dismiss
  private let feedback = UIImpactFeedbackGenerator(style: .medium)

  var body: some View {
    VStack {
      Picker(
        "选择图标类型",
        selection: $selectedType
      ) {
        ForEach(IconType.allCases, id: \.self) { type in
          Text(type.rawValue).tag(type)
        }
      }
      .pickerStyle(.segmented)
      .padding()

      ScrollView {
        LazyVGrid(
          columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 5), spacing: 6
        ) {
          if selectedType == .buildIn {
            ForEach(AppIcons.allCases, id: \.self) { key in
              BuildInIconButton(
                icon: key,
                action: { icon in
                  value = icon.file
                  feedback.impactOccurred()
                  dismiss()

                }
              )
            }
          }
          if selectedType == .emoji {
            ForEach(EmojiIcon.allCases, id: \.self) { key in
              EmojiIconButton(
                icon: key,
                action: { icon in
                  value = icon.value
                  feedback.impactOccurred()
                  dismiss()
                }
              )
            }
          }
          if selectedType == .SFSymbol {
            ForEach(SFSymbolIcon.allCases, id: \.self) { symbol in
              SFSymbolIconButton(
                icon: symbol,
                action: { icon in
                  value = icon.value
                  feedback.impactOccurred()
                  dismiss()
                }
              )
            }
          }
        }
      }
      .frame(height: 300)
    }
    .padding()
    .onAppear { input = value }
  }
}

struct BuildInIconButton: View {
  let icon: AppIcons
  let action: (AppIcons) -> Void

  var body: some View {
    Button(action: {
      action(icon)
    }) {
      AppIconView(icon: icon.file)

    }
    .padding(12)
    .cornerRadius(100)
  }
}

struct EmojiIconButton: View {
  let icon: EmojiIcon
  let action: (EmojiIcon) -> Void

  var body: some View {
    Button(action: {
      action(icon)
    }) {
      AppIconView(icon: icon.value)
    }
    .padding(10)
    .cornerRadius(100)
  }
}

struct SFSymbolIconButton: View {
  let icon: SFSymbolIcon
  let action: (SFSymbolIcon) -> Void

  var body: some View {
    Button(action: {
      action(icon)
    }) {
      AppIconView(icon: icon.value)

    }
    .padding(12)
    .cornerRadius(100)
  }
}

#Preview {
  IconInputView(value: .constant(""))
}

#Preview {
  HStack {
    EmojiIconButton(icon: .💰, action: { _ in })
    BuildInIconButton(icon: .alipay, action: { _ in })
    SFSymbolIconButton(icon: SFSymbolIcon.square_and_arrow_up, action: { _ in })
  }
}
