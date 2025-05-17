//
//  TransactionRow.swift
//  money
//
//  Created by Yoda on 2025/5/16.
//

import MapKit
import SwiftUI

struct TransactionRow: View {
  let transaction: TransactionRecord
  // on delete
  let onDelete: () -> Void

  var info: some View {
    HStack {
      Image(systemName: transaction.category?.iconName ?? "chineseyuanrenminbisign.ring")
        .resizable()
        .scaledToFit()
        .frame(width: 18, height: 18)
        .foregroundStyle(transaction.transactionType.color)
        .padding(8)
        .background(transaction.transactionType.color.opacity(0.2))
        .cornerRadius(28)
        .overlay(
          RoundedRectangle(cornerRadius: 28)
            .stroke(transaction.transactionType.color.opacity(0.3), lineWidth: 1)
        )

      VStack(alignment: .leading) {
        Text(
          transaction.category?.name ?? (transaction.transactionType == .transfer ? "转账" : "未分类")
        )
        .font(.subheadline).fontWeight(.semibold)
        .foregroundStyle(transaction.transactionType.color)
        .padding(.bottom, 1)
        if let notes = transaction.notes {
          Text(notes)
            .font(.caption)
            .tint(.primary)

        }
        Text(CoreFormatter.time(transaction.date))
          .font(.caption)
          .tint(.primary)
      }
      Spacer()
      VStack(alignment: .trailing) {
        Text(
          "\(transaction.transactionType == .income ? "+" : "-")\(transaction.amount, format: .currency(code: "CNY"))"
        )
        .font(.headline)
        .fontDesign(.rounded)
        .fontWeight(.semibold)
        .foregroundColor(
          transaction.transactionType.color)

        if let account = transaction.account {
          Text("#\(account.name)")
            .font(.caption)
            .foregroundStyle(.secondary)
          //            Budge(title: account.name, icon: Image(systemName: "creditcard"), color: transaction.transactionType.color)

        }
      }
    }
  }
  var body: some View {
    info
      .padding(.horizontal, 12)
      .padding(.vertical, 14)
      .background(.thickMaterial)
      .cornerRadius(16)
      #if os(iOS)
        .contextMenu {
          Button(action: {

          }) {
            Label("选择", systemImage: "checkmark.circle")
          }

          Menu {
            Button(action: {
              print("编辑")
            }) {
              Label("增加标签", systemImage: "tag")
            }

            Button(action: {
            }) {
              Label("编辑交易", systemImage: "pencil")
            }
           
          } label: {
            Label("编辑", systemImage: "square.and.pencil")
          }
            Button(action: {
            }) {
              Label("标记为待确认", systemImage: "checklist.unchecked")
            }
            Button(action: {
            }) {
              Label("标记为确认", systemImage: "checklist.checked")
            }
          Divider()

          Button(
            role: .destructive,
            action: {
              onDelete()
            }
          ) {
            Label("删除记录", systemImage: "trash.fill")
          }
        } preview: {
          VStack {
            info
            .padding(12)

            if transaction.latitude != nil && transaction.longitude != nil {
              let spot = ParkingSpot(
                name: "",
                location: CLLocation(
                  latitude: transaction.latitude!, longitude: transaction.longitude!),
                cameraDistance: 2000)
              ParkingSpotShowcaseView(spot: spot, topSafeAreaInset: 0, animated: false)
              .frame(height: 200)
            }
          }

          .frame(width: UIScreen.main.bounds.width)

        }
      #endif
  }
}

#Preview {

  VStack {
    ForEach(TransactionRecord.sampleItems, id: \.self) { transaction in
      TransactionRow(
        transaction: transaction, onDelete: {}
      )
    }
  }
  .padding()
}
