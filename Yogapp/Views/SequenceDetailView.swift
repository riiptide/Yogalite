import SwiftUI
import SwiftData

struct SequenceDetailView: View {
    let sequence: YogaSequence
    var endWorkoutAction: () -> Void = {}
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var savedPracticeRecords: [SavedPracticeRecord]
    @State private var selectedTab: DetailTab = .sequence

    private var isFavorite: Bool {
        savedPracticeRecords.contains { $0.sequenceID == sequence.id }
    }

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
                    toggleFavorite()
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

            VStack(alignment: .leading, spacing: 12) {
                Text(sequence.title)
                    .font(.system(.largeTitle, design: .serif, weight: .bold))
                    .foregroundStyle(FlowDesign.text)
                    .fixedSize(horizontal: false, vertical: true)
                Text(sequence.subtitle)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                metadataSummary
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
            .lineLimit(1)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(FlowDesign.paleAqua)
            .foregroundStyle(FlowDesign.teal)
            .clipShape(Capsule())
            .fixedSize(horizontal: true, vertical: false)
            .accessibilityLabel("Difficulty: \(sequence.difficulty)")
    }

    private var metadataSummary: some View {
        VStack(alignment: .leading, spacing: 10) {
            tagSummary

            HStack(spacing: 12) {
                roundMetadata
                durationMetadata
            }
        }
    }

    private var tagSummary: some View {
        FlowLayout(spacing: 8) {
            difficultyBadge
            ForEach(visibleTags, id: \.self) { tag in
                SequenceTagBadge(tag: tag)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .contain)
    }

    private var visibleTags: [String] {
        var seenTags = Set<String>()
        return sequence.tags.filter { tag in
            let tagKey = normalizedTag(tag)
            guard tagKey != normalizedTag(sequence.difficulty),
                  !seenTags.contains(tagKey) else {
                return false
            }
            seenTags.insert(tagKey)
            return true
        }
    }

    private var roundMetadata: some View {
        MetadataLabel(title: "\(sequence.rounds) rounds", systemImage: "arrow.triangle.2.circlepath")
    }

    private var durationMetadata: some View {
        MetadataLabel(title: sequence.estimatedDuration.minutesText, systemImage: "clock")
    }

    private var difficultyIcon: String {
        switch sequence.difficulty.lowercased() {
        case "gentle": "leaf"
        case "intermediate": "flame"
        default: "chart.bar"
        }
    }

    private func normalizedTag(_ tag: String) -> String {
        tag.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
            .replacingOccurrences(of: "\u{2013}", with: "-")
            .replacingOccurrences(of: "\u{2014}", with: "-")
            .lowercased()
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

    private func toggleFavorite() {
        if let savedRecord = savedPracticeRecords.first(where: { $0.sequenceID == sequence.id }) {
            modelContext.delete(savedRecord)
        } else {
            modelContext.insert(SavedPracticeRecord(sequenceID: sequence.id))
        }
        try? modelContext.save()
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
