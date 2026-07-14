import SwiftUI

struct PoseIllustrationView: View {
    let pose: Pose
    var side: PracticeSide = .none
    var isBreathing = false
    @State private var breathScale = 1.0

    var body: some View {
        Group {
            if pose.hasRasterAsset {
                RasterPoseImageView(pose: pose)
            } else {
                PoseFigureView(config: PoseFigureConfiguration.configuration(for: pose), progress: 1)
            }
        }
            .scaleEffect(x: side == .left ? -1 : 1, y: 1)
            .scaleEffect(isBreathing ? breathScale : 1)
            .animation(isBreathing ? .easeInOut(duration: 2.8).repeatForever(autoreverses: true) : .default, value: breathScale)
            .onAppear {
                guard isBreathing else { return }
                breathScale = 1.035
            }
            .accessibilityLabel(pose.name)
    }
}

struct PoseTransitionView: View {
    let startPose: Pose
    let endPose: Pose
    let progress: Double
    let isPaused: Bool
    var startSide: PracticeSide = .none
    var endSide: PracticeSide = .none

    var body: some View {
        Group {
            if startPose.hasRasterAsset, endPose.hasRasterAsset {
                RasterPoseTransitionView(startPose: startPose, endPose: endPose, progress: progress, startSide: startSide, endSide: endSide)
            } else {
                PoseFigureView(
                    config: PoseFigureConfiguration.interpolate(
                        from: .configuration(for: startPose),
                        to: .configuration(for: endPose),
                        progress: progress
                    ),
                    progress: progress
                )
                .scaleEffect(x: (progress < 0.5 ? startSide : endSide) == .left ? -1 : 1, y: 1)
            }
        }
        .animation(isPaused ? nil : .linear(duration: 0.18), value: progress)
        .accessibilityLabel("Transition from \(startPose.name) to \(endPose.name)")
    }
}

private extension Pose {
    var hasRasterAsset: Bool {
        !assetName.hasPrefix("figure.")
    }
}

private struct RasterPoseImageView: View {
    let pose: Pose

    var body: some View {
        Image(pose.assetName)
            .resizable()
            .scaledToFit()
            .padding(6)
            .accessibilityHidden(true)
    }
}

private struct RasterPoseTransitionView: View {
    let startPose: Pose
    let endPose: Pose
    let progress: Double
    let startSide: PracticeSide
    let endSide: PracticeSide

    private var t: Double {
        min(max(progress, 0), 1)
    }

    private var easedProgress: Double {
        t * t * (3 - 2 * t)
    }

    var body: some View {
        ZStack {
            RasterPoseImageView(pose: startPose)
                .scaleEffect(x: startSide == .left ? -1 : 1, y: 1)
                .opacity(1 - easedProgress)
                .scaleEffect(1.02 - 0.07 * easedProgress)
                .offset(x: -22 * easedProgress, y: -8 * easedProgress)
                .rotationEffect(.degrees(-2.5 * easedProgress))

            RasterPoseImageView(pose: endPose)
                .scaleEffect(x: endSide == .left ? -1 : 1, y: 1)
                .opacity(easedProgress)
                .scaleEffect(0.95 + 0.07 * easedProgress)
                .offset(x: 22 * (1 - easedProgress), y: 8 * (1 - easedProgress))
                .rotationEffect(.degrees(2.5 * (1 - easedProgress)))

            if t > 0.05 && t < 0.95 {
                Image(systemName: "arrow.right")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(FlowDesign.teal)
                    .padding(10)
                    .background(.thinMaterial)
                    .clipShape(Circle())
                    .opacity(sin(t * .pi) * 0.75)
            }
        }
    }
}

struct PoseFigureConfiguration {
    var torsoRotation: Angle
    var armAngle: Angle
    var hipOffset: CGSize
    var kneeBend: Double
    var verticalOffset: CGFloat
    var bodyScale: CGFloat
    var isHorizontal: Bool
    var foldAmount: Double

    static func configuration(for pose: Pose) -> PoseFigureConfiguration {
        switch pose.id {
        case "tabletop":
            PoseFigureConfiguration(torsoRotation: .degrees(88), armAngle: .degrees(86), hipOffset: CGSize(width: -10, height: 18), kneeBend: 0.45, verticalOffset: 28, bodyScale: 0.98, isHorizontal: true, foldAmount: 0.42)
        case "cow", "sphinx", "bridge":
            PoseFigureConfiguration(torsoRotation: .degrees(24), armAngle: .degrees(96), hipOffset: CGSize(width: 0, height: 28), kneeBend: 0.20, verticalOffset: 24, bodyScale: 1, isHorizontal: true, foldAmount: 0.15)
        case "bird-dog", "three-legged-dog":
            PoseFigureConfiguration(torsoRotation: .degrees(100), armAngle: .degrees(132), hipOffset: CGSize(width: 0, height: 8), kneeBend: 0.04, verticalOffset: 18, bodyScale: 1.02, isHorizontal: true, foldAmount: 0.34)
        case "thread-needle", "child-pose":
            PoseFigureConfiguration(torsoRotation: .degrees(96), armAngle: .degrees(126), hipOffset: CGSize(width: -8, height: 32), kneeBend: 0.55, verticalOffset: 36, bodyScale: 0.96, isHorizontal: true, foldAmount: 0.82)
        case "low-lunge", "warrior-two", "side-angle":
            PoseFigureConfiguration(torsoRotation: .degrees(-18), armAngle: .degrees(-126), hipOffset: CGSize(width: 0, height: 12), kneeBend: 0.72, verticalOffset: 16, bodyScale: 1, isHorizontal: false, foldAmount: 0.15)
        case "triangle", "pyramid", "half-split", "seated-fold":
            PoseFigureConfiguration(torsoRotation: .degrees(68), armAngle: .degrees(82), hipOffset: CGSize(width: 0, height: 16), kneeBend: 0.18, verticalOffset: 20, bodyScale: 0.96, isHorizontal: false, foldAmount: 0.78)
        case "shoulder-stand":
            PoseFigureConfiguration(torsoRotation: .degrees(178), armAngle: .degrees(30), hipOffset: CGSize(width: 0, height: -18), kneeBend: 0.04, verticalOffset: -8, bodyScale: 0.95, isHorizontal: false, foldAmount: 0.3)
        case "knee-to-nose", "boat", "chair":
            PoseFigureConfiguration(torsoRotation: .degrees(32), armAngle: .degrees(-96), hipOffset: CGSize(width: 0, height: 18), kneeBend: 0.65, verticalOffset: 18, bodyScale: 0.98, isHorizontal: false, foldAmount: 0.42)
        case "upward-salute":
            PoseFigureConfiguration(torsoRotation: .degrees(0), armAngle: .degrees(-160), hipOffset: .zero, kneeBend: 0.05, verticalOffset: -8, bodyScale: 1.02, isHorizontal: false, foldAmount: 0)
        case "forward-fold":
            PoseFigureConfiguration(torsoRotation: .degrees(78), armAngle: .degrees(70), hipOffset: CGSize(width: 0, height: 8), kneeBend: 0.28, verticalOffset: 12, bodyScale: 0.96, isHorizontal: false, foldAmount: 1)
        case "halfway-lift":
            PoseFigureConfiguration(torsoRotation: .degrees(58), armAngle: .degrees(45), hipOffset: CGSize(width: 4, height: 4), kneeBend: 0.16, verticalOffset: 5, bodyScale: 0.98, isHorizontal: false, foldAmount: 0.58)
        case "plank":
            PoseFigureConfiguration(torsoRotation: .degrees(88), armAngle: .degrees(84), hipOffset: CGSize(width: 0, height: 28), kneeBend: 0.02, verticalOffset: 34, bodyScale: 1, isHorizontal: true, foldAmount: 0.5)
        case "chaturanga":
            PoseFigureConfiguration(torsoRotation: .degrees(90), armAngle: .degrees(110), hipOffset: CGSize(width: 0, height: 34), kneeBend: 0.04, verticalOffset: 42, bodyScale: 0.98, isHorizontal: true, foldAmount: 0.68)
        case "upward-facing-dog":
            PoseFigureConfiguration(torsoRotation: .degrees(26), armAngle: .degrees(95), hipOffset: CGSize(width: 0, height: 34), kneeBend: 0.02, verticalOffset: 26, bodyScale: 1.02, isHorizontal: true, foldAmount: 0.12)
        case "downward-facing-dog":
            PoseFigureConfiguration(torsoRotation: .degrees(132), armAngle: .degrees(120), hipOffset: CGSize(width: 0, height: -8), kneeBend: 0.12, verticalOffset: 18, bodyScale: 1, isHorizontal: true, foldAmount: 0.9)
        default:
            PoseFigureConfiguration(torsoRotation: .degrees(0), armAngle: .degrees(18), hipOffset: .zero, kneeBend: 0.04, verticalOffset: 0, bodyScale: 1, isHorizontal: false, foldAmount: 0)
        }
    }

    static func interpolate(from start: PoseFigureConfiguration, to end: PoseFigureConfiguration, progress: Double) -> PoseFigureConfiguration {
        let t = min(max(progress, 0), 1)
        return PoseFigureConfiguration(
            torsoRotation: .degrees(lerp(start.torsoRotation.degrees, end.torsoRotation.degrees, t)),
            armAngle: .degrees(lerp(start.armAngle.degrees, end.armAngle.degrees, t)),
            hipOffset: CGSize(width: lerp(start.hipOffset.width, end.hipOffset.width, t), height: lerp(start.hipOffset.height, end.hipOffset.height, t)),
            kneeBend: lerp(start.kneeBend, end.kneeBend, t),
            verticalOffset: lerp(start.verticalOffset, end.verticalOffset, t),
            bodyScale: lerp(start.bodyScale, end.bodyScale, t),
            isHorizontal: t < 0.5 ? start.isHorizontal : end.isHorizontal,
            foldAmount: lerp(start.foldAmount, end.foldAmount, t)
        )
    }

    private static func lerp(_ a: Double, _ b: Double, _ t: Double) -> Double {
        a + (b - a) * t
    }
}

private struct PoseFigureView: View {
    let config: PoseFigureConfiguration
    let progress: Double

    var body: some View {
        GeometryReader { proxy in
            let size = min(proxy.size.width, proxy.size.height)
            let center = CGPoint(x: proxy.size.width / 2, y: proxy.size.height / 2 + config.verticalOffset)
            let unit = size / 100
            ZStack {
                Capsule()
                    .fill(Color.orange.opacity(0.75))
                    .frame(width: 12 * unit, height: 16 * unit)
                    .offset(x: headX(unit), y: headY(unit))

                limb(length: 35 * unit, angle: config.armAngle.degrees - 12, width: 5 * unit, color: FlowDesign.teal)
                    .offset(x: armBaseX(unit) - 8 * unit, y: armBaseY(unit))
                limb(length: 35 * unit, angle: -config.armAngle.degrees + 12, width: 5 * unit, color: FlowDesign.teal)
                    .offset(x: armBaseX(unit) + 8 * unit, y: armBaseY(unit))

                Capsule()
                    .fill(FlowDesign.teal)
                    .frame(width: 20 * unit, height: 40 * unit)
                    .rotationEffect(config.torsoRotation)
                    .offset(x: torsoX(unit), y: torsoY(unit))

                limb(length: 34 * unit, angle: legAngle(sign: -1), width: 6 * unit, color: Color(red: 0.13, green: 0.18, blue: 0.17))
                    .offset(x: legBaseX(unit) - 6 * unit, y: legBaseY(unit))
                limb(length: 34 * unit, angle: legAngle(sign: 1), width: 6 * unit, color: Color(red: 0.13, green: 0.18, blue: 0.17))
                    .offset(x: legBaseX(unit) + 6 * unit, y: legBaseY(unit))

                Circle()
                    .fill(Color(red: 0.12, green: 0.17, blue: 0.16))
                    .frame(width: 18 * unit, height: 18 * unit)
                    .offset(x: config.hipOffset.width, y: config.hipOffset.height + 18 * unit)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .position(center)
            .scaleEffect(config.bodyScale)
        }
    }

    private func limb(length: CGFloat, angle: Double, width: CGFloat, color: Color) -> some View {
        Capsule()
            .fill(color)
            .frame(width: width, height: length)
            .rotationEffect(.degrees(angle), anchor: .top)
    }

    private func headX(_ unit: CGFloat) -> CGFloat {
        config.isHorizontal ? 28 * unit - CGFloat(config.foldAmount) * 18 * unit : CGFloat(sin(config.torsoRotation.radians)) * 17 * unit
    }

    private func headY(_ unit: CGFloat) -> CGFloat {
        config.isHorizontal ? -6 * unit + CGFloat(config.foldAmount) * 8 * unit : -32 * unit + CGFloat(config.foldAmount) * 45 * unit
    }

    private func torsoX(_ unit: CGFloat) -> CGFloat {
        config.isHorizontal ? 0 : CGFloat(sin(config.torsoRotation.radians)) * 11 * unit
    }

    private func torsoY(_ unit: CGFloat) -> CGFloat {
        config.isHorizontal ? 4 * unit : -4 * unit + CGFloat(config.foldAmount) * 19 * unit
    }

    private func armBaseX(_ unit: CGFloat) -> CGFloat {
        config.isHorizontal ? 25 * unit : torsoX(unit)
    }

    private func armBaseY(_ unit: CGFloat) -> CGFloat {
        config.isHorizontal ? 0 : torsoY(unit) - 16 * unit
    }

    private func legBaseX(_ unit: CGFloat) -> CGFloat {
        config.isHorizontal ? -19 * unit : config.hipOffset.width
    }

    private func legBaseY(_ unit: CGFloat) -> CGFloat {
        config.isHorizontal ? 9 * unit : config.hipOffset.height + 24 * unit
    }

    private func legAngle(sign: Double) -> Double {
        if config.isHorizontal {
            return 86 + sign * (8 + config.kneeBend * 18)
        }
        return sign * (9 + config.kneeBend * 28)
    }
}

#Preview("Hold") {
    PoseIllustrationView(pose: SunSalutationData.downwardDog, isBreathing: true)
        .frame(width: 240, height: 240)
        .padding()
}

#Preview("Transition") {
    PoseTransitionView(
        startPose: SunSalutationData.forwardFold,
        endPose: SunSalutationData.halfwayLift,
        progress: 0.55,
        isPaused: false
    )
    .frame(width: 240, height: 240)
    .padding()
}
