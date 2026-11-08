import SwiftUI

/// 오늘 진행률. 다 마치면 초록으로.
struct ProgressRing: View {
    var done: Int
    var total: Int
    var size: CGFloat = 56
    var lineWidth: CGFloat = 6

    private var fraction: Double { total == 0 ? 0 : Double(done) / Double(total) }
    private var percent: Int { Int((fraction * 100).rounded()) }
    private var tint: Color { total > 0 && done == total ? .green : .accentColor }

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.secondary.opacity(0.18), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: fraction)
                .stroke(tint, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.snappy, value: fraction)
            Text("\(percent)%")
                .font(.system(size: size * 0.23, weight: .semibold, design: .rounded))
                .monospacedDigit()
        }
        .frame(width: size, height: size)
        .accessibilityLabel("오늘 진행률 \(percent)퍼센트")
    }
}
