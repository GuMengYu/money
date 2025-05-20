//
//  NumberInputNew.swift
//  SwiftDataSample
//
//  Created by Yoda on 2025/4/5.
//

import SwiftUI
import TipKit

// 定义一个提示

//struct SampleTip: Tip {
//    var title: Text {
//        Text("Save as a Favorite")
//    }
//
//
//    var message: Text? {
//        Text("Your favorite backyards always appear at the top of the list.")
//    }
//
//    // 定义全局参数（控制提示是否显示）
//    @Parameter
//    static var hasTap: Bool = false
//
//    // 规则：当从未长按过按钮时显示提示
//    var rules: [Rule] {
//        #Rule(Self.$hasTap) { $0 == true }
//    }
//}
struct NumberInputView: View {
  let title: String
  let tips: String?
  let accuracy: Int
  @Binding var value: String
  @Environment(\.dismiss) private var dismiss
  @EnvironmentObject private var sheetManager: SheetManager
  //var tip = SampleTip()

  @State private var input = ""
  @State private var showCalculation = false

  var body: some View {
    VStack(spacing: 12) {
      // Header
//      HStack {
//        Text(title).font(.headline.bold())
//          .padding(.vertical, 12)
//        Image(systemName: "info.circle")
//          .foregroundStyle(.secondary)
//          .onTapGesture {
//            sheetManager.showAlertSheet(
//              title: "关于\(title)", message: "计算器哦计算器哦计算器哦计算器哦计算器哦计算器哦计算器哦计算器哦计算器哦计算器哦计算器哦计算器哦")
//          }
//      }

      // Input Display
      TextFieldDisplay(text: $input)

      // Keyboard Grid
      LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 4), spacing: 6)
      {
        ForEach(NumberKey.allCases) { key in
          KeyButton(
            key: key,
            showEqual: showCalculation,
            action: handleInput
          )
        }
      }
    }
    .padding()
    .onAppear { input = value }
  }

  private func handleInput(_ key: NumberKey) {
    switch key {
    case .number(let num):
      input = input == "0" ? num : input + num
    case .operation(let op):
      handleOperation(op)
    case .equal:
      calculateResult()
    case .delete:
      deleteLast()
    case .dot:
      handleDot()
    case .ok:
      commitResult()
    }
    updateCalculationFlag()
  }

  private func handleOperation(_ op: Operation) {
    guard let last = input.last else { return }
    print("\(last)  \(op)")

    if op == .multiplyDivide {
      if last.isMathOperator {
        if String(last) == Operation.multiplication.rawValue {
          input.removeLast()
          input.append(Operation.division.rawValue)
        } else if String(last) == Operation.division.rawValue {
          input.removeLast()
          input.append(Operation.multiplication.rawValue)
        }
      } else {
        calculateResult()
        input.append(Operation.multiplication.rawValue)
      }
    } else if op == .addSubtract {
      if last.isMathOperator {
        if String(last) == Operation.addition.rawValue {
          input.removeLast()
          input.append(Operation.subtraction.rawValue)
        } else if String(last) == Operation.subtraction.rawValue {
          input.removeLast()
          input.append(Operation.addition.rawValue)
        }
      } else {
        calculateResult()
        input.append(Operation.addition.rawValue)
      }
    }
  }

  private func calculateResult() {
    // Step 1: 替换符号并强制将整数转为浮点数（例如 1 → 1.0）
    print(input)

    let expression =
      input
      .replacingOccurrences(of: "×", with: "*")
      .replacingOccurrences(of: "÷", with: "/")
      // 正则替换所有独立整数为浮点数（例如 "1" → "1.0"）
      .replacingOccurrences(
        of: "(?<![\\d.])(\\d+)(?![\\d.])",
        with: "$1.0",
        options: .regularExpression
      )

    // Step 2: 处理空表达式
    guard !expression.isEmpty else {
      input = "Error"
      return
    }

    let mathExpression = NSExpression(format: expression)
    guard let result = mathExpression.expressionValue(with: nil, context: nil) as? Double else {
      input = "Error"
      return
    }
    input = formatResult(result)

  }

  //    // 示例格式化函数（按需实现）
  //    private func formatResult(_ value: Double) -> String {
  //        return String(format: "%g", value) // 自动去除多余的 .0
  //    }

  private func formatResult(_ value: Double) -> String {
    let formatter = NumberFormatter()
    formatter.minimumFractionDigits = 0
    formatter.maximumFractionDigits = accuracy
    // formatter.numberStyle = .decimal
    return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
  }

  private func deleteLast() {
    guard !input.isEmpty else { return }
    input.removeLast()
    if input.isEmpty { input = "0" }
  }

  private func handleDot() {
    let parts = input.components(separatedBy: .mathOperators)
    guard let lastPart = parts.last, !lastPart.contains(".") else { return }
    input += input.isEmpty ? "0." : "."
  }

  private func updateCalculationFlag() {
    showCalculation = input.contains { $0.isMathOperator }
  }

  private func clearInput() {
    input = "0"
  }

  private func commitResult() {
    value = input
    dismiss()
  }
}

// MARK: - Subviews
private struct TextFieldDisplay: View {
  @Binding var text: String

  var body: some View {
    HStack {
      Text(text.isEmpty ? "请输入" : text)
        .font(.title3.bold())
        .lineLimit(1)
        .minimumScaleFactor(0.5)
        .frame(maxWidth: .infinity, alignment: .leading)

      if !text.isEmpty && text != "0" {
        Image(systemName: "xmark.circle.fill")
          .foregroundStyle(.secondary)
          .onTapGesture { text = "0" }
      }
    }
    .padding(.horizontal, 16)
    .frame(height: 50)
    .background(
      RoundedRectangle(cornerRadius: 16)
        .stroke(Color.primary, lineWidth: 2)
    )
  }
}

private struct KeyButton: View {
  let key: NumberKey
  let showEqual: Bool
  let action: (NumberKey) -> Void

  private let feedback = UIImpactFeedbackGenerator(style: .medium)
  var currentKey: NumberKey {
    return key
  }

  var backgroundColor: Color {
    switch currentKey {
    case .operation: return .blue.opacity(0.2)
    case .equal, .ok: return .green.opacity(0.2)
    case .delete: return .red.opacity(0.2)
    default: return .gray.opacity(0.1)
    }
  }

  var body: some View {
    GeometryReader { geometry in
      Button {
        action(currentKey)
        // add hapic
        feedback.impactOccurred()
      } label: {
        Group {
          switch currentKey {
          case .number(let num):
            Text(num)
          case .operation(let op):
            Text(op.rawValue)
          case .equal:
            Text("=")
          case .delete:
            Image(systemName: "delete.left")
              .resizable()
              .scaledToFit()
              .frame(width: 24)
          case .dot:
            Text(".")
          case .ok:
            Text("完成").font(.title2).fontWeight(.semibold)
          }
        }
        .font(.title.bold())
        .fontDesign(.rounded)
      }
      .buttonStyle(.plain)
      .frame(width: geometry.size.width, height: geometry.size.width)
      .background(backgroundColor)
      .clipShape(RoundedRectangle(cornerRadius: 26))
    }.aspectRatio(1, contentMode: .fit)
  }
}

// MARK: - Models
enum NumberKey: Identifiable, CaseIterable {
  case number(String)
  case operation(Operation)
  case equal
  case delete
  case dot
  case ok

  var id: String {
    switch self {
    case .number(let num): return num
    case .operation(let op): return op.rawValue
    case .equal: return "="
    case .delete: return "delete"
    case .dot: return "."
    case .ok: return "ok"
    }
  }

  static var allCases: [NumberKey] {
    [
      .number("1"), .number("2"), .number("3"), .operation(.multiplyDivide),
      .number("4"), .number("5"), .number("6"), .operation(.addSubtract),
      .number("7"), .number("8"), .number("9"), .equal,
      .dot, .number("0"), .delete, .ok,
    ]
  }
}

enum Operation: String {
  case addSubtract = "+-"
  case multiplyDivide = "×÷"
  case addition = "+"
  case subtraction = "-"
  case multiplication = "×"
  case division = "÷"
  case dot = "."
}

// MARK: - Extensions
extension Character {
  var isMathOperator: Bool {
    "+-×÷".contains(self)
  }
}

// 修改字符集扩展（关键修复）
extension CharacterSet {
  static var mathOperators: CharacterSet {
    CharacterSet(charactersIn: "+-×÷")
  }
}

extension String {
  var last: Character? {
    isEmpty ? nil : self[index(before: endIndex)]
  }
}

extension Collection where Element == Character {
  var mathOperators: CharacterSet {
    CharacterSet(charactersIn: "+-×/")
  }
}
//
//// MARK: - Tip
//struct NumberInputTip: Tip {
//    let content: String
//    let title: String
//
//    var message: Text? { Text(content) }
//    var image: Image? { Image(systemName: "info.circle") }
//}

#Preview {
  @Previewable @State var value: String = ""
  NumberInputView(
    title: "价格输入",
    tips: nil,
    accuracy: 2,
    value: $value)
}
