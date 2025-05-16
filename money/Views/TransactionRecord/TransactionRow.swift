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
        .foregroundStyle(.primary)
        .padding(.bottom, 1)
        if let notes = transaction.notes {
          Text(notes)
            .font(.caption)
            .foregroundStyle(.secondary)

        }
        Text(CoreFormatter.time(transaction.date))
          .font(.caption)
          .foregroundStyle(.secondary)
      }
      Spacer()
      VStack(alignment: .trailing) {
        Text(transaction.amount, format: .currency(code: "CNY"))
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
      .background(.background)
      .overlay(
        RoundedRectangle(cornerRadius: 16)
          .stroke(Color.gray.opacity(0.2), lineWidth: 1)
      )
      .cornerRadius(16)
      #if os(iOS)
        .contextMenu {
          Button(action: {

          }) {
            Label("复制内容", systemImage: "scissors")
          }

          Button(action: {
            print("分享")
          }) {
            Label("本地保存", systemImage: "square.and.arrow.up")
          }
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
            }
          }

          .frame(width: UIScreen.main.bounds.width, height: 300)

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
