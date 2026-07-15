import SwiftUI
import SwiftData

struct LibraryView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("didSeedSavedPractices") private var didSeedSavedPractices = false
    @Query(sort: \SavedPracticeRecord.savedAt, order: .reverse) private var savedPracticeRecords: [SavedPracticeRecord]
    @State private var path: [LibraryRoute] = []

    private var savedPractices: [SavedPractice] {
        savedPracticeRecords.compactMap { record in
            guard let sequence = PracticePersistence.sequence(for: record.sequenceID) else { return nil }
            return SavedPractice(id: record.sequenceID, sequence: sequence, savedAt: record.savedAt)
        }
    }

    private var totalMinutes: Int {
        savedPractices.reduce(0) { $0 + $1.sequence.estimatedMinutes }
    }

    private var savedCountText: String {
        "\(savedPractices.count) saved"
    }

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                FlowDesign.background.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        header
                        summary
                        savedPracticeList
                    }
                    .padding(FlowDesign.spacing)
                }
            }
            .navigationTitle("Library")
            .task {
                PracticePersistence.seedSavedPracticesIfNeeded(modelContext: modelContext, didSeed: &didSeedSavedPractices)
            }
            .navigationDestination(for: LibraryRoute.self) { route in
                switch route {
                case .sequence(let id):
                    let sequence = savedPractices.first { $0.sequence.id == id }?.sequence ?? SunSalutationData.sunSalutationA
                    SequenceDetailView(sequence: sequence, endWorkoutAction: returnToLibraryRoot)
                }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Saved practices")
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(FlowDesign.text)
            Text("Your go-to flows, ready when you want to return to them.")
                .font(.body)
                .foregroundStyle(.secondary)
        }
    }

    private var summary: some View {
        HStack(spacing: 12) {
            LibraryStatCard(title: "Practices", value: savedCountText, systemImage: "bookmark.fill")
            LibraryStatCard(title: "Time", value: "\(totalMinutes) min", systemImage: "clock.fill")
        }
    }

    @ViewBuilder
    private var savedPracticeList: some View {
        if savedPractices.isEmpty {
            ContentUnavailableView(
                "No saved practices yet",
                systemImage: "bookmark",
                description: Text("Favorite a sequence to keep it here for later.")
            )
            .frame(maxWidth: .infinity)
            .padding(.top, 36)
        } else {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text("Saved")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(FlowDesign.text)
                    Spacer()
                    Text(savedCountText)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                }

                ForEach(savedPractices) { savedPractice in
                    NavigationLink(value: LibraryRoute.sequence(savedPractice.sequence.id)) {
                        SavedPracticeCard(savedPractice: savedPractice)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func returnToLibraryRoot() {
        path.removeAll()
    }
}

private enum LibraryRoute: Hashable {
    case sequence(String)
}

private struct SavedPractice: Identifiable {
    let id: String
    let sequence: YogaSequence
    let savedAt: Date

    var savedLabel: String {
        if Calendar.current.isDateInToday(savedAt) {
            "Saved today"
        } else {
            "Saved \(savedAt.formatted(date: .abbreviated, time: .omitted))"
        }
    }
}

private struct LibraryStatCard: View {
    let title: String
    let value: String
    let systemImage: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: systemImage)
                .font(.headline.weight(.bold))
                .foregroundStyle(FlowDesign.teal)
                .frame(width: 34, height: 34)
                .background(FlowDesign.paleAqua)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 3) {
                Text(value)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(FlowDesign.text)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(.systemBackground).opacity(0.90))
        .clipShape(RoundedRectangle(cornerRadius: FlowDesign.cornerMedium, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title), \(value)")
    }
}

private struct SavedPracticeCard: View {
    let savedPractice: SavedPractice

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 14) {
                PoseIllustrationView(pose: savedPractice.sequence.steps.first?.startPose ?? SunSalutationData.mountain)
                    .frame(width: 74, height: 74)
                    .background(FlowDesign.paleAqua.opacity(0.70))
                    .clipShape(RoundedRectangle(cornerRadius: FlowDesign.cornerMedium, style: .continuous))

                VStack(alignment: .leading, spacing: 7) {
                    Text(savedPractice.sequence.title)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(FlowDesign.text)
                        .lineLimit(2)
                    Text(savedPractice.savedLabel)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: "chevron.right")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(FlowDesign.teal)
            }

            HStack(spacing: 10) {
                MetadataLabel(title: savedPractice.sequence.difficulty, systemImage: "chart.bar")
                MetadataLabel(title: savedPractice.sequence.estimatedDuration.minutesText, systemImage: "clock")
                MetadataLabel(title: savedPractice.sequence.rounds.roundsText, systemImage: "arrow.triangle.2.circlepath")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: FlowDesign.cornerLarge, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 16, x: 0, y: 8)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(savedPractice.sequence.title), \(savedPractice.sequence.difficulty), about \(savedPractice.sequence.estimatedDuration.minutesText), \(savedPractice.savedLabel)")
    }
}

#Preview("Library") {
    LibraryView()
}

#Preview("Library Dark") {
    LibraryView()
        .preferredColorScheme(.dark)
}
