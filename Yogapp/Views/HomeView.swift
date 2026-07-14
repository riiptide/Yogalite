import SwiftUI

struct HomeView: View {
    private let sequences = SunSalutationData.allSequences
    @State private var path: [HomeRoute] = []
    @State private var selectedDailySequenceID = SunSalutationData.sunSalutationB.id

    private var selectedDailySequence: YogaSequence {
        sequences.first { $0.id == selectedDailySequenceID } ?? SunSalutationData.sunSalutationB
    }

    private var totalPoseCount: Int {
        Set(sequences.flatMap { sequence in
            sequence.steps.flatMap { step in
                [step.startPose.id, step.endPose?.id].compactMap { $0 }
            }
        }).count
    }

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                FlowDesign.background.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        morningHeader
                        todayFlowCard
                        dailyStats
                        allFlowsSection
                    }
                    .padding(FlowDesign.spacing)
                }
            }
            .navigationTitle("Flow")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: HomeRoute.self) { route in
                switch route {
                case .sequence(let id):
                    let sequence = sequences.first { $0.id == id } ?? SunSalutationData.sunSalutationA
                    SequenceDetailView(sequence: sequence, endWorkoutAction: returnHome)
                }
            }
        }
    }

    private var morningHeader: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Text("Good morning")
                        .font(.largeTitle.weight(.bold))
                        .foregroundStyle(FlowDesign.text)
                        .lineLimit(1)
                        .minimumScaleFactor(0.82)
                    Image(systemName: "sun.max.fill")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(FlowDesign.teal)
                        .accessibilityHidden(true)
                }

                Text("Ready to move today?")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
            } label: {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "bell")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(FlowDesign.teal)
                        .frame(width: 48, height: 48)
                        .background(Color(.systemBackground).opacity(0.88))
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 6)

                    Circle()
                        .fill(FlowDesign.teal)
                        .frame(width: 9, height: 9)
                        .offset(x: -8, y: 8)
                }
            }
            .accessibilityLabel("Notifications")
        }
    }

    private var todayFlowCard: some View {
        NavigationLink(value: HomeRoute.sequence(selectedDailySequence.id)) {
            HStack(alignment: .center, spacing: 14) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Today's Flow")
                        .font(.caption.weight(.heavy))
                        .textCase(.uppercase)
                        .foregroundStyle(FlowDesign.teal)

                    Text(selectedDailySequence.title)
                        .font(.system(.largeTitle, design: .rounded, weight: .bold))
                        .foregroundStyle(FlowDesign.text)
                        .lineLimit(3)
                        .minimumScaleFactor(0.78)

                    Text(selectedDailySequence.subtitle)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .lineLimit(3)

                    Label("Start Practice", systemImage: "play.fill")
                        .font(.headline.weight(.bold))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(FlowDesign.teal)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                PoseIllustrationView(pose: heroPose(for: selectedDailySequence))
                    .frame(width: 138, height: 184)
                    .background(
                        Circle()
                            .fill(FlowDesign.paleAqua.opacity(0.76))
                            .frame(width: 138, height: 138)
                    )
                    .accessibilityHidden(true)
            }
            .padding(20)
            .background(
                LinearGradient(
                    colors: [
                        Color(.systemBackground),
                        FlowDesign.paleAqua.opacity(0.48)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: FlowDesign.cornerLarge, style: .continuous))
            .shadow(color: FlowDesign.teal.opacity(0.12), radius: 22, x: 0, y: 12)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Today's flow, \(selectedDailySequence.title), start practice")
        }
        .buttonStyle(.plain)
    }

    private var dailyStats: some View {
        HStack(spacing: 12) {
            HomeMetricCard(value: "\(sequences.count)", title: "flows", systemImage: "rectangle.stack")
            HomeMetricCard(value: "\(totalPoseCount)", title: "poses", systemImage: "figure.yoga")
            HomeMetricCard(value: selectedDailySequence.estimatedDuration.minutesText.replacingOccurrences(of: " min", with: ""), title: "min", systemImage: "clock")
        }
    }

    private var allFlowsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("All flows")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(FlowDesign.text)
                Spacer()
                Text("\(sequences.count) routines")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: 16) {
                            ForEach(sequences) { sequence in
                                NavigationLink(value: HomeRoute.sequence(sequence.id)) {
                                    SequenceCard(sequence: sequence)
                                }
                                .buttonStyle(.plain)
                            }
            }
        }
    }

    private func heroPose(for sequence: YogaSequence) -> Pose {
        switch sequence.id {
        case SunSalutationData.sunSalutationB.id:
            SunSalutationData.warriorOne
        case SunSalutationData.sunSalutationA.id:
            SunSalutationData.upwardSalute
        default:
            sequence.steps.first?.startPose ?? SunSalutationData.mountain
        }
    }

    private func returnHome() {
        path.removeAll()
    }
}

private enum HomeRoute: Hashable {
    case sequence(String)
}

private struct HomeMetricCard: View {
    let value: String
    let title: String
    let systemImage: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: systemImage)
                .font(.headline.weight(.semibold))
                .foregroundStyle(FlowDesign.teal)
                .frame(width: 38, height: 38)
                .background(FlowDesign.paleAqua)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 1) {
                Text(value)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(FlowDesign.text)
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground).opacity(0.90))
        .clipShape(RoundedRectangle(cornerRadius: FlowDesign.cornerMedium, style: .continuous))
        .shadow(color: .black.opacity(0.04), radius: 12, x: 0, y: 6)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(value) \(title)")
    }
}

#Preview("Home") {
    HomeView()
}

#Preview("Home Dark") {
    HomeView()
        .preferredColorScheme(.dark)
}
