import MapKit  // For Map view and coordinate region
import SwiftData
import SwiftUI

enum RecordStatus: String, Codable, CaseIterable {
  case completed = "已完成"
  case retired = "已退款"
  var color: Color {
    switch self {
    case .completed:
      return .green
    case .retired:
      return .red
    }
  }
}
struct TransactionDetailView: View {
  // Using @Bindable if we want to allow editing directly from the detail view in the future.
  @Bindable var transaction: TransactionRecord
  @Environment(\.modelContext) private var modelContext
  @Environment(\.dismiss) private var dismiss

  // 用于显示删除确认对话框
  @State private var showingDeleteConfirmation = false

  // State for the map region
  @State private var mapRegion: MKCoordinateRegion?

  // 用于存储地点名称
  @State private var locationName: String = "正在获取地点..."

  @State private var status: RecordStatus = .completed

  var body: some View {
    ScrollView {
      VStack {  // Using Form for a grouped layout, similar to system detail views

        if let coordinate = transaction.coordinate {
          let spot = ParkingSpot(
            name: locationName,
            location: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude),
            cameraDistance: 300
          )

          ZStack {
            Text("Beautiful Map Goes Here")
              .hidden()
              .frame(height: 260)
              .frame(maxWidth: .infinity)
          }
          .background(alignment: .bottom) {
              ParkingSpotShowcaseView(spot: spot, topSafeAreaInset: 0)
//            let title = spot.name
//
//            DetailedMapView(location: spot.location, topSafeAreaInset: 0, title: title)
              #if os(iOS)
                .mask {
                  LinearGradient(
                    stops: [
                      .init(color: .clear, location: 0),
                      .init(color: .black.opacity(0.15), location: 0.1),
                      .init(color: .black, location: 0.6),
                      .init(color: .black, location: 1),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                  )
                }
                .padding(.top, -40)
              #endif
          }
          .overlay(alignment: .bottomTrailing) {
            //                      if let currentWeatherCondition = condition, let willRainSoon = willRainSoon, let symbolName = symbolName {
            //                          CityWeatherCard(
            //                            condition: currentWeatherCondition,
            //                            willRainSoon: willRainSoon,
            //                            symbolName: symbolName
            //                          )
            //                          .padding(.bottom)
            //                      }
          }
        }
        VStack(alignment: .leading, spacing: 8) {
          Text(transaction.category?.name ?? "").font(.title)
            .fontWeight(.semibold)
          HStack {
            VStack(alignment: .leading) {
              HStack {
                Image(systemName: "list.bullet.clipboard.fill")
                Text(transaction.notes ?? "")
              }
              HStack {
                Image(systemName: "calendar")
                  Text(CoreFormatter.formattedDate(transaction.date))
              }
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            Spacer()
            Menu {
              Picker(selection: $status, label: EmptyView()) {
                ForEach(RecordStatus.allCases, id: \.self) {
                  Text($0.rawValue)
                }
              }
            } label: {
              HStack(spacing: 2) {
                Image(systemName: "checkmark.seal.fill")
                  .resizable()
                  .scaledToFit()
                  .frame(width: 12)
                Text(status.rawValue)
                  .font(.footnote)
                  .fontWeight(.semibold)
              }
              .foregroundStyle(status.color)
              .padding(.vertical, 6)
              .padding(.horizontal, 8)
              .background(status.color.opacity(0.2))
              .cornerRadius(10)
              .overlay(RoundedRectangle(cornerRadius: 10).stroke(status.color, lineWidth: 1))
            }

          }

          HStack {
            Budge(
              title: transaction.transactionType.rawValue,
              icon: Image(systemName: "arrow.up.backward.circle.fill"), color: transaction.transactionType.color)
            Budge(
              title: transaction.account?.name ?? "", icon: Image(systemName: "creditcard.fill"),
              color: .accentColor)
            Budge(
              title: transaction.date.formatted(date: .omitted, time: .shortened),
              icon: Image(systemName: "clock.fill"), color: .teal)
          }

//          LabeledContent("类型", value: transaction.transactionType.rawValue)
//          LabeledContent("金额") {
//            Text(transaction.amount, format: .currency(code: "CNY"))
//              .foregroundColor(
//                transaction.transactionType == .income
//                  ? .green : (transaction.transactionType == .expense ? .red : .primary))
//          }
//          LabeledContent("账户", value: transaction.account?.name ?? "N/A")
//
//          if transaction.transactionType == .transfer {
//            LabeledContent("转入账户", value: transaction.toAccount?.name ?? "N/A")
//          }
//
//          if let categoryName = transaction.category?.name {
//            LabeledContent("分类", value: categoryName)
//          }
//
//          LabeledContent(
//            "日期", value: transaction.date, format: .dateTime.year().month().day().hour().minute())
//
//          if let notes = transaction.notes, !notes.isEmpty {
//            LabeledContent("备注") {
//              Text(notes)
//            }
//          }

          // 添加删除按钮
            Spacer()
            VStack {
                Button(role: .destructive) {
                  showingDeleteConfirmation = true
                } label: {
                  HStack {
                    Spacer()
                    Text("删除交易")
                    Spacer()
                  }
                }
            }
            
        }.padding(.horizontal)
      }
    }

    .alert("确认删除", isPresented: $showingDeleteConfirmation) {
      Button("取消", role: .cancel) {}
      Button("删除", role: .destructive) {
        deleteTransaction()
        dismiss()  // 删除后返回列表
      }
    } message: {
      Text("确定要删除这笔交易记录吗？此操作无法撤销。")
    }
    .onAppear {
      performReverseGeocoding()
    }
  }

  // 删除交易并更新相关账户余额
  private func deleteTransaction() {
    // 在删除交易前，先反向更新相关账户的余额
    reverseAccountBalanceUpdates(for: transaction)

    // 删除交易
    modelContext.delete(transaction)
  }

  // 反向更新账户余额（删除交易时使用）
  private func reverseAccountBalanceUpdates(for transaction: TransactionRecord) {
    guard let account = transaction.account else { return }

    switch transaction.transactionType {
    case .income:
      // 删除收入：减少账户余额
      account.balance -= transaction.amount

    case .expense:
      // 删除支出：增加账户余额
      account.balance += transaction.amount

    case .transfer:
      // 删除转账：增加源账户余额，减少目标账户余额
      guard let toAccount = transaction.toAccount else { return }
      account.balance += transaction.amount
      toAccount.balance -= transaction.amount
    }
  }

  // 执行反向地理编码
  private func performReverseGeocoding() {
    guard let coordinate = transaction.coordinate else { return }

    let geocoder = CLGeocoder()
    let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)

    geocoder.reverseGeocodeLocation(location) { placemarks, error in
      if let error = error {
        print("反向地理编码错误: \(error.localizedDescription)")
        locationName = "未知地点"
        return
      }

      if let placemark = placemarks?.first {
        // 构建地点名称
        var components: [String] = []

        if let name = placemark.name {
          components.append(name)
        }
        if let locality = placemark.locality {
          components.append(locality)
        }
        if let administrativeArea = placemark.administrativeArea {
          components.append(administrativeArea)
        }

        locationName = components.joined(separator: ", ")
      } else {
        locationName = "未知地点"
      }
    }
  }
}

// Helper struct to make CLLocationCoordinate2D Identifiable for Map annotationItems
private struct IdentifiableCoordinate: Identifiable {
  let id = UUID()
  var coordinate: CLLocationCoordinate2D
}

struct Budge: View {
  var title: String
  var icon: Image
  var color: Color
  var body: some View {
    HStack(spacing: 2) {
      icon
        .resizable()
        .scaledToFit()
        .frame(width: 12)
      Text(title)
            .font(.caption)
        .fontWeight(.semibold)
    }
    .foregroundStyle(color)
    .padding(.vertical, 4)
    .padding(.horizontal, 6)
    .background(color.opacity(0.2))
    .cornerRadius(6)
    .overlay(RoundedRectangle(cornerRadius: 6).stroke(color, lineWidth: 1))
  }
}

#Preview {
  struct PreviewWrapper: View {

    let sampleTransactionWithLocation = TransactionRecord(
      amount: 125.50,
      transactionType: .expense,
      date: Date(),
      notes: "午餐和咖啡",
      latitude: 31.2304,  // Shanghai latitude
      longitude: 121.4737,  // Shanghai longitude
      account: Account(name: "储蓄卡", type: .savings, balance: 1000),
      category: TransactionCategory(name: "餐饮", type: .expense)
    )

    var body: some View {
      NavigationView {
        // Use one of the sample transactions for the preview
        TransactionDetailView(transaction: sampleTransactionWithLocation)
      }
    }
  }
  return PreviewWrapper()
}
