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
  var icon: Image {
    switch self {
    case .completed:
      return Image(systemName: "checkmark.circle.fill")
    case .retired:
      return Image(systemName: "arrowshape.turn.up.backward.circle.fill")
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
            cameraDistance: 800
          )

          ZStack {
            Text("Beautiful Map Goes Here")
              .hidden()
              .frame(height: 300)
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
                .padding(.top, -100)
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
          Text(transaction.category?.name ?? "").font(.largeTitle)
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
              HStack(spacing: 4) {
                status.icon
                  .resizable()
                  .scaledToFit()
                  .frame(width: 16)
                Text(status.rawValue)
                  .font(.subheadline)
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

          ScrollView(.horizontal) {
            HStack {
              Budge(
                title: transaction.transactionType.rawValue,
                icon: Image(systemName: "arrow.up.backward.circle.fill"),
                color: transaction.transactionType.color)
              Budge(
                title: transaction.account?.name ?? "", icon: Image(systemName: "creditcard.fill"),
                color: .accentColor)
              Budge(
                title: transaction.date.formatted(date: .omitted, time: .shortened),
                icon: Image(systemName: "clock.fill"), color: .teal)
              Budge(
                title: "CNY",
                icon: Image(systemName: "chineseyuanrenminbisign.circle.fill"), color: .red)
            }
            .padding(.vertical, 5)
            .padding(.horizontal, 1)
          }
          .scrollIndicators(.hidden)
          //            Divider()
          HStack {

            Text(transaction.amount, format: .currency(code: "CNY"))
              .font(.title)
              .bold()
              .fontDesign(.rounded)
              .foregroundColor(transaction.transactionType.color)
          }
          Divider()
          VStack(alignment: .leading, spacing: 4) {
            Text("消费对象")
              .font(.caption)
              .foregroundStyle(.secondary)
            if !transaction.consumers.isEmpty {
              ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                  ForEach(transaction.consumers) { consumer in
                    HStack(spacing: 4) {
                      consumer.avatarImage
                        .resizable()
                        .scaledToFill()
                        .frame(width: 28, height: 28)
                        .clipShape(Circle())
                      Text(consumer.name)
                        .font(.caption)
                    }
                    .padding(.trailing, 8)
                  }
                }
              }
            } else {
              Text("无")
                .font(.caption)
                .foregroundStyle(.tertiary)
            }
          }
          VStack(alignment: .leading) {
            HStack(alignment: .center) {
              Text("评论&附件")
                .font(.caption)
                .foregroundStyle(.secondary)
              Spacer()
              Button {

              } label: {
                Image(systemName: "plus.circle.fill")
                  .resizable()
                  .scaledToFit()
                  .frame(width: 12)
              }
            }

          }
          .padding(.vertical)
        }.padding(.horizontal)
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
    HStack(spacing: 3) {
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
    .background(color.opacity(0.1))
    .cornerRadius(6)
    .overlay(RoundedRectangle(cornerRadius: 6).stroke(color.opacity(0.4), lineWidth: 0.5))
  }
}

struct ConsumerItemView: View {
  var body: some View {
    VStack {
      Image("memoji/angela_appy")
        .resizable()
        .scaledToFit()
        .frame(width: 36)
        .foregroundStyle(.primary)
        .frame(width: 48, height: 48)
        .background(.green.opacity(0.2))
        .clipShape(Circle())
      Text("爸比").font(.caption2).foregroundStyle(.secondary)
    }
  }
}

#Preview {
  struct PreviewWrapper: View {

    let sampleTransactionWithLocation = TransactionRecord.sampleItems[0]

    var body: some View {
      NavigationView {
        // Use one of the sample transactions for the preview
        TransactionDetailView(transaction: sampleTransactionWithLocation)
      }
    }
  }
  return PreviewWrapper()
}
