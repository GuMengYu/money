import Foundation
import SwiftData
import SwiftUI

@Model
final class Consumer {
  var name: String
  var avatarData: Data?  // 存储图片的二进制数据
  var isDefault: Bool

  init(name: String, avatarData: Data? = nil, isDefault: Bool = false) {
    self.name = name
    self.avatarData = avatarData
    self.isDefault = isDefault
  }

  // 便于直接用 Image
  var avatarImage: Image {
    if let data = avatarData, let uiImage = UIImage(data: data) {
      return Image(uiImage: uiImage)
    } else {
      return Image(systemName: "person.crop.circle.fill")
    }
  }
}
