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
