import SwiftUI

struct ExploreView: View {
    private let sequences = SunSalutationData.allSequences
    @State private var path: [ExploreRoute] = []
    @State private var searchText = ""
    @State private var selectedDifficulty: String = "All"
    @State private var selectedTimeRange: TimeRange = .any
    @State private var selectedTag: ExploreTag?
    @FocusState private var isSearchFocused: Bool

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
        ["All"] + Array(Set(sequences.map(\.difficulty).filter { normalized($0) != "gentle" })).sorted()
    }

    private var timeRangeSummaries: [TimeRangeSummary] {
        TimeRange.filterRanges.map { range in
            TimeRangeSummary(
                range: range,
                count: sequences.filter { range.contains($0.estimatedMinutes) }.count,
                total: sequences.count
            )
        }
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
                    VStack(alignment: .leading, spacing: 20) {
                        searchField
                        tagShelf
                        filters
                        results
                    }
                    .padding(FlowDesign.spacing)
                }
            }
            .navigationTitle("Explore flows")
            .navigationDestination(for: ExploreRoute.self) { route in
                switch route {
                case .sequence(let id):
                    let sequence = sequences.first { $0.id == id } ?? SunSalutationData.sunSalutationA
                    SequenceDetailView(sequence: sequence, endWorkoutAction: returnToExploreRoot)
                }
            }
        }
    }

    private var searchField: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.title3.weight(.semibold))
                .foregroundStyle(.secondary)

            TextField("Search title, tag, body area, or time", text: $searchText)
                .font(.body)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .focused($isSearchFocused)

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                    isSearchFocused = false
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.headline)
                        .foregroundStyle(.secondary.opacity(0.7))
                }
                .accessibilityLabel("Clear search")
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
        .background(Color(.systemBackground).opacity(0.96))
        .clipShape(Capsule())
    }

    private var tagShelf: some View {
        VStack(alignment: .leading, spacing: 9) {
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

            FlowLayout(spacing: 6) {
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
        .padding(12)
        .background(Color(.systemBackground).opacity(0.88))
        .clipShape(RoundedRectangle(cornerRadius: FlowDesign.cornerMedium, style: .continuous))
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
            }

            timeDistribution
            activeFilterSummary
        }
        .padding(16)
        .background(Color(.systemBackground).opacity(0.88))
        .clipShape(RoundedRectangle(cornerRadius: FlowDesign.cornerMedium, style: .continuous))
    }

    private var timeDistribution: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Timing")
                    .font(.caption.weight(.heavy))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)

                Spacer()

                Button(selectedTimeRange == .any ? "Any time" : "Clear time") {
                    selectedTimeRange = .any
                }
                .font(.caption.weight(.bold))
                .foregroundStyle(FlowDesign.teal)
                .disabled(selectedTimeRange == .any)
                .opacity(selectedTimeRange == .any ? 0.58 : 1)
            }

            VStack(spacing: 8) {
                ForEach(timeRangeSummaries) { summary in
                    TimeRangeDistributionButton(
                        summary: summary,
                        isSelected: selectedTimeRange == summary.range
                    ) {
                        selectedTimeRange = selectedTimeRange == summary.range ? .any : summary.range
                    }
                }
            }
        }
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
            HStack(spacing: 5) {
                Image(systemName: tag.systemImage)
                    .font(.system(size: 10, weight: .bold))
                    .frame(width: 11, height: 11)
                Text(tag.title)
                    .font(.caption2.weight(.bold))
                    .lineLimit(1)
                Text("\(count)")
                    .font(.system(size: 10, weight: .heavy))
                    .padding(.horizontal, 5)
                    .padding(.vertical, 2)
                    .background(isSelected ? Color.white.opacity(0.24) : Color(.systemBackground).opacity(0.62))
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
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

private struct TimeRangeSummary: Identifiable {
    let range: TimeRange
    let count: Int
    let total: Int

    var id: TimeRange { range }

    var fraction: CGFloat {
        guard total > 0 else { return 0 }
        return CGFloat(count) / CGFloat(total)
    }
}

private struct TimeRangeDistributionButton: View {
    let summary: TimeRangeSummary
    let isSelected: Bool
    let action: () -> Void

    private var fillFraction: CGFloat {
        summary.count > 0 ? max(summary.fraction, 0.04) : 0
    }

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 7) {
                HStack(spacing: 8) {
                    Text(summary.range.title)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(isSelected ? FlowDesign.teal : FlowDesign.text)
                        .lineLimit(1)

                    Spacer()

                    Text("\(summary.count)")
                        .font(.caption.weight(.heavy))
                        .foregroundStyle(isSelected ? FlowDesign.teal : .secondary)
                }

                GeometryReader { proxy in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color(.secondarySystemBackground))
                        Capsule()
                            .fill(isSelected ? FlowDesign.teal : FlowDesign.teal.opacity(0.32))
                            .frame(width: proxy.size.width * fillFraction)
                    }
                }
                .frame(height: 5)
            }
            .padding(10)
            .background(isSelected ? FlowDesign.paleAqua.opacity(0.88) : Color(.secondarySystemBackground).opacity(0.36))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(isSelected ? FlowDesign.teal.opacity(0.24) : Color.clear, lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(summary.range.title), \(summary.count) flows")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

private enum TimeRange: String, CaseIterable, Identifiable {
    case any
    case quick
    case standard
    case steady
    case extended

    static let filterRanges: [TimeRange] = [.quick, .standard, .steady, .extended]

    var id: String { rawValue }

    var title: String {
        switch self {
        case .any: "Any time"
        case .quick: "10 min or less"
        case .standard: "11-15 min"
        case .steady: "16-20 min"
        case .extended: "21+ min"
        }
    }

    func contains(_ minutes: Int) -> Bool {
        switch self {
        case .any: true
        case .quick: minutes <= 10
        case .standard: (11...15).contains(minutes)
        case .steady: (16...20).contains(minutes)
        case .extended: minutes >= 21
        }
    }
}

#Preview("Explore") {
    ExploreView()
}
