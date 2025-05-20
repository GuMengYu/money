//
//  HeightReader.swift
//  money
//
//  Created by Yoda on 2025/5/18.
//
import SwiftUI

// 高度读取工具
struct HeightReader: View {
  @Binding var height: CGFloat

  var body: some View {
    GeometryReader { geo in
      Color.clear
        .onAppear {
          height = geo.size.height
        }
        .onChange(of: geo.size.height) { oldValue, newValue in
          height = newValue
        }
    }
  }
}
