import SwiftData
import SwiftUI

struct SubcategoriesView: View {
  @Environment(\.modelContext) private var modelContext
  // 父分类，用于显示其子分类
  @Bindable var parentCategory: TransactionCategory

  @State private var showingAddSubcategorySheet = false
  @State private var subcategoryToEdit: TransactionCategory? = nil

  // 计算属性：获取并排序子分类
  private var subcategories: [TransactionCategory] {
    parentCategory.subcategories?.sorted(by: { $0.name < $1.name }) ?? []
  }

  var body: some View {
    NavigationView {
      List {
        if subcategories.isEmpty {
          Text("暂无子分类。点击\"+\"添加一个。")
            .foregroundColor(.gray)
            .frame(maxWidth: .infinity, alignment: .center)
            .listRowBackground(Color.clear)
        } else {
          ForEach(subcategories) { subcategory in
            HStack {
              Image(systemName: subcategory.iconName ?? "square.grid.2x2.fill")
                .foregroundColor(.accentColor)
              Text(subcategory.name)
              Spacer()
              Button {
                subcategoryToEdit = subcategory
              } label: {
                Image(systemName: "pencil.circle.fill")
              }
              .buttonStyle(BorderlessButtonStyle())
            }
          }
          .onDelete(perform: deleteSubcategories)
        }
      }
      .navigationTitle("\(parentCategory.name) - 子分类")
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          if !subcategories.isEmpty {
            EditButton()
          }
        }
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            showingAddSubcategorySheet = true
          } label: {
            Label("添加子分类", systemImage: "plus.circle.fill")
          }
        }
      }
      .sheet(isPresented: $showingAddSubcategorySheet) {
        AddEditCategoryView(parentCategoryForNewSubcategory: parentCategory)
      }
      .sheet(item: $subcategoryToEdit) { category in
        AddEditCategoryView(categoryToEdit: category)
      }
    }
  }

  private func deleteSubcategories(offsets: IndexSet) {
    withAnimation {
      offsets.map { subcategories[$0] }.forEach(modelContext.delete)
    }
  }
}

//#Preview {
//  let config = ModelConfiguration(isStoredInMemoryOnly: true)
//  let container = try! ModelContainer(for: TransactionCategory.self, configurations: config)
//
//  // 创建父分类
//  let food = TransactionCategory(name: "餐饮", type: .expense, iconName: "fork.knife")
//  container.mainContext.insert(food)
//
//  // 创建子分类
//  let breakfast = TransactionCategory(name: "早餐", type: .expense, iconName: "sunrise")
//  breakfast.parentCategory = food
//  container.mainContext.insert(breakfast)
//
//  let lunch = TransactionCategory(name: "午餐", type: .expense, iconName: "sun.max")
//  lunch.parentCategory = food
//  container.mainContext.insert(lunch)
//
//  // 手动设置父分类的子分类数组（预览时可能需要）
//  if food.subcategories == nil {
//    food.subcategories = []
//  }
//  food.subcategories?.append(breakfast)
//  food.subcategories?.append(lunch)
//
//  SubcategoriesView(parentCategory: food)
//    .modelContainer(container)
//}
