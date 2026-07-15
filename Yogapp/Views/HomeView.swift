import SwiftUI

struct HomeView: View {
    private let sequences = SunSalutationData.allSequences
    @State private var path: [HomeRoute] = []
    @AppStorage("profileDisplayName") private var displayName = ""
    @AppStorage("selectedPracticeTags") private var selectedPracticeTags = ""

    private var selectedDailySequence: YogaSequence {
        DailyFlowSelector.sequence(for: Date(), in: sequences) ?? SunSalutationData.sunSalutationB
    }

    private var recommendedSequences: [YogaSequence] {
        RecommendedFlowSelector.sequences(
            for: Date(),
            in: sequences,
            selectedTags: OnboardingPreferences.decodeTags(selectedPracticeTags),
            excluding: selectedDailySequence.id
        )
    }

    private var timeOfDayGreeting: TimeOfDayGreeting {
        TimeOfDayGreeting.current()
    }

    private var greetingTitle: String {
        let trimmedName = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            return timeOfDayGreeting.title
        }
        return "\(timeOfDayGreeting.title), \(trimmedName)"
    }

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                FlowDesign.background.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        morningHeader
                        todayFlowCard
                        recommendedFlowsSection
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
                    Text(greetingTitle)
                        .font(.largeTitle.weight(.bold))
                        .foregroundStyle(FlowDesign.text)
                        .lineLimit(2)
                        .minimumScaleFactor(0.78)
                    Image(systemName: timeOfDayGreeting.systemImage)
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
            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Today's Flow")
                        .font(.caption.weight(.heavy))
                        .textCase(.uppercase)
                        .foregroundStyle(FlowDesign.teal)

                    Text(selectedDailySequence.title)
                        .font(.system(.title, design: .rounded, weight: .bold))
                        .foregroundStyle(FlowDesign.text)
                        .lineLimit(3)
                        .minimumScaleFactor(0.78)

                    Text(selectedDailySequence.subtitle)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .lineLimit(3)

                    Label("Start Practice", systemImage: "play.fill")
                        .font(.headline.weight(.bold))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(FlowDesign.teal)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                PoseIllustrationView(pose: heroPose(for: selectedDailySequence))
                    .frame(width: 116, height: 154)
                    .background(
                        Circle()
                            .fill(FlowDesign.paleAqua.opacity(0.76))
                            .frame(width: 116, height: 116)
                    )
                    .accessibilityHidden(true)
            }
            .padding(18)
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

    private var recommendedFlowsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recommended for you")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(FlowDesign.text)
                Spacer()
                Text("Today")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(FlowDesign.teal)
            }

            HStack(spacing: 12) {
                ForEach(recommendedSequences) { sequence in
                    NavigationLink(value: HomeRoute.sequence(sequence.id)) {
                        HomeRecommendationCard(sequence: sequence)
                    }
                    .buttonStyle(.plain)
                }
            }
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

enum TimeOfDayGreeting {
    case morning
    case afternoon
    case evening
    case night

    static func current(date: Date = Date(), calendar: Calendar = .autoupdatingCurrent) -> Self {
        let hour = calendar.component(.hour, from: date)

        switch hour {
        case 5..<12:
            return .morning
        case 12..<17:
            return .afternoon
        case 17..<21:
            return .evening
        default:
            return .night
        }
    }

    var title: String {
        switch self {
        case .morning:
            return "Good morning"
        case .afternoon:
            return "Good afternoon"
        case .evening:
            return "Good evening"
        case .night:
            return "Good night"
        }
    }

    var systemImage: String {
        switch self {
        case .morning:
            return "sun.max.fill"
        case .afternoon:
            return "sun.max.fill"
        case .evening:
            return "sunset.fill"
        case .night:
            return "moon.stars.fill"
        }
    }
}

enum DailyFlowSelector {
    static func sequence(
        for date: Date = Date(),
        in sequences: [YogaSequence],
        calendar: Calendar = .autoupdatingCurrent
    ) -> YogaSequence? {
        guard !sequences.isEmpty else { return nil }
        let dayIndex = LocalDaySeed.index(for: date, calendar: calendar)
        return sequences[LocalDaySeed.positiveModulo(dayIndex, sequences.count)]
    }
}

enum RecommendedFlowSelector {
    static func sequences(
        for date: Date = Date(),
        in sequences: [YogaSequence],
        selectedTags: [String],
        excluding excludedSequenceID: String? = nil,
        count: Int = 2,
        calendar: Calendar = .autoupdatingCurrent
    ) -> [YogaSequence] {
        guard count > 0 else { return [] }
        let candidates = sequences.filter { $0.id != excludedSequenceID }
        guard !candidates.isEmpty else { return [] }

        let preferredTags = Set(selectedTags.map(normalized))
        let dayIndex = LocalDaySeed.index(for: date, calendar: calendar)

        return candidates
            .enumerated()
            .sorted { lhs, rhs in
                let lhsScore = preferenceScore(for: lhs.element, preferredTags: preferredTags)
                let rhsScore = preferenceScore(for: rhs.element, preferredTags: preferredTags)

                if lhsScore != rhsScore {
                    return lhsScore > rhsScore
                }

                let lhsRank = LocalDaySeed.positiveModulo(lhs.offset - dayIndex, candidates.count)
                let rhsRank = LocalDaySeed.positiveModulo(rhs.offset - dayIndex, candidates.count)
                return lhsRank < rhsRank
            }
            .prefix(count)
            .map(\.element)
    }

    private static func preferenceScore(for sequence: YogaSequence, preferredTags: Set<String>) -> Int {
        guard !preferredTags.isEmpty else { return 0 }
        let sequenceTags = Set(sequence.tags.map(normalized))
        return preferredTags.intersection(sequenceTags).count
    }

    private static func normalized(_ value: String) -> String {
        value
            .replacingOccurrences(of: "–", with: "-")
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
    }
}

private enum LocalDaySeed {
    static func index(for date: Date, calendar: Calendar) -> Int {
        let referenceDate = DateComponents(
            calendar: calendar,
            timeZone: calendar.timeZone,
            year: 2026,
            month: 1,
            day: 1
        ).date ?? Date(timeIntervalSinceReferenceDate: 0)

        let referenceDay = calendar.startOfDay(for: referenceDate)
        let targetDay = calendar.startOfDay(for: date)
        return calendar.dateComponents([.day], from: referenceDay, to: targetDay).day ?? 0
    }

    static func positiveModulo(_ value: Int, _ divisor: Int) -> Int {
        let remainder = value % divisor
        return remainder >= 0 ? remainder : remainder + divisor
    }
}

private struct HomeRecommendationCard: View {
    let sequence: YogaSequence

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            PoseIllustrationView(pose: sequence.thumbnailPose)
                .frame(width: 58, height: 58)
                .frame(maxWidth: .infinity)
                .background(FlowDesign.paleAqua.opacity(0.72))
                .clipShape(RoundedRectangle(cornerRadius: FlowDesign.cornerMedium, style: .continuous))

            VStack(alignment: .leading, spacing: 1) {
                Text(sequence.title)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(FlowDesign.text)
                    .lineLimit(2)
                    .minimumScaleFactor(0.82)
                Text(sequence.estimatedDuration.minutesText)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground).opacity(0.90))
        .clipShape(RoundedRectangle(cornerRadius: FlowDesign.cornerMedium, style: .continuous))
        .shadow(color: .black.opacity(0.04), radius: 12, x: 0, y: 6)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Recommended flow, \(sequence.title), \(sequence.estimatedDuration.minutesText)")
    }
}

#Preview("Home") {
    HomeView()
}

#Preview("Home Dark") {
    HomeView()
        .preferredColorScheme(.dark)
}
