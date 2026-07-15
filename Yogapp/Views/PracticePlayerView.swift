import SwiftUI
import SwiftData
import UIKit

struct PracticePlayerView: View {
    @State private var viewModel: PracticePlayerViewModel
    let endWorkoutAction: () -> Void
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @State private var isShowingIntro = true
    @State private var didRecordCurrentCompletion = false
    @State private var narrationPlayer = PracticeNarrationPlayer()
    @State private var countdownDisplay: CountdownDisplay?
    @State private var countdownTask: Task<Void, Never>?

    init(viewModel: PracticePlayerViewModel, endWorkoutAction: @escaping () -> Void = {}) {
        _viewModel = State(initialValue: viewModel)
        self.endWorkoutAction = endWorkoutAction
    }

    var body: some View {
        ZStack {
            FlowDesign.background.ignoresSafeArea()

            if viewModel.isComplete {
                CompletionView(
                    sequence: viewModel.sequence,
                    restartAction: {
                        didRecordCurrentCompletion = false
                        beginPracticeWithCountdown {
                            viewModel.restart()
                        }
                    },
                    exitAction: endWorkout
                )
            } else {
                GeometryReader { proxy in
                    let usableHeight = proxy.size.height - proxy.safeAreaInsets.top - proxy.safeAreaInsets.bottom
                    let figureSize = min(300, max(220, usableHeight * 0.34))
                    let timerSize = min(104, max(86, usableHeight * 0.13))

                    VStack(spacing: 12) {
                        topBar
                        progressArea
                        Spacer(minLength: 0)
                        figureArea(size: figureSize)
                        currentStepArea
                        CircularCountdownView(
                            remainingTime: viewModel.remainingTime,
                            duration: viewModel.currentStep.duration,
                            size: timerSize
                        )
                        Spacer(minLength: 0)
                        controls
                    }
                    .padding(.horizontal, FlowDesign.spacing)
                    .padding(.top, proxy.safeAreaInsets.top + 8)
                    .padding(.bottom, proxy.safeAreaInsets.bottom + 28)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }

            if isShowingIntro && !viewModel.isComplete {
                introOverlay
            }

            if let countdownDisplay {
                countdownOverlay(countdownDisplay)
            }
        }
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            isShowingIntro = !viewModel.isPlaying && !viewModel.isComplete
            updateIdleTimerDisabled()
        }
        .onDisappear {
            countdownTask?.cancel()
            narrationPlayer.stop()
            viewModel.stop()
            UIApplication.shared.isIdleTimerDisabled = false
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                updateIdleTimerDisabled()
                viewModel.tick()
            } else {
                UIApplication.shared.isIdleTimerDisabled = false
                countdownTask?.cancel()
                countdownDisplay = nil
                narrationPlayer.stop()
            }
        }
        .onChange(of: viewModel.isComplete) { _, isComplete in
            guard isComplete else { return }
            UIApplication.shared.isIdleTimerDisabled = false
            narrationPlayer.stop()
            recordCompletionIfNeeded()
        }
        .onChange(of: viewModel.currentStep.id) { _, _ in
            guard viewModel.isPlaying, !viewModel.isPaused, !viewModel.isComplete else { return }
            narrationPlayer.speak(step: viewModel.currentStep)
        }
        .onChange(of: viewModel.isPaused) { _, isPaused in
            if isPaused {
                narrationPlayer.stop()
            }
        }
    }

    private var topBar: some View {
        HStack {
            Button {
                endWorkout()
            } label: {
                Label("End", systemImage: "xmark")
                    .font(.callout.weight(.bold))
                    .padding(.horizontal, 14)
                    .frame(height: 44)
                    .background(Color(.systemBackground).opacity(0.86))
                    .clipShape(Capsule())
            }
            .accessibilityLabel("End workout and return home")

            Spacer()

            Text("Round \(viewModel.currentRound) of \(viewModel.sequence.rounds)")
                .font(.headline.weight(.bold))
                .foregroundStyle(FlowDesign.text)

            Spacer()

            Button {
                beginPracticeWithCountdown {
                    viewModel.restart()
                }
            } label: {
                Image(systemName: "arrow.counterclockwise")
                    .font(.headline.weight(.bold))
                    .frame(width: 44, height: 44)
                    .background(Color(.systemBackground).opacity(0.86))
                    .clipShape(Circle())
            }
            .accessibilityLabel("Restart practice")
        }
    }

    private var progressArea: some View {
        VStack(spacing: 8) {
            ProgressView(value: viewModel.overallProgress)
                .tint(FlowDesign.teal)
                .accessibilityLabel("Overall progress")
            Text("\(Int((viewModel.overallProgress * 100).rounded()))% complete")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
        }
    }

    private func figureArea(size: CGFloat) -> some View {
        ZStack {
            Circle()
                .fill(FlowDesign.paleAqua.opacity(0.72))
                .frame(width: size, height: size)

            if viewModel.currentStep.kind == .transition, let endPose = viewModel.currentStep.endPose {
                PoseTransitionView(
                    startPose: viewModel.currentStep.startPose,
                    endPose: endPose,
                    progress: viewModel.transitionProgress,
                    isPaused: viewModel.isPaused,
                    startSide: viewModel.currentStep.side,
                    endSide: viewModel.currentStep.endSide
                )
                .frame(width: size * 0.90, height: size * 0.90)
            } else {
                PoseIllustrationView(pose: viewModel.currentStep.startPose, side: viewModel.currentStep.side, isBreathing: viewModel.isPlaying && !viewModel.isPaused)
                    .frame(width: size * 0.90, height: size * 0.90)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var currentStepArea: some View {
        VStack(spacing: 10) {
            Text(viewModel.currentStep.title)
                .font(.title2.weight(.bold))
                .multilineTextAlignment(.center)
                .foregroundStyle(FlowDesign.text)
            BreathBadge(cue: viewModel.currentStep.breathCue)
                .scaleEffect(1.08)
            if let side = activeSide.displayName {
                Text("\(side) side")
                    .font(.caption.weight(.bold))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(Color(.systemBackground).opacity(0.82))
                    .foregroundStyle(FlowDesign.secondaryText)
                    .clipShape(Capsule())
                    .accessibilityLabel("\(side) side")
            }
            Text(viewModel.currentStep.instruction)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var controls: some View {
        HStack(spacing: 18) {
            Button {
                viewModel.previous()
            } label: {
                Image(systemName: "backward.fill")
                    .font(.title3.weight(.bold))
                    .frame(width: 58, height: 58)
                    .background(Color(.systemBackground))
                    .clipShape(Circle())
            }
            .accessibilityLabel("Previous step")

            Button {
                viewModel.togglePause()
                if viewModel.isPaused {
                    narrationPlayer.stop()
                } else if viewModel.isPlaying, !viewModel.isComplete {
                    narrateCurrentStep()
                }
            } label: {
                Image(systemName: viewModel.isPaused ? "play.fill" : "pause.fill")
                    .font(.title2.weight(.bold))
                    .frame(width: 76, height: 76)
                    .background(FlowDesign.teal)
                    .foregroundStyle(.white)
                    .clipShape(Circle())
            }
            .accessibilityLabel(viewModel.isPaused ? "Resume practice" : "Pause practice")

            Button {
                viewModel.next()
            } label: {
                Image(systemName: "forward.fill")
                    .font(.title3.weight(.bold))
                    .frame(width: 58, height: 58)
                    .background(Color(.systemBackground))
                    .clipShape(Circle())
            }
            .accessibilityLabel("Skip to next step")
        }
        .foregroundStyle(FlowDesign.teal)
    }

    private var activeSide: PracticeSide {
        viewModel.currentStep.endSide == .none ? viewModel.currentStep.side : viewModel.currentStep.endSide
    }

    private var introOverlay: some View {
        ZStack {
            FlowDesign.background.opacity(0.96).ignoresSafeArea()
            VStack(spacing: 20) {
                PoseIllustrationView(pose: viewModel.sequence.steps.first?.startPose ?? SunSalutationData.mountain)
                    .frame(width: 150, height: 150)
                    .padding(18)
                    .background(FlowDesign.paleAqua)
                    .clipShape(Circle())

                VStack(spacing: 10) {
                    Text(viewModel.sequence.title)
                        .font(.title.weight(.bold))
                        .multilineTextAlignment(.center)
                    Text(viewModel.sequence.onboardingNote)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                VStack(alignment: .leading, spacing: 8) {
                    ForEach(viewModel.sequence.safetyNotes.prefix(2), id: \.self) { note in
                        Label(note, systemImage: "checkmark.circle.fill")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(Color(.systemBackground).opacity(0.86))
                .clipShape(RoundedRectangle(cornerRadius: FlowDesign.cornerMedium, style: .continuous))

                PrimaryButton("Begin Practice", systemImage: "play.fill") {
                    isShowingIntro = false
                    didRecordCurrentCompletion = false
                    beginPracticeWithCountdown {
                        viewModel.start()
                    }
                }
            }
            .padding(FlowDesign.spacing)
        }
    }

    private func countdownOverlay(_ display: CountdownDisplay) -> some View {
        ZStack {
            FlowDesign.background.opacity(0.96).ignoresSafeArea()

            VStack(spacing: 18) {
                Text(display.title)
                    .font(.system(size: display == .begin ? 64 : 104, weight: .heavy, design: .rounded))
                    .foregroundStyle(FlowDesign.teal)
                    .contentTransition(.numericText())
                    .scaleEffect(display == .begin ? 1.0 : 1.08)
                    .animation(.spring(response: 0.28, dampingFraction: 0.72), value: display)

                Text(display == .begin ? "Begin" : "Get ready")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(FlowDesign.text)
            }
            .padding(32)
            .frame(maxWidth: .infinity)
            .accessibilityElement(children: .combine)
            .accessibilityLabel(display.accessibilityLabel)
        }
    }

    private func endWorkout() {
        countdownTask?.cancel()
        narrationPlayer.stop()
        viewModel.stop()
        UIApplication.shared.isIdleTimerDisabled = false
        endWorkoutAction()
        dismiss()
    }

    private func beginPracticeWithCountdown(startAction: @escaping @MainActor () -> Void) {
        countdownTask?.cancel()
        narrationPlayer.stop()
        viewModel.stop()

        countdownTask = Task { @MainActor in
            for value in [3, 2, 1] {
                guard !Task.isCancelled else { return }
                countdownDisplay = .number(value)
                PracticeCountdownSoundPlayer.playCountBeep()
                try? await Task.sleep(for: .seconds(1))
            }

            guard !Task.isCancelled else { return }
            countdownDisplay = .begin
            PracticeCountdownSoundPlayer.playBeginBeep()
            try? await Task.sleep(for: .milliseconds(650))

            guard !Task.isCancelled else { return }
            countdownDisplay = nil
            startAction()
            updateIdleTimerDisabled()
            narrateCurrentStep(includeOpeningPoseName: true)
            countdownTask = nil
        }
    }

    private func narrateCurrentStep(includeOpeningPoseName: Bool = false) {
        guard viewModel.isPlaying, !viewModel.isPaused, !viewModel.isComplete else { return }
        narrationPlayer.speak(
            step: viewModel.currentStep,
            includeHoldPoseName: includeOpeningPoseName && viewModel.currentStep.kind == .hold
        )
    }

    private func updateIdleTimerDisabled() {
        UIApplication.shared.isIdleTimerDisabled = scenePhase == .active && !viewModel.isComplete
    }

    private func recordCompletionIfNeeded() {
        guard !didRecordCurrentCompletion else { return }
        didRecordCurrentCompletion = true
        modelContext.insert(
            PracticeCompletionRecord(
                sequenceID: viewModel.sequence.id,
                sequenceTitle: viewModel.sequence.title,
                duration: viewModel.sequence.estimatedDuration,
                rounds: viewModel.sequence.rounds
            )
        )
        ProductAnalytics.recordPracticeCompleted(sequence: viewModel.sequence)
        try? modelContext.save()
    }
}

private enum CountdownDisplay: Equatable {
    case number(Int)
    case begin

    var title: String {
        switch self {
        case .number(let value):
            "\(value)"
        case .begin:
            "Begin"
        }
    }

    var accessibilityLabel: String {
        switch self {
        case .number(let value):
            "\(value)"
        case .begin:
            "Begin practice"
        }
    }
}

#Preview("Practice Hold") {
    let viewModel = PracticePlayerViewModel(sequence: SunSalutationData.sunSalutationA)
    PracticePlayerView(viewModel: viewModel)
}

#Preview("Practice Transition") {
    let viewModel = PracticePlayerViewModel(sequence: SunSalutationData.sunSalutationA)
    viewModel.start()
    viewModel.tick(now: Date().addingTimeInterval(8.5))
    return PracticePlayerView(viewModel: viewModel)
}
