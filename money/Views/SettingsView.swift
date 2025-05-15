import SwiftUI

struct SettingsView: View {
  var body: some View {

    NavigationStack {  // Standard practice for root views in a tab or navigation hierarchy
      List {
        Section {
          NavigationLink {
            CategoriesView()
          } label: {
            Label("分类", systemImage: "list.bullet.clipboard")
          }
            NavigationLink {
                CategoriesView()
             } label: {
                        HStack {
                          Image(systemName: "paintpalette")
                          Text("外观")
                        }
                      }
            Text("货币 (待实现)")
        } header: {
          Text("通用设置")
        }  // Using Form for a familiar settings layout
       

        Section(header: Text("数据管理")) {
          Text("导出数据 (待实现)")
          Text("导入数据 (待实现)")
          Button("清除所有数据 (待实现)", role: .destructive) {
            // Action to clear data would go here
            print("清除所有数据按钮被点击")
          }
        }

        Section(header: Text("关于")) {
          LabeledContent("应用版本", value: "1.0.0 (Alpha)")
          Text("隐私政策 (待实现)")
          Text("服务条款 (待实现)")
        }
      }
      .navigationTitle("设置")
    }
  }
}

#Preview {
  SettingsView()
}
