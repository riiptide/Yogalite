import SwiftUI

struct OnboardingView: View {
    @AppStorage("didCompleteOnboarding") private var didCompleteOnboarding = false
    @AppStorage("profileDisplayName") private var storedDisplayName = ""
    @AppStorage("preferredPracticeTime") private var preferredPracticeTime = ""
    @AppStorage("yogaExperienceLevel") private var yogaExperienceLevel = ""
    @AppStorage("selectedPracticeTags") private var selectedPracticeTags = ""

    @State private var step: OnboardingStep = .welcome
    @State private var displayName = ""
    @State private var selectedPracticeTime = ""
    @State private var selectedExperience = ""
    @State private var selectedTags: Set<String> = []
    @FocusState private var isNameFocused: Bool

    private var trimmedName: String {
        displayName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var canContinue: Bool {
        switch step {
        case .welcome:
            true
        case .name:
            !trimmedName.isEmpty
        case .practiceTime:
            !selectedPracticeTime.isEmpty
        case .experience:
            !selectedExperience.isEmpty
        case .interests:
            true
        }
    }

    var body: some View {
        ZStack {
            FlowDesign.background.ignoresSafeArea()

            VStack(spacing: 0) {
                progressHeader

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        hero
                        stepContent
                    }
                    .padding(FlowDesign.spacing)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                footer
            }
        }
        .onAppear {
            displayName = storedDisplayName
            selectedPracticeTime = preferredPracticeTime
            selectedExperience = yogaExperienceLevel
            selectedTags = Set(OnboardingPreferences.decodeTags(selectedPracticeTags))
        }
    }

    private var progressHeader: some View {
        VStack(spacing: 12) {
            HStack(spacing: 7) {
                ForEach(OnboardingStep.allCases) { item in
                    Capsule()
                        .fill(item.rawValue <= step.rawValue ? FlowDesign.teal : FlowDesign.softLine)
                        .frame(height: 5)
                }
            }
            .padding(.horizontal, FlowDesign.spacing)
            .padding(.top, 14)
        }
    }

    private var hero: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(FlowDesign.paleAqua)
                PoseIllustrationView(pose: SunSalutationData.easyPose)
                    .padding(16)
            }
            .frame(width: 92, height: 92)

            VStack(alignment: .leading, spacing: 6) {
                Text("Yogalite")
                    .font(.caption.weight(.heavy))
                    .textCase(.uppercase)
                    .foregroundStyle(FlowDesign.teal)
                Text(step.eyebrow)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(FlowDesign.text)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(18)
        .background(Color(.systemBackground).opacity(0.92))
        .clipShape(RoundedRectangle(cornerRadius: FlowDesign.cornerLarge, style: .continuous))
        .shadow(color: FlowDesign.teal.opacity(0.10), radius: 18, x: 0, y: 10)
    }

    @ViewBuilder
    private var stepContent: some View {
        switch step {
        case .welcome:
            welcomeStep
        case .name:
            nameStep
        case .practiceTime:
            choiceStep(
                title: "What time of day do you like to practice?",
                options: OnboardingPreferences.practiceTimes,
                selectedValue: $selectedPracticeTime
            )
        case .experience:
            choiceStep(
                title: "What is your experience with yoga?",
                options: OnboardingPreferences.experienceLevels,
                selectedValue: $selectedExperience
            )
        case .interests:
            interestsStep
        }
    }

    private var welcomeStep: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Welcome to Yogalite!")
                .font(.system(.largeTitle, design: .rounded, weight: .bold))
                .foregroundStyle(FlowDesign.text)
                .fixedSize(horizontal: false, vertical: true)

            Text("A few quick questions will help shape your practice space.")
                .font(.title3)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var nameStep: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("What is your name?")
                .font(.system(.largeTitle, design: .rounded, weight: .bold))
                .foregroundStyle(FlowDesign.text)
                .fixedSize(horizontal: false, vertical: true)

            TextField("Your name", text: $displayName)
                .font(.title3.weight(.semibold))
                .textInputAutocapitalization(.words)
                .submitLabel(.next)
                .focused($isNameFocused)
                .padding(16)
                .background(Color(.systemBackground).opacity(0.94))
                .clipShape(RoundedRectangle(cornerRadius: FlowDesign.cornerMedium, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: FlowDesign.cornerMedium, style: .continuous)
                        .stroke(trimmedName.isEmpty ? FlowDesign.softLine : FlowDesign.teal.opacity(0.42), lineWidth: 1)
                }
                .onSubmit {
                    if canContinue {
                        advance()
                    }
                }

            if trimmedName.isEmpty {
                Text("Enter a name to continue.")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
        }
        .onAppear {
            isNameFocused = true
        }
    }

    private func choiceStep(title: String, options: [OnboardingChoice], selectedValue: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.system(.largeTitle, design: .rounded, weight: .bold))
                .foregroundStyle(FlowDesign.text)
                .fixedSize(horizontal: false, vertical: true)

            VStack(spacing: 12) {
                ForEach(options) { option in
                    OnboardingChoiceButton(
                        title: option.title,
                        systemImage: option.systemImage,
                        isSelected: selectedValue.wrappedValue == option.title
                    ) {
                        selectedValue.wrappedValue = option.title
                    }
                }
            }
        }
    }

    private var interestsStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Select up to 3 goals and focus areas.")
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    .foregroundStyle(FlowDesign.text)
                    .fixedSize(horizontal: false, vertical: true)

                Text("You can continue without selecting interests.")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            FlowLayout(spacing: 9) {
                ForEach(OnboardingPreferences.interestTags, id: \.self) { tag in
                    Button {
                        toggleTag(tag)
                    } label: {
                        HStack(spacing: 6) {
                            if selectedTags.contains(tag) {
                                Image(systemName: "checkmark")
                                    .font(.caption.weight(.heavy))
                            }
                            Text(tag)
                                .font(.caption.weight(.bold))
                                .lineLimit(1)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 9)
                        .background(selectedTags.contains(tag) ? FlowDesign.teal : FlowDesign.paleAqua.opacity(0.76))
                        .foregroundStyle(selectedTags.contains(tag) ? .white : FlowDesign.teal)
                        .clipShape(Capsule())
                        .opacity(canSelect(tag) ? 1 : 0.42)
                    }
                    .disabled(!canSelect(tag))
                    .accessibilityLabel(tag)
                }
            }

            Text("\(selectedTags.count)/3 selected")
                .font(.caption.weight(.bold))
                .foregroundStyle(.secondary)
        }
    }

    private var footer: some View {
        VStack(spacing: 12) {
            PrimaryButton(step == .interests ? "Start Yogalite" : "Continue", systemImage: step == .interests ? "checkmark" : "arrow.right") {
                advance()
            }
            .disabled(!canContinue)
            .opacity(canContinue ? 1 : 0.45)

            if step != .welcome {
                Button("Back") {
                    retreat()
                }
                .font(.subheadline.weight(.bold))
                .foregroundStyle(FlowDesign.teal)
            }
        }
        .padding(FlowDesign.spacing)
        .background(.ultraThinMaterial)
    }

    private func advance() {
        guard canContinue else { return }

        if step == .interests {
            completeOnboarding()
        } else if let nextStep = OnboardingStep(rawValue: step.rawValue + 1) {
            withAnimation(.snappy) {
                step = nextStep
            }
        }
    }

    private func retreat() {
        guard let previousStep = OnboardingStep(rawValue: step.rawValue - 1) else { return }
        withAnimation(.snappy) {
            step = previousStep
        }
    }

    private func completeOnboarding() {
        storedDisplayName = trimmedName
        preferredPracticeTime = selectedPracticeTime
        yogaExperienceLevel = selectedExperience
        selectedPracticeTags = OnboardingPreferences.encodeTags(Array(selectedTags))
        didCompleteOnboarding = true
    }

    private func toggleTag(_ tag: String) {
        if selectedTags.contains(tag) {
            selectedTags.remove(tag)
        } else if selectedTags.count < 3 {
            selectedTags.insert(tag)
        }
    }

    private func canSelect(_ tag: String) -> Bool {
        selectedTags.contains(tag) || selectedTags.count < 3
    }
}

private enum OnboardingStep: Int, CaseIterable, Identifiable {
    case welcome
    case name
    case practiceTime
    case experience
    case interests

    var id: Int { rawValue }

    var eyebrow: String {
        switch self {
        case .welcome:
            return "Welcome"
        case .name:
            return "Your name"
        case .practiceTime:
            return "Practice rhythm"
        case .experience:
            return "Experience"
        case .interests:
            return "Goals"
        }
    }
}

private struct OnboardingChoiceButton: View {
    let title: String
    let systemImage: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(isSelected ? .white : FlowDesign.teal)
                    .frame(width: 34, height: 34)
                    .background(isSelected ? Color.white.opacity(0.18) : FlowDesign.paleAqua)
                    .clipShape(Circle())

                Text(title)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(isSelected ? .white : FlowDesign.text)
                    .multilineTextAlignment(.leading)

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(isSelected ? .white : FlowDesign.secondaryText)
            }
            .padding(15)
            .background(isSelected ? FlowDesign.teal : Color(.systemBackground).opacity(0.94))
            .clipShape(RoundedRectangle(cornerRadius: FlowDesign.cornerMedium, style: .continuous))
            .shadow(color: isSelected ? FlowDesign.teal.opacity(0.16) : .black.opacity(0.04), radius: 12, x: 0, y: 7)
        }
        .accessibilityLabel(title)
    }
}

struct OnboardingChoice: Identifiable {
    let title: String
    let systemImage: String
    var id: String { title }
}

enum OnboardingPreferences {
    static let practiceTimes = [
        OnboardingChoice(title: "Morning", systemImage: "sun.max"),
        OnboardingChoice(title: "Afternoon", systemImage: "sun.max.fill"),
        OnboardingChoice(title: "Evening", systemImage: "sunset")
    ]

    static let experienceLevels = [
        OnboardingChoice(title: "Never done yoga before", systemImage: "sparkles"),
        OnboardingChoice(title: "Beginner", systemImage: "figure.yoga"),
        OnboardingChoice(title: "Beginner-intermediate", systemImage: "chart.bar"),
        OnboardingChoice(title: "Intermediate", systemImage: "flame")
    ]

    static let interestTags = [
        "Morning",
        "Evening",
        "Stress Relief",
        "Better Sleep",
        "Strength",
        "Flexibility",
        "Mobility",
        "Balance",
        "Core",
        "Hips",
        "Hamstrings",
        "Back Care",
        "Beginner",
        "Quick Practices",
        "Restorative"
    ]

    static func encodeTags(_ tags: [String]) -> String {
        tags.sorted().joined(separator: "|")
    }

    static func decodeTags(_ encodedTags: String) -> [String] {
        encodedTags
            .split(separator: "|")
            .map(String.init)
            .filter { !$0.isEmpty }
    }
}

#Preview {
    OnboardingView()
}
