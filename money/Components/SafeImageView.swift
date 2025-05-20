//
//  SafeImageView.swift
//  SwiftDataSample
//
//  Created by Yoda on 2025/5/6.
//

import SwiftUI

struct SafeImageView: View {
    private let imageName: String
    private let placeholderName: String
    private let isPlaceholderSystemImage: Bool // 标记占位符是否是 SF Symbol

    /// 初始化一个安全显示图片的视图
    /// - Parameters:
    ///   - name: 尝试加载的图片名称 (来自 Assets)
    ///   - placeholder: 如果找不到主图片，使用的后备图片名称 (来自 Assets)
    init(name: String, placeholder: String) {
        self.imageName = name
        self.placeholderName = placeholder
        self.isPlaceholderSystemImage = false
    }

    /// 初始化一个安全显示图片的视图
    /// - Parameters:
    ///   - name: 尝试加载的图片名称 (来自 Assets)
    ///   - systemPlaceholder: 如果找不到主图片，使用的后备 SF Symbol 名称
    init(name: String, systemPlaceholder: String) {
        self.imageName = name
        self.placeholderName = systemPlaceholder
        self.isPlaceholderSystemImage = true
    }

    var body: some View {
        resolveImage()
    }

    private func resolveImage() -> Image {
        #if os(macOS)
        if NSImage(named: imageName) != nil {
            return Image(imageName)
        } else {
            print("Warning: Image asset '\(imageName)' not found. Using placeholder '\(placeholderName)'.")
            return placeholderImage()
        }
        #else
        if UIImage(named: imageName) != nil {
            return Image(imageName).resizable()
        } else {
            print("Warning: Image asset '\(imageName)' not found. Using placeholder '\(placeholderName)'.")
            // 最好也检查一下占位符是否存在（如果它不是 System Image）
            if !isPlaceholderSystemImage && UIImage(named: placeholderName) == nil {
                 print("Error: Placeholder image asset '\(placeholderName)' also not found. Using system symbol.")
                 return Image(systemName: "exclamationmark.triangle.fill")
            }
            return placeholderImage()
        }
        #endif
    }

    private func placeholderImage() -> Image {
        if isPlaceholderSystemImage {
            return Image(systemName: placeholderName).resizable()
        } else {
            return Image(placeholderName).resizable()
        }
    }
}
