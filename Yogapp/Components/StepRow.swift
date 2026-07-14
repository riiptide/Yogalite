import SwiftUI

struct StepRow: View {
    let number: Int
    let step: PracticeStep

    var body: some View {
        if step.kind == .transition, let endPose = step.endPose {
            TransitionStepRow(number: number, step: step, endPose: endPose)
        } else {
            HoldStepRow(number: number, step: step)
        }
    }
}

struct HoldStepRow: View {
    let number: Int
    let step: PracticeStep

    var body: some View {
        rowContent
            .padding(12)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: FlowDesign.cornerMedium, style: .continuous))
            .accessibilityElement(children: .combine)
    }

    private var rowContent: some View {
        HStack(spacing: 12) {
            stepNumber
            PoseIllustrationView(pose: step.startPose, side: step.side)
                .frame(width: 78, height: 72)
                .background(FlowDesign.background)
                .clipShape(RoundedRectangle(cornerRadius: FlowDesign.cornerSmall, style: .continuous))
            textBlock
            Spacer(minLength: 4)
            trailing
        }
    }

    private var stepNumber: some View {
        Text("\(number)")
            .font(.callout.weight(.bold))
            .foregroundStyle(FlowDesign.teal)
            .frame(width: 34, height: 34)
            .background(FlowDesign.paleAqua)
            .clipShape(Circle())
    }

    private var textBlock: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(step.title)
                    .font(.headline)
                    .lineLimit(2)
                Text("Hold")
                    .font(.caption.weight(.bold))
                    .padding(.horizontal, 9)
                    .padding(.vertical, 5)
                    .background(FlowDesign.paleAqua)
                    .foregroundStyle(FlowDesign.teal)
                    .clipShape(Capsule())
                if let side = step.side.displayName {
                    sideBadge(side)
                }
            }
            Text(step.instruction)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var trailing: some View {
        VStack(alignment: .trailing, spacing: 10) {
            Label(step.duration.secondsText, systemImage: "clock")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            BreathBadge(cue: step.breathCue)
        }
    }
}

struct TransitionStepRow: View {
    let number: Int
    let step: PracticeStep
    let endPose: Pose

    var body: some View {
        HStack(spacing: 12) {
            stepNumber
            ZStack {
                HStack(spacing: 0) {
                    PoseIllustrationView(pose: step.startPose, side: step.side)
                    Image(systemName: "arrow.right")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(FlowDesign.teal)
                    PoseIllustrationView(pose: endPose, side: step.endSide)
                }
                .padding(.horizontal, 4)
            }
            .frame(width: 92, height: 72)
            .background(Color(.systemBackground).opacity(0.72))
            .clipShape(RoundedRectangle(cornerRadius: FlowDesign.cornerSmall, style: .continuous))

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(step.title)
                        .font(.headline)
                        .lineLimit(2)
                    Text("Move")
                        .font(.caption.weight(.bold))
                        .padding(.horizontal, 9)
                        .padding(.vertical, 5)
                        .background(Color(.systemBackground).opacity(0.75))
                        .foregroundStyle(FlowDesign.teal)
                        .clipShape(Capsule())
                    if let side = activeSide.displayName {
                        sideBadge(side)
                    }
                }
                Text(step.instruction)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 4)

            VStack(alignment: .trailing, spacing: 10) {
                Label(step.duration.secondsText, systemImage: "clock")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                BreathBadge(cue: step.breathCue)
            }
        }
        .padding(12)
        .background(FlowDesign.paleAqua.opacity(0.72))
        .clipShape(RoundedRectangle(cornerRadius: FlowDesign.cornerMedium, style: .continuous))
        .accessibilityElement(children: .combine)
    }

    private var stepNumber: some View {
        ZStack {
            Circle()
                .fill(FlowDesign.paleAqua)
            Text("\(number)")
                .font(.callout.weight(.bold))
                .foregroundStyle(FlowDesign.teal)
        }
        .frame(width: 34, height: 34)
        .overlay(alignment: .bottomTrailing) {
            Image(systemName: "arrow.triangle.2.circlepath")
                .font(.caption2.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 18, height: 18)
                .background(FlowDesign.teal)
                .clipShape(Circle())
                .offset(x: 5, y: 5)
        }
    }

    private var activeSide: PracticeSide {
        step.endSide == .none ? step.side : step.endSide
    }
}

private func sideBadge(_ side: String) -> some View {
    Text(side)
        .font(.caption.weight(.bold))
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(Color(.systemBackground).opacity(0.75))
        .foregroundStyle(FlowDesign.secondaryText)
        .clipShape(Capsule())
}

#Preview("Hold Row") {
    HoldStepRow(number: 1, step: SunSalutationData.sunSalutationA.steps[0])
        .padding()
        .background(FlowDesign.background)
}

#Preview("Transition Row") {
    TransitionStepRow(number: 2, step: SunSalutationData.sunSalutationA.steps[1], endPose: SunSalutationData.upwardSalute)
        .padding()
        .background(FlowDesign.background)
}
