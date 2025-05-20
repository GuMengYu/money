//
//  AppIconView.swift
//  SwiftDataSample
//
//  Created by Yoda on 2025/5/6.
//
import SwiftUI

struct AppIconView: View {
  let icon: String
  var size: CGFloat = 24
  private var isEmoji: Bool {
    return icon.contains("emoji_")
  }
  private var isSystemIcon: Bool {
    return icon.contains("system_")
  }
  var body: some View {
    Group {
      if isEmoji {
        let emojiIcon = icon.replacingOccurrences(of: "emoji_", with: "")
        Text(emojiIcon)
          .font(.system(size: size))
      } else if isSystemIcon {
        let systemIcon = icon.replacingOccurrences(of: "system_", with: "")
        Image(systemName: systemIcon)
          .resizable()
          .scaledToFit()
          .frame(width: size, height: size)
      } else {
        Image(icon)
          .resizable()
          .scaledToFit()
          .frame(width: size, height: size)
      }
    }
  }
}

#Preview {
  HStack {
    AppIconView(icon: "emoji_🤓")
    AppIconView(icon: "system_creditcard")
    AppIconView(icon: "account_alipay")
  }
}
