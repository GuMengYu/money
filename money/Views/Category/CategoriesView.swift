import SwiftData
import SwiftUI

struct CategoriesView: View {
  @Environment(\.modelContext) private var modelContext
  // 获取顶级分类（没有父分类的分类）
static let rootCategoryPredicate: Predicate<TransactionCategory> = #Predicate { category in
        category.parentCategory == nil
    }

    static let categorySortDescriptors: [SortDescriptor<TransactionCategory>] = [
        SortDescriptor(\.name),
    ]
  @Query(filter: rootCategoryPredicate, sort: categorySortDescriptors)
  private var rootCategories: [TransactionCategory]

  @State private var showingAddCategorySheet = false
  @State private var categoryToEdit: TransactionCategory? = nil
  @State private var categoryToViewSubcategories: TransactionCategory? = nil

  var body: some View {
      List {
        ForEach(TransactionType.allCases, id: \.self) { type in
          Section(header: Text("\(type.rawValue)分类")) {
            let categoriesForType = rootCategories.filter { $0.type == type }
            if categoriesForType.isEmpty {
              Text("暂无\(type.rawValue)分类，请添加。")
                .foregroundColor(.gray)
            } else {
              ForEach(categoriesForType) { category in
                CategoryRow(
                  category: category,
                  onEdit: { editCategory(category) },
                  onViewSubcategories: { viewSubcategories(category) })
              }
              .onDelete { offsets in
                deleteCategories(at: offsets, in: categoriesForType)
              }
            }
          }
        }
      }
      .navigationTitle("交易分类")
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            showingAddCategorySheet = true
          } label: {
            Label("添加分类", systemImage: "plus.circle.fill")
          }
        }
      }
      .sheet(isPresented: $showingAddCategorySheet) {
        AddEditCategoryView(categoryToEdit: nil)  // 添加新的根分类
      }
      .sheet(item: $categoryToEdit) { category in
        AddEditCategoryView(categoryToEdit: category)
      }
      .sheet(item: $categoryToViewSubcategories) { category in
        SubcategoriesView(parentCategory: category)
      }
    
  }

  private func editCategory(_ category: TransactionCategory) {
    categoryToEdit = category
  }

  private func viewSubcategories(_ category: TransactionCategory) {
    categoryToViewSubcategories = category
  }

  private func deleteCategories(at offsets: IndexSet, in categories: [TransactionCategory]) {
    withAnimation {
      offsets.map { categories[$0] }.forEach { category in
        // 先删除子分类，再删除分类本身
        if let subcategories = category.subcategories {
          for subcategory in subcategories {
            modelContext.delete(subcategory)
          }
        }
        modelContext.delete(category)
      }
    }
  }
}

struct CategoryRow: View {
  let category: TransactionCategory
  var onEdit: () -> Void
  var onViewSubcategories: () -> Void

  var body: some View {
    HStack {
      Image(systemName: category.iconName ?? "square.grid.2x2.fill")
        .foregroundColor(.accentColor)
      Text(category.name)
      Spacer()
      // 如果有子分类，显示子分类数量
      if let subcategories = category.subcategories, !subcategories.isEmpty {
        Text("\(subcategories.count) 子分类")
          .font(.caption)
          .foregroundColor(.gray)
      }
      // 查看/管理子分类的按钮
      Button {
        onViewSubcategories()
      } label: {
        Image(systemName: "list.bullet.indent")
      }
      .buttonStyle(BorderlessButtonStyle())

      // 编辑分类的按钮
      Button {
        onEdit()
      } label: {
        Image(systemName: "pencil.circle.fill")
      }
      .buttonStyle(BorderlessButtonStyle())
    }
  }
}
//
//#Preview {
//  let config = ModelConfiguration(isStoredInMemoryOnly: true)
//  let container = try! ModelContainer(
//    for: [TransactionCategory.self, Account.self, TransactionRecord.self], configurations: config)
//
//  // 创建示例数据
//  let food = TransactionCategory(name: "餐饮", type: .expense, iconName: "fork.knife")
//  let income = TransactionCategory(name: "工资", type: .income, iconName: "creditcard.fill")
//  let breakfast = TransactionCategory(name: "早餐", type: .expense, iconName: "sunrise")
//
//  // 设置父子关系
//  breakfast.parentCategory = food
//  if food.subcategories == nil {
//    food.subcategories = []
//  }
//  food.subcategories?.append(breakfast)
//
//  container.mainContext.insert(food)
//  container.mainContext.insert(income)
//  container.mainContext.insert(breakfast)
//
//  CategoriesView()
//    .modelContainer(container)
//}
