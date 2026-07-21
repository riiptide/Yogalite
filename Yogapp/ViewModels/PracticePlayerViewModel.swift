import Foundation
import Observation

@MainActor
@Observable
final class PracticePlayerViewModel {
    let sequence: YogaSequence

    private(set) var currentStepIndex = 0
    private(set) var currentRound = 1
    private(set) var remainingTime: TimeInterval
    private(set) var elapsedTime: TimeInterval = 0
    private(set) var transitionProgress: Double = 0
    private(set) var isPlaying = false
    private(set) var isPaused = false
    private(set) var isComplete = false

    private var stepStartedAt: Date?
    private var stepElapsedBeforePause: TimeInterval = 0
    private var timerTask: Task<Void, Never>?

    init(sequence: YogaSequence) {
        self.sequence = sequence
        self.remainingTime = sequence.steps.first?.duration ?? 0
    }

    var currentStep: PracticeStep {
        sequence.steps[currentStepIndex]
    }

    var nextStep: PracticeStep? {
        guard !sequence.steps.isEmpty else { return nil }
        let nextIndex = currentStepIndex + 1
        if nextIndex < sequence.steps.count {
            return sequence.steps[nextIndex]
        }
        return currentRound < sequence.rounds ? sequence.steps.first : nil
    }

    var canGoToPreviousStep: Bool {
        currentStepIndex > 0 || currentRound > 1
    }

    var overallProgress: Double {
        if isComplete { return 1 }
        guard totalDuration > 0 else { return 0 }
        return min(max(completedElapsedTime / totalDuration, 0), 1)
    }

    var stepProgress: Double {
        guard currentStep.duration > 0 else { return 1 }
        return min(max(elapsedTime / currentStep.duration, 0), 1)
    }

    func start(now: Date = Date()) {
        guard !sequence.steps.isEmpty else {
            isComplete = true
            return
        }
        timerTask?.cancel()
        isPlaying = true
        isPaused = false
        isComplete = false
        currentStepIndex = 0
        currentRound = 1
        stepElapsedBeforePause = 0
        elapsedTime = 0
        remainingTime = currentStep.duration
        transitionProgress = currentStep.kind == .transition ? 0 : 1
        stepStartedAt = now
        beginTimerLoop()
    }

    func pause(now: Date = Date()) {
        guard isPlaying, !isPaused, !isComplete else { return }
        tick(now: now)
        isPaused = true
        stepElapsedBeforePause = elapsedTime
        stepStartedAt = nil
    }

    func resume(now: Date = Date()) {
        guard isPlaying, isPaused, !isComplete else { return }
        isPaused = false
        stepStartedAt = now
        beginTimerLoop()
    }

    func togglePause(now: Date = Date()) {
        isPaused ? resume(now: now) : pause(now: now)
    }

    func restart(now: Date = Date()) {
        start(now: now)
    }

    func previous(now: Date = Date()) {
        guard isPlaying, !isComplete, canGoToPreviousStep else { return }
        if currentStepIndex > 0 {
            currentStepIndex -= 1
        } else if currentRound > 1 {
            currentRound -= 1
            currentStepIndex = sequence.steps.count - 1
        }
        resetCurrentStep(now: now)
    }

    func next(now: Date = Date()) {
        guard isPlaying, !isComplete else { return }
        advanceStep()
        if !isComplete {
            resetCurrentStep(now: now)
        }
    }

    func stop() {
        timerTask?.cancel()
        timerTask = nil
        isPlaying = false
    }

    func tick(now: Date = Date()) {
        guard isPlaying, !isPaused, !isComplete else { return }
        guard let stepStartedAt else { return }

        var elapsed = stepElapsedBeforePause + max(0, now.timeIntervalSince(stepStartedAt))
        var currentDuration = currentStep.duration

        while elapsed >= currentDuration, !isComplete {
            elapsed -= currentDuration
            advanceStep()
            currentDuration = currentStep.duration
            self.stepStartedAt = now.addingTimeInterval(-elapsed)
            stepElapsedBeforePause = 0
        }

        if isComplete {
            elapsedTime = 0
            remainingTime = 0
            transitionProgress = 1
            return
        }

        elapsedTime = elapsed
        remainingTime = max(currentDuration - elapsed, 0)
        transitionProgress = currentStep.kind == .transition ? stepProgress : 1
    }

    private var roundDuration: TimeInterval {
        sequence.steps.reduce(0) { $0 + $1.duration }
    }

    private var totalDuration: TimeInterval {
        roundDuration * Double(sequence.rounds)
    }

    private var completedElapsedTime: TimeInterval {
        let previousRounds = Double(max(currentRound - 1, 0)) * roundDuration
        let previousSteps = sequence.steps.prefix(currentStepIndex).reduce(0) { $0 + $1.duration }
        return previousRounds + previousSteps + elapsedTime
    }

    private func advanceStep() {
        if currentStepIndex < sequence.steps.count - 1 {
            currentStepIndex += 1
        } else if currentRound < sequence.rounds {
            currentRound += 1
            currentStepIndex = 0
        } else {
            complete()
        }
    }

    private func resetCurrentStep(now: Date) {
        stepStartedAt = isPaused ? nil : now
        stepElapsedBeforePause = 0
        elapsedTime = 0
        remainingTime = currentStep.duration
        transitionProgress = currentStep.kind == .transition ? 0 : 1
    }

    private func complete() {
        isComplete = true
        isPlaying = false
        isPaused = false
        timerTask?.cancel()
        timerTask = nil
    }

    private func beginTimerLoop() {
        timerTask?.cancel()
        timerTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(100))
                guard let self else { break }
                self.tick()
            }
        }
    }
}
