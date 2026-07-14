import SwiftUI

struct CircularCountdownView: View {
    let remainingTime: TimeInterval
    let duration: TimeInterval
    var size: CGFloat = 112

    private var progress: Double {
        guard duration > 0 else { return 0 }
        return min(max(remainingTime / duration, 0), 1)
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(FlowDesign.teal.opacity(0.16), lineWidth: 10)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(FlowDesign.teal, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.2), value: progress)
            VStack(spacing: 2) {
                Text("\(Int(ceil(remainingTime)))")
                    .font(.system(.title, design: .rounded, weight: .bold))
                    .monospacedDigit()
                Text("sec")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: size, height: size)
        .accessibilityLabel("\(Int(ceil(remainingTime))) seconds remaining")
    }
}

#Preview {
    CircularCountdownView(remainingTime: 8, duration: 15)
        .padding()
}
