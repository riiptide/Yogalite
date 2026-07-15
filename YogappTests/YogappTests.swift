import Foundation
import Testing
@testable import Yogapp

@MainActor
struct PracticePlayerViewModelTests {
    private let sequence = YogaSequence(
        id: "test-flow",
        title: "Test Flow",
        subtitle: "Short deterministic test sequence.",
        difficulty: "Beginner",
        rounds: 4,
        steps: [
            PracticeStep(
                kind: .hold,
                title: "Hold One",
                startPose: Pose(id: "one", name: "One", assetName: "one"),
                duration: 2,
                breathCue: .natural,
                instruction: "Hold."
            ),
            PracticeStep(
                kind: .transition,
                title: "Move One",
                startPose: Pose(id: "one", name: "One", assetName: "one"),
                endPose: Pose(id: "two", name: "Two", assetName: "two"),
                duration: 1,
                breathCue: .inhale,
                instruction: "Move."
            )
        ]
    )

    @Test func advancingFromOneStepToTheNext() {
        let now = Date(timeIntervalSinceReferenceDate: 100)
        let viewModel = PracticePlayerViewModel(sequence: sequence)

        viewModel.start(now: now)
        viewModel.tick(now: now.addingTimeInterval(2.1))

        #expect(viewModel.currentStepIndex == 1)
        #expect(viewModel.currentStep.title == "Move One")
        #expect(viewModel.currentRound == 1)
    }

    @Test func pausingAndResumingKeepsElapsedTimeStableWhilePaused() {
        let now = Date(timeIntervalSinceReferenceDate: 200)
        let viewModel = PracticePlayerViewModel(sequence: sequence)

        viewModel.start(now: now)
        viewModel.tick(now: now.addingTimeInterval(1))
        viewModel.pause(now: now.addingTimeInterval(1))
        viewModel.tick(now: now.addingTimeInterval(20))

        #expect(viewModel.currentStepIndex == 0)
        #expect(viewModel.remainingTime == 1)

        viewModel.resume(now: now.addingTimeInterval(20))
        viewModel.tick(now: now.addingTimeInterval(21.1))

        #expect(viewModel.currentStepIndex == 1)
    }

    @Test func movingToTheNextRound() {
        let now = Date(timeIntervalSinceReferenceDate: 300)
        let viewModel = PracticePlayerViewModel(sequence: sequence)

        viewModel.start(now: now)
        viewModel.tick(now: now.addingTimeInterval(3.1))

        #expect(viewModel.currentRound == 2)
        #expect(viewModel.currentStepIndex == 0)
    }

    @Test func completingAfterFourRounds() {
        let now = Date(timeIntervalSinceReferenceDate: 400)
        let viewModel = PracticePlayerViewModel(sequence: sequence)

        viewModel.start(now: now)
        viewModel.tick(now: now.addingTimeInterval(12.1))

        #expect(viewModel.isComplete)
        #expect(viewModel.overallProgress == 1)
    }

    @Test func restartingThePractice() {
        let now = Date(timeIntervalSinceReferenceDate: 500)
        let viewModel = PracticePlayerViewModel(sequence: sequence)

        viewModel.start(now: now)
        viewModel.tick(now: now.addingTimeInterval(4))
        viewModel.restart(now: now.addingTimeInterval(10))

        #expect(viewModel.currentRound == 1)
        #expect(viewModel.currentStepIndex == 0)
        #expect(viewModel.remainingTime == 2)
        #expect(!viewModel.isComplete)
    }

    @Test func skippingToNextStep() {
        let now = Date(timeIntervalSinceReferenceDate: 550)
        let viewModel = PracticePlayerViewModel(sequence: sequence)

        viewModel.start(now: now)
        viewModel.next(now: now.addingTimeInterval(0.5))

        #expect(viewModel.currentStepIndex == 1)
        #expect(viewModel.remainingTime == 1)
    }

    @Test func overallProgressCalculation() {
        let now = Date(timeIntervalSinceReferenceDate: 600)
        let viewModel = PracticePlayerViewModel(sequence: sequence)

        viewModel.start(now: now)
        viewModel.tick(now: now.addingTimeInterval(6))

        #expect(abs(viewModel.overallProgress - 0.5) < 0.0001)
    }
}

@MainActor
struct PracticeNarrationCueBuilderTests {
    private let mountain = Pose(id: "mountain", name: "Mountain Pose", assetName: "mountain_pose")
    private let forwardFold = Pose(id: "forward-fold", name: "Forward Fold", assetName: "forward_fold")

    @Test func longHoldStepSpeaksOnlyHoldDuration() {
        let step = PracticeStep(
            kind: .hold,
            title: "Mountain Pose",
            startPose: mountain,
            duration: 10,
            breathCue: .inhale,
            instruction: "Stand tall."
        )

        #expect(PracticeNarrationCueBuilder.narration(for: step) == "Hold for 10 seconds")
    }

    @Test func openingHoldStepSpeaksPoseNameAndHoldDuration() {
        let step = PracticeStep(
            kind: .hold,
            title: "Mountain Pose",
            startPose: mountain,
            duration: 10,
            breathCue: .natural,
            instruction: "Stand tall."
        )

        #expect(PracticeNarrationCueBuilder.narration(for: step, includeHoldPoseName: true) == "Mountain Pose. Hold for 10 seconds")
    }

    @Test func shortHoldDoesNotRepeatBreathOrPoseName() {
        let step = PracticeStep(
            kind: .hold,
            title: "Mountain Pose",
            startPose: mountain,
            duration: 8,
            breathCue: .exhale,
            instruction: "Stand tall."
        )

        #expect(PracticeNarrationCueBuilder.narration(for: step).isEmpty)
    }

    @Test func transitionSpeaksBreathAndTargetPose() {
        let step = PracticeStep(
            kind: .transition,
            title: "Mountain Pose to Forward Fold",
            startPose: mountain,
            endPose: forwardFold,
            duration: 4,
            breathCue: .exhale,
            instruction: "Fold forward."
        )

        #expect(PracticeNarrationCueBuilder.narration(for: step) == "Exhale. Forward Fold")
    }
}

@MainActor
struct TimeOfDayGreetingTests {
    @Test func morningGreetingStartsAtFive() {
        #expect(TimeOfDayGreeting.current(date: date(hour: 5), calendar: calendar) == .morning)
        #expect(TimeOfDayGreeting.current(date: date(hour: 11), calendar: calendar) == .morning)
    }

    @Test func afternoonGreetingStartsAtNoon() {
        #expect(TimeOfDayGreeting.current(date: date(hour: 12), calendar: calendar) == .afternoon)
        #expect(TimeOfDayGreeting.current(date: date(hour: 16), calendar: calendar) == .afternoon)
    }

    @Test func eveningGreetingStartsAtFivePm() {
        #expect(TimeOfDayGreeting.current(date: date(hour: 17), calendar: calendar) == .evening)
        #expect(TimeOfDayGreeting.current(date: date(hour: 20), calendar: calendar) == .evening)
    }

    @Test func nightGreetingCoversLateAndEarlyHours() {
        #expect(TimeOfDayGreeting.current(date: date(hour: 21), calendar: calendar) == .night)
        #expect(TimeOfDayGreeting.current(date: date(hour: 4), calendar: calendar) == .night)
    }

    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }

    private func date(hour: Int) -> Date {
        DateComponents(calendar: calendar, timeZone: calendar.timeZone, year: 2026, month: 7, day: 15, hour: hour).date!
    }
}

@MainActor
struct DailyFlowSelectorTests {
    @Test func sameLocalCalendarDayKeepsTheSameFlow() {
        let morning = date(year: 2026, month: 7, day: 15, hour: 7)
        let evening = date(year: 2026, month: 7, day: 15, hour: 21)

        let morningFlow = DailyFlowSelector.sequence(for: morning, in: sequences, calendar: calendar)
        let eveningFlow = DailyFlowSelector.sequence(for: evening, in: sequences, calendar: calendar)

        #expect(morningFlow?.id == eveningFlow?.id)
    }

    @Test func nextLocalCalendarDaySelectsAnotherFlow() {
        let today = date(year: 2026, month: 1, day: 1, hour: 10)
        let tomorrow = date(year: 2026, month: 1, day: 2, hour: 10)

        let todayFlow = DailyFlowSelector.sequence(for: today, in: sequences, calendar: calendar)
        let tomorrowFlow = DailyFlowSelector.sequence(for: tomorrow, in: sequences, calendar: calendar)

        #expect(todayFlow?.id == "flow-one")
        #expect(tomorrowFlow?.id == "flow-two")
    }

    @Test func emptyLibraryReturnsNil() {
        let selectedFlow = DailyFlowSelector.sequence(for: date(year: 2026, month: 1, day: 1, hour: 10), in: [], calendar: calendar)

        #expect(selectedFlow == nil)
    }

    private var sequences: [YogaSequence] {
        [
            sequence(id: "flow-one"),
            sequence(id: "flow-two"),
            sequence(id: "flow-three")
        ]
    }

    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }

    private func date(year: Int, month: Int, day: Int, hour: Int) -> Date {
        DateComponents(calendar: calendar, timeZone: calendar.timeZone, year: year, month: month, day: day, hour: hour).date!
    }

    private func sequence(id: String) -> YogaSequence {
        YogaSequence(
            id: id,
            title: id,
            subtitle: "Test flow",
            difficulty: "Beginner",
            rounds: 1,
            steps: [
                PracticeStep(
                    kind: .hold,
                    title: "Mountain Pose",
                    startPose: Pose(id: "mountain", name: "Mountain Pose", assetName: "mountain_pose"),
                    duration: 10,
                    breathCue: .natural,
                    instruction: "Stand tall."
                )
            ]
        )
    }
}

@MainActor
struct RecommendedFlowSelectorTests {
    @Test func prefersFlowsMatchingSelectedTagsAndExcludesDailyFlow() {
        let recommendations = RecommendedFlowSelector.sequences(
            for: date(year: 2026, month: 1, day: 1, hour: 10),
            in: [
                sequence(id: "daily", tags: ["Morning"]),
                sequence(id: "hips", tags: ["Hips", "Flexibility"]),
                sequence(id: "strength", tags: ["Strength"]),
                sequence(id: "calm", tags: ["Stress Relief"])
            ],
            selectedTags: ["Hips"],
            excluding: "daily",
            calendar: calendar
        )

        #expect(recommendations.map(\.id) == ["hips", "strength"])
    }

    @Test func sameLocalDayKeepsRecommendationsStable() {
        let morningRecommendations = RecommendedFlowSelector.sequences(
            for: date(year: 2026, month: 7, day: 15, hour: 7),
            in: sequences,
            selectedTags: [],
            calendar: calendar
        )
        let eveningRecommendations = RecommendedFlowSelector.sequences(
            for: date(year: 2026, month: 7, day: 15, hour: 21),
            in: sequences,
            selectedTags: [],
            calendar: calendar
        )

        #expect(morningRecommendations.map(\.id) == eveningRecommendations.map(\.id))
    }

    @Test func nextLocalCalendarDayRotatesFallbackRecommendations() {
        let todayRecommendations = RecommendedFlowSelector.sequences(
            for: date(year: 2026, month: 1, day: 1, hour: 10),
            in: sequences,
            selectedTags: [],
            calendar: calendar
        )
        let tomorrowRecommendations = RecommendedFlowSelector.sequences(
            for: date(year: 2026, month: 1, day: 2, hour: 10),
            in: sequences,
            selectedTags: [],
            calendar: calendar
        )

        #expect(todayRecommendations.map(\.id) == ["flow-one", "flow-two"])
        #expect(tomorrowRecommendations.map(\.id) == ["flow-two", "flow-three"])
    }

    private var sequences: [YogaSequence] {
        [
            sequence(id: "flow-one", tags: ["Morning"]),
            sequence(id: "flow-two", tags: ["Evening"]),
            sequence(id: "flow-three", tags: ["Core"])
        ]
    }

    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }

    private func date(year: Int, month: Int, day: Int, hour: Int) -> Date {
        DateComponents(calendar: calendar, timeZone: calendar.timeZone, year: year, month: month, day: day, hour: hour).date!
    }

    private func sequence(id: String, tags: [String]) -> YogaSequence {
        YogaSequence(
            id: id,
            title: id,
            subtitle: "Test flow",
            difficulty: "Beginner",
            rounds: 1,
            steps: [
                PracticeStep(
                    kind: .hold,
                    title: "Mountain Pose",
                    startPose: Pose(id: "mountain", name: "Mountain Pose", assetName: "mountain_pose"),
                    duration: 10,
                    breathCue: .natural,
                    instruction: "Stand tall."
                )
            ],
            tags: tags
        )
    }
}

@MainActor
struct OnboardingPreferencesTests {
    @Test func selectedTagsRoundTripThroughStorageString() {
        let encodedTags = OnboardingPreferences.encodeTags(["Strength", "Morning", "Hips"])

        #expect(encodedTags == "Hips|Morning|Strength")
        #expect(OnboardingPreferences.decodeTags(encodedTags) == ["Hips", "Morning", "Strength"])
    }
}

@MainActor
struct RoundTextTests {
    @Test func formatsSingularAndPluralRounds() {
        #expect(1.roundsText == "1 round")
        #expect(2.roundsText == "2 rounds")
    }
}
