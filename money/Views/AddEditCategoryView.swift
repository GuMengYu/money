import SwiftData
import SwiftUI

struct AddEditCategoryView: View {
  @Environment(\.modelContext) private var modelContext
  @Environment(\.dismiss) var dismiss

  // 要编辑的分类，如果是新增则为nil
  var categoryToEdit: TransactionCategory? = nil
  // 如果添加子分类，则指定其父分类
  var parentCategoryForNewSubcategory: TransactionCategory? = nil

  @State private var categoryName: String = ""
  @State private var categoryType: TransactionType = .expense  // 默认为支出类型，可能被父分类覆盖
  @State private var iconName: String = "tag.fill"  // 默认图标

  // 确定是编辑还是新增模式
  private var isEditing: Bool { categoryToEdit != nil }

  // 导航标题
  private var navigationTitle: String {
    if parentCategoryForNewSubcategory != nil {
      return "添加子分类"
    } else {
      return isEditing ? "编辑分类" : "添加分类"
    }
  }

  // 可选的交易类型
  // 如果是编辑现有分类或添加子分类，类型由父分类或现有分类固定
  private var availableTypes: [TransactionType] {
    if let parent = parentCategoryForNewSubcategory {
      return [parent.type]  // 子分类类型必须与父分类相同
    } else if let existing = categoryToEdit {
      return [existing.type]  // 编辑模式下不能更改类型
    } else {
      return TransactionType.allCases  // 新增主分类可以选择任意类型
    }
  }

  // 表单验证
  private var isFormValid: Bool {
    !categoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
  }

  var body: some View {
    NavigationView {
      Form {
        Section("分类信息") {
          TextField("分类名称", text: $categoryName)

          Picker("分类图标", selection: $iconName) {
            // 这里应该是一个完整的图标选择器，但现在只做简单示例
            Text("标签").tag("tag.fill")
            Text("购物车").tag("cart.fill")
            Text("信用卡").tag("creditcard.fill")
            Text("礼物").tag("gift.fill")
            Text("餐饮").tag("fork.knife")
            Text("交通").tag("car.fill")
          }

          if availableTypes.count > 1 {  // 仅当类型不固定时显示选择器
            Picker("交易类型", selection: $categoryType) {
              ForEach(availableTypes, id: \.self) { type in
                Text(type.rawValue).tag(type)
              }
            }
          } else if let fixedType = availableTypes.first {
            LabeledContent("交易类型", value: fixedType.rawValue)
          }
        }
      }
      .navigationTitle(navigationTitle)
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button("取消") { dismiss() }
        }
        ToolbarItem(placement: .navigationBarTrailing) {
          Button(isEditing ? "保存" : "添加") {
            saveCategory()
            dismiss()
          }
          .disabled(!isFormValid)
        }
      }
      .onAppear {
        if let category = categoryToEdit {
          // 编辑模式，加载现有数据
          categoryName = category.name
          categoryType = category.type
          iconName = category.iconName ?? "tag.fill"
        } else if let parent = parentCategoryForNewSubcategory {
          // 添加子分类模式，设置与父分类相同的类型
          categoryType = parent.type
        }
      }
    }
  }

  private func saveCategory() {
    if let category = categoryToEdit {
      // 编辑现有分类
      category.name = categoryName
      category.iconName = iconName
      // 现有分类的类型不应该通过此视图更改，
      // 否则会导致关联交易的复杂数据迁移/验证问题。
    } else {
      // 添加新分类
      let newCategory = TransactionCategory(
        name: categoryName,
        type: categoryType,
        iconName: iconName
      )

      if let parent = parentCategoryForNewSubcategory {
        // 设置父子关系
        newCategory.parentCategory = parent

        // 确保父分类的subcategories数组已初始化
        if parent.subcategories == nil {
          parent.subcategories = []
        }
        parent.subcategories?.append(newCategory)
      }

      modelContext.insert(newCategory)
    }
  }
}

//#Preview("添加模式") {
//  AddEditCategoryView()
//    .modelContainer(for: [TransactionCategory.self], inMemory: true)
//}
//
//#Preview("编辑模式") {
//  let config = ModelConfiguration(isStoredInMemoryOnly: true)
//  let container = try! ModelContainer(for: TransactionCategory.self, configurations: config)
//
//  let sampleCategory = TransactionCategory(name: "餐饮", type: .expense, iconName: "fork.knife")
//  container.mainContext.insert(sampleCategory)
//
//  AddEditCategoryView(categoryToEdit: sampleCategory)
//    .modelContainer(container)
//}
//
//#Preview("添加子分类模式") {
//  let config = ModelConfiguration(isStoredInMemoryOnly: true)
//  let container = try! ModelContainer(for: TransactionCategory.self, configurations: config)
//
//  let parentCategory = TransactionCategory(name: "餐饮", type: .expense, iconName: "fork.knife")
//  container.mainContext.insert(parentCategory)
//
//  AddEditCategoryView(parentCategoryForNewSubcategory: parentCategory)
//    .modelContainer(container)
//}
