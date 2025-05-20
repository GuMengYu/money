import PhotosUI
import SwiftData
import SwiftUI

struct ConsumerView: View {
  @Environment(\.modelContext) private var modelContext
  @Query(sort: \Consumer.name) private var consumers: [Consumer]
  @State private var showAddSheet = false
  @State private var editingConsumer: Consumer? = nil
  @State private var selectedPhoto: PhotosPickerItem? = nil
  @State var avatarImage: UIImage? = nil

  var body: some View {
    VStack(spacing: 16) {
      List {
        ForEach(consumers) { consumer in
          HStack {
            consumer.avatarImage
              .resizable()
              .scaledToFill()
              .frame(width: 40, height: 40)
              .clipShape(Circle())
              .overlay(Circle().stroke(Color.gray.opacity(0.2), lineWidth: 1))
            Text(consumer.name)
              .font(.body)
            Spacer()
            if consumer.isDefault {
              Text("默认")
                .font(.caption)
                .foregroundColor(.gray)
            }
          }
          .contentShape(Rectangle())
          .onTapGesture {
            editingConsumer = consumer
          }
          .swipeActions {
            Button(role: .destructive) {
              withAnimation { modelContext.delete(consumer) }
            } label: {
              Label("删除", systemImage: "trash")
            }
            Button {
              setDefault(consumer)
            } label: {
              Label("设为默认", systemImage: "star")
            }
            .tint(.yellow)
          }
        }
      }
    }
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        Button {
            showAddSheet = true
        } label: {
          Label("添加消费对象", systemImage: "plus.circle.fill")
        }
      }
    }
    .navigationTitle("Target Consumer")
    .sheet(item: $editingConsumer) { consumer in
      EditConsumerSheet(consumer: consumer)
    }
    .sheet(isPresented: $showAddSheet) {
      EditConsumerSheet(consumer: nil)
    }
  }

  private func setDefault(_ consumer: Consumer) {
    for c in consumers {
      c.isDefault = (c == consumer)
    }
  }
}

// 编辑/新增消费对象
struct EditConsumerSheet: View {
  @Environment(\.modelContext) private var modelContext
  @Environment(\.dismiss) private var dismiss

  @State var name: String = ""
  @State var avatarImage: UIImage? = nil
  @State private var selectedPhoto: PhotosPickerItem? = nil

  var consumer: Consumer?

  var body: some View {
    NavigationView {
      Form {
        Section("头像") {
          HStack {
            if let avatarImage {
              Image(uiImage: avatarImage)
                .resizable()
                .scaledToFill()
                .frame(width: 60, height: 60)
                .clipShape(Circle())
            } else {
              Image(systemName: "person.crop.circle.fill")
                .resizable()
                .frame(width: 60, height: 60)
                .foregroundColor(.gray)
            }
            Spacer()
            PhotosPicker(
              selection: $selectedPhoto,
              matching: .images,
              photoLibrary: .shared()
            ) {
              Text("选择图片")
            }
          }
        }
        .onChange(of: selectedPhoto) { newItem, oldItem in
          if let newItem {
            Task {
              if let data = try? await newItem.loadTransferable(type: Data.self),
                let img = UIImage(data: data)
              {
                avatarImage = img
              }
            }
          }
        }
        Section("名称") {
          TextField("请输入名称", text: $name)
        }
      }
      .navigationTitle(consumer == nil ? "添加消费对象" : "编辑消费对象")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("取消") { dismiss() }
        }
        ToolbarItem(placement: .confirmationAction) {
          Button("保存") {
            save()
            dismiss()
          }
          .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
        }
      }
      .onAppear {
        if let consumer {
          name = consumer.name
          if let data = consumer.avatarData, let img = UIImage(data: data) {
            avatarImage = img
          }
        }
      }
    }
  }

  private func save() {
    if let consumer {
      consumer.name = name
      if let img = avatarImage {
        consumer.avatarData = img.jpegData(compressionQuality: 0.8)
      }
    } else {
      let newConsumer = Consumer(
        name: name,
        avatarData: avatarImage?.jpegData(compressionQuality: 0.8),
        isDefault: false
      )
      modelContext.insert(newConsumer)
    }
  }
}
