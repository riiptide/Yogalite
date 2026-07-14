import SwiftUI

struct ExploreView: View {
    private let sequences = SunSalutationData.allSequences
    @State private var path: [ExploreRoute] = []
    @State private var searchText = ""
    @State private var selectedDifficulty: String = "All"
    @State private var selectedTimeRange: TimeRange = .any

    private var difficulties: [String] {
        ["All"] + Array(Set(sequences.map(\.difficulty))).sorted()
    }

    private var filteredSequences: [YogaSequence] {
        sequences.filter { sequence in
            let normalizedSearch = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            let matchesSearch = normalizedSearch.isEmpty
                || sequence.title.lowercased().contains(normalizedSearch)
                || sequence.difficulty.lowercased().contains(normalizedSearch)
                || sequence.estimatedDuration.minutesText.lowercased().contains(normalizedSearch)

            let matchesDifficulty = selectedDifficulty == "All" || sequence.difficulty == selectedDifficulty
            let matchesTime = selectedTimeRange.contains(sequence.estimatedMinutes)

            return matchesSearch && matchesDifficulty && matchesTime
        }
    }

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                FlowDesign.background.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        header
                        filters
                        results
                    }
                    .padding(FlowDesign.spacing)
                }
            }
            .navigationTitle("Explore")
            .searchable(text: $searchText, prompt: "Search title, difficulty, or time")
            .navigationDestination(for: ExploreRoute.self) { route in
                switch route {
                case .sequence(let id):
                    let sequence = sequences.first { $0.id == id } ?? SunSalutationData.sunSalutationA
                    SequenceDetailView(sequence: sequence, endWorkoutAction: returnToExploreRoot)
                }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Find your flow")
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(FlowDesign.text)
            Text("Search by routine name, choose a difficulty, or narrow by practice time.")
                .font(.body)
                .foregroundStyle(.secondary)
        }
    }

    private var filters: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Filters")
                .font(.headline.weight(.bold))
                .foregroundStyle(FlowDesign.text)

            HStack(spacing: 10) {
                Picker("Difficulty", selection: $selectedDifficulty) {
                    ForEach(difficulties, id: \.self) { difficulty in
                        Text(difficulty).tag(difficulty)
                    }
                }
                .pickerStyle(.menu)
                .buttonStyle(.bordered)
                .accessibilityLabel("Difficulty filter")

                Picker("Time", selection: $selectedTimeRange) {
                    ForEach(TimeRange.allCases) { range in
                        Text(range.title).tag(range)
                    }
                }
                .pickerStyle(.menu)
                .buttonStyle(.bordered)
                .accessibilityLabel("Time filter")

                if selectedDifficulty != "All" || selectedTimeRange != .any || !searchText.isEmpty {
                    Button("Clear") {
                        searchText = ""
                        selectedDifficulty = "All"
                        selectedTimeRange = .any
                    }
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(FlowDesign.teal)
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground).opacity(0.86))
        .clipShape(RoundedRectangle(cornerRadius: FlowDesign.cornerMedium, style: .continuous))
    }

    @ViewBuilder
    private var results: some View {
        if filteredSequences.isEmpty {
            ContentUnavailableView(
                "No workouts found",
                systemImage: "magnifyingglass",
                description: Text("Try a different title, difficulty, or time range.")
            )
            .frame(maxWidth: .infinity)
            .padding(.top, 32)
        } else {
            VStack(alignment: .leading, spacing: 14) {
                Text("\(filteredSequences.count) workout\(filteredSequences.count == 1 ? "" : "s")")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.secondary)

                ForEach(filteredSequences) { sequence in
                    NavigationLink(value: ExploreRoute.sequence(sequence.id)) {
                        SequenceCard(sequence: sequence)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func returnToExploreRoot() {
        path.removeAll()
    }
}

private enum ExploreRoute: Hashable {
    case sequence(String)
}

private enum TimeRange: String, CaseIterable, Identifiable {
    case any
    case short
    case medium
    case long

    var id: String { rawValue }

    var title: String {
        switch self {
        case .any: "Any time"
        case .short: "5 min or less"
        case .medium: "6-10 min"
        case .long: "11+ min"
        }
    }

    func contains(_ minutes: Int) -> Bool {
        switch self {
        case .any: true
        case .short: minutes <= 5
        case .medium: (6...10).contains(minutes)
        case .long: minutes >= 11
        }
    }
}

#Preview("Explore") {
    ExploreView()
}
