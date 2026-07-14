import SwiftUI

struct SequenceDetailView: View {
    let sequence: YogaSequence
    var endWorkoutAction: () -> Void = {}
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab: DetailTab = .sequence
    @State private var isFavorite = false

    var body: some View {
        ZStack(alignment: .bottom) {
            FlowDesign.background.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    header
                    tabs
                    tabContent
                    roundFooter
                        .padding(.bottom, 96)
                }
                .padding(.horizontal, FlowDesign.spacing)
                .padding(.top, 12)
            }

            NavigationLink {
                PracticePlayerView(
                    viewModel: PracticePlayerViewModel(sequence: sequence),
                    endWorkoutAction: endWorkoutAction
                )
            } label: {
                Label("Start Practice", systemImage: "play.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(FlowDesign.teal)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: FlowDesign.cornerLarge, style: .continuous))
            }
            .padding(.horizontal, FlowDesign.spacing)
            .padding(.bottom, 10)
        }
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .navigationBar)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.headline.weight(.bold))
                        .frame(width: 44, height: 44)
                        .background(Color(.systemBackground).opacity(0.85))
                        .clipShape(Circle())
                }
                .accessibilityLabel("Back")

                Spacer()

                Button {
                    isFavorite.toggle()
                } label: {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(isFavorite ? FlowDesign.teal : .secondary)
                        .frame(width: 44, height: 44)
                        .background(Color(.systemBackground).opacity(0.85))
                        .clipShape(Circle())
                }
                .accessibilityLabel(isFavorite ? "Remove favorite" : "Favorite")
            }

            HStack(alignment: .center, spacing: 18) {
                VStack(alignment: .leading, spacing: 12) {
                    Text(sequence.title)
                        .font(.system(.largeTitle, design: .serif, weight: .bold))
                        .foregroundStyle(FlowDesign.text)
                        .lineLimit(2)
                    Text(sequence.subtitle)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                    HStack(spacing: 12) {
                        difficultyBadge
                        MetadataLabel(title: "\(sequence.rounds) rounds", systemImage: "arrow.triangle.2.circlepath")
                        MetadataLabel(title: sequence.estimatedDuration.minutesText, systemImage: "clock")
                    }
                }

                PoseTransitionView(
                    startPose: SunSalutationData.mountain,
                    endPose: SunSalutationData.upwardSalute,
                    progress: 0.78,
                    isPaused: true
                )
                .frame(width: 118, height: 118)
                .background(FlowDesign.paleAqua)
                .clipShape(Circle())
            }
        }
    }

    private var tabs: some View {
        Picker("Section", selection: $selectedTab) {
            ForEach(DetailTab.allCases) { tab in
                Text(tab.title).tag(tab)
            }
        }
        .pickerStyle(.segmented)
        .accessibilityLabel("Detail sections")
    }

    @ViewBuilder
    private var tabContent: some View {
        switch selectedTab {
        case .overview:
            VStack(spacing: 14) {
                infoPanel(sequence.onboardingNote)
                safetyPanel
            }
        case .sequence:
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Sequence Breakdown")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(sequence.rounds) rounds")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(FlowDesign.teal)
                }
                ForEach(Array(sequence.steps.enumerated()), id: \.element.id) { index, step in
                    StepRow(number: index + 1, step: step)
                }
            }
        case .benefits:
            infoPanel("Builds breath awareness, mobility, and control through timed holds and smooth transitions. Use the side cues to keep balanced shapes clear.")
        }
    }

    private var difficultyBadge: some View {
        Label(sequence.difficulty, systemImage: difficultyIcon)
            .font(.caption.weight(.bold))
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(FlowDesign.paleAqua)
            .foregroundStyle(FlowDesign.teal)
            .clipShape(Capsule())
            .accessibilityLabel("Difficulty: \(sequence.difficulty)")
    }

    private var difficultyIcon: String {
        switch sequence.difficulty.lowercased() {
        case "gentle": "leaf"
        case "intermediate": "flame"
        default: "chart.bar"
        }
    }

    private var safetyPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Safety Notes", systemImage: "heart.text.square")
                .font(.headline.weight(.bold))
                .foregroundStyle(FlowDesign.text)
            ForEach(sequence.safetyNotes, id: \.self) { note in
                Label(note, systemImage: "checkmark.circle.fill")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: FlowDesign.cornerMedium, style: .continuous))
    }

    private var roundFooter: some View {
        HStack(spacing: 14) {
            Image(systemName: "arrow.triangle.2.circlepath")
                .font(.title3.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 48, height: 48)
                .background(FlowDesign.teal)
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 4) {
                Text("This completes one round")
                    .font(.headline)
                Text("Repeat \(sequence.rounds) rounds")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(16)
        .background(Color(.systemBackground).opacity(0.86))
        .clipShape(RoundedRectangle(cornerRadius: FlowDesign.cornerLarge, style: .continuous))
    }

    private func infoPanel(_ text: String) -> some View {
        Text(text)
            .font(.body)
            .foregroundStyle(.secondary)
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: FlowDesign.cornerMedium, style: .continuous))
    }
}

private enum DetailTab: String, CaseIterable, Identifiable {
    case overview
    case sequence
    case benefits

    var id: String { rawValue }
    var title: String {
        switch self {
        case .overview: "Overview"
        case .sequence: "Sequence"
        case .benefits: "Benefits"
        }
    }
}

#Preview("Sequence Detail") {
    NavigationStack {
        SequenceDetailView(sequence: SunSalutationData.sunSalutationA)
    }
}
