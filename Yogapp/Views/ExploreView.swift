import SwiftUI

struct ExploreView: View {
    private let sequences = SunSalutationData.allSequences
    @State private var path: [ExploreRoute] = []
    @State private var searchText = ""
    @State private var selectedDifficulty: String = "All"
    @State private var selectedTimeRange: TimeRange = .any
    @State private var selectedTag: ExploreTag?

    private let featuredTags: [ExploreTag] = [
        ExploreTag(title: "Morning", type: .timeOfDay, systemImage: "sun.max"),
        ExploreTag(title: "Calming", type: .mood, systemImage: "leaf"),
        ExploreTag(title: "Strength", type: .focus, systemImage: "flame"),
        ExploreTag(title: "Hips", type: .bodyArea, systemImage: "figure.flexibility"),
        ExploreTag(title: "Core", type: .bodyArea, systemImage: "figure.core.training"),
        ExploreTag(title: "Balance", type: .skill, systemImage: "figure.yoga"),
        ExploreTag(title: "Quick", type: .duration, systemImage: "timer"),
        ExploreTag(title: "Beginner", type: .level, systemImage: "sparkles"),
        ExploreTag(title: "Stress Relief", type: .mood, systemImage: "heart"),
        ExploreTag(title: "Floor Practice", type: .format, systemImage: "square.grid.2x2")
    ]

    private var difficulties: [String] {
        ["All"] + Array(Set(sequences.map(\.difficulty))).sorted()
    }

    private var filteredSequences: [YogaSequence] {
        sequences.filter { sequence in
            let normalizedSearch = normalized(searchText.trimmingCharacters(in: .whitespacesAndNewlines))
            let matchesSearch = normalizedSearch.isEmpty
                || normalized(sequence.title).contains(normalizedSearch)
                || normalized(sequence.subtitle).contains(normalizedSearch)
                || normalized(sequence.difficulty).contains(normalizedSearch)
                || normalized(sequence.estimatedDuration.minutesText).contains(normalizedSearch)
                || sequence.tags.contains { normalized($0).contains(normalizedSearch) }

            let matchesDifficulty = selectedDifficulty == "All" || sequence.difficulty == selectedDifficulty
            let matchesTime = selectedTimeRange.contains(sequence.estimatedMinutes)
            let matchesTag = selectedTag.map { tag in
                sequence.tags.contains { normalized($0) == normalized(tag.title) }
            } ?? true

            return matchesSearch && matchesDifficulty && matchesTime && matchesTag
        }
    }

    private var isFiltering: Bool {
        selectedDifficulty != "All" || selectedTimeRange != .any || !searchText.isEmpty || selectedTag != nil
    }

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                FlowDesign.background.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        header
                        tagShelf
                        filters
                        results
                    }
                    .padding(FlowDesign.spacing)
                }
            }
            .navigationTitle("Explore")
            .searchable(text: $searchText, prompt: "Search title, tag, body area, or time")
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
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Explore flows")
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(FlowDesign.text)
                Text("Search the full library, tap a tag, or narrow by level and time.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            HStack(spacing: 12) {
                ExploreMetricCard(value: "\(sequences.count)", title: "flows", systemImage: "rectangle.stack")
                ExploreMetricCard(value: "\(difficulties.count - 1)", title: "levels", systemImage: "chart.bar")
                ExploreMetricCard(value: "\(featuredTags.count)", title: "tags", systemImage: "tag")
            }
        }
    }

    private var tagShelf: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label("Browse by tag", systemImage: "tag")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(FlowDesign.text)

                Spacer()

                if let selectedTag {
                    Button("Clear tag") {
                        self.selectedTag = nil
                    }
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(FlowDesign.teal)
                    .accessibilityLabel("Clear \(selectedTag.title) tag")
                }
            }

            FlowLayout(spacing: 9) {
                ForEach(featuredTags) { tag in
                    ExploreTagButton(
                        tag: tag,
                        count: count(for: tag),
                        isSelected: selectedTag == tag
                    ) {
                        selectedTag = selectedTag == tag ? nil : tag
                    }
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground).opacity(0.88))
        .clipShape(RoundedRectangle(cornerRadius: FlowDesign.cornerLarge, style: .continuous))
    }

    private var filters: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label("Refine", systemImage: "slider.horizontal.3")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(FlowDesign.text)

                Spacer()

                if isFiltering {
                    Button("Reset") {
                        clearFilters()
                    }
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(FlowDesign.teal)
                }
            }

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
            }

            activeFilterSummary
        }
        .padding(16)
        .background(Color(.systemBackground).opacity(0.88))
        .clipShape(RoundedRectangle(cornerRadius: FlowDesign.cornerMedium, style: .continuous))
    }

    @ViewBuilder
    private var activeFilterSummary: some View {
        if isFiltering {
            FlowLayout(spacing: 8) {
                if !searchText.isEmpty {
                    ActiveFilterChip(title: "Search: \(searchText)", systemImage: "magnifyingglass")
                }
                if let selectedTag {
                    ActiveFilterChip(title: selectedTag.title, systemImage: selectedTag.systemImage)
                }
                if selectedDifficulty != "All" {
                    ActiveFilterChip(title: selectedDifficulty, systemImage: "chart.bar")
                }
                if selectedTimeRange != .any {
                    ActiveFilterChip(title: selectedTimeRange.title, systemImage: "clock")
                }
            }
        }
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
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(resultsTitle)
                            .font(.title3.weight(.bold))
                            .foregroundStyle(FlowDesign.text)
                        Text(resultsSubtitle)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Text("\(filteredSequences.count)")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(FlowDesign.teal)
                }

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

    private var resultsTitle: String {
        if let selectedTag {
            return "\(selectedTag.title) flows"
        }
        return isFiltering ? "Matching flows" : "All flows"
    }

    private var resultsSubtitle: String {
        let noun = filteredSequences.count == 1 ? "practice" : "practices"
        return "\(filteredSequences.count) \(noun) ready to start"
    }

    private func count(for tag: ExploreTag) -> Int {
        sequences.filter { sequence in
            sequence.tags.contains { normalized($0) == normalized(tag.title) }
        }.count
    }

    private func clearFilters() {
        searchText = ""
        selectedDifficulty = "All"
        selectedTimeRange = .any
        selectedTag = nil
    }

    private func normalized(_ value: String) -> String {
        value.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
            .replacingOccurrences(of: "\u{2013}", with: "-")
            .replacingOccurrences(of: "\u{2014}", with: "-")
            .lowercased()
    }
}

private enum ExploreRoute: Hashable {
    case sequence(String)
}

private struct ExploreTag: Identifiable, Hashable {
    let title: String
    let type: ExploreTagType
    let systemImage: String

    var id: String { title }
}

private enum ExploreTagType {
    case timeOfDay
    case mood
    case focus
    case bodyArea
    case skill
    case duration
    case level
    case format

    var foreground: Color {
        switch self {
        case .timeOfDay: Color(red: 0.64, green: 0.38, blue: 0.03)
        case .mood: Color(red: 0.39, green: 0.29, blue: 0.64)
        case .focus: Color(red: 0.62, green: 0.20, blue: 0.16)
        case .bodyArea: Color(red: 0.16, green: 0.42, blue: 0.46)
        case .skill: Color(red: 0.12, green: 0.38, blue: 0.28)
        case .duration: Color(red: 0.18, green: 0.36, blue: 0.66)
        case .level: FlowDesign.teal
        case .format: Color(red: 0.34, green: 0.34, blue: 0.40)
        }
    }

    var background: Color {
        switch self {
        case .timeOfDay: Color(red: 1.00, green: 0.92, blue: 0.74)
        case .mood: Color(red: 0.92, green: 0.88, blue: 0.98)
        case .focus: Color(red: 0.98, green: 0.87, blue: 0.84)
        case .bodyArea: Color(red: 0.84, green: 0.94, blue: 0.95)
        case .skill: Color(red: 0.84, green: 0.94, blue: 0.89)
        case .duration: Color(red: 0.84, green: 0.90, blue: 0.99)
        case .level: FlowDesign.paleAqua
        case .format: Color(.secondarySystemBackground)
        }
    }
}

private struct ExploreTagButton: View {
    let tag: ExploreTag
    let count: Int
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: tag.systemImage)
                    .font(.caption.weight(.bold))
                    .frame(width: 18, height: 18)
                Text(tag.title)
                    .font(.subheadline.weight(.bold))
                    .lineLimit(1)
                Text("\(count)")
                    .font(.caption.weight(.heavy))
                    .padding(.horizontal, 7)
                    .padding(.vertical, 4)
                    .background(isSelected ? Color.white.opacity(0.24) : Color(.systemBackground).opacity(0.62))
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(isSelected ? tag.type.foreground : tag.type.background)
            .foregroundStyle(isSelected ? .white : tag.type.foreground)
            .clipShape(Capsule())
            .overlay {
                Capsule()
                    .stroke(isSelected ? Color.clear : tag.type.foreground.opacity(0.14), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(tag.title), \(count) flows")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

private struct ExploreMetricCard: View {
    let value: String
    let title: String
    let systemImage: String

    var body: some View {
        HStack(spacing: 9) {
            Image(systemName: systemImage)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(FlowDesign.teal)
                .frame(width: 30, height: 30)
                .background(FlowDesign.paleAqua)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 1) {
                Text(value)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(FlowDesign.text)
                    .lineLimit(1)
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color(.systemBackground).opacity(0.88))
        .clipShape(RoundedRectangle(cornerRadius: FlowDesign.cornerMedium, style: .continuous))
        .accessibilityElement(children: .combine)
    }
}

private struct ActiveFilterChip: View {
    let title: String
    let systemImage: String

    var body: some View {
        Label(title, systemImage: systemImage)
            .font(.caption.weight(.bold))
            .lineLimit(1)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(FlowDesign.paleAqua.opacity(0.74))
            .foregroundStyle(FlowDesign.teal)
            .clipShape(Capsule())
    }
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
