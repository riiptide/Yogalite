import AVFoundation
import Foundation

enum PracticeNarrationCueBuilder {
    static func narration(for step: PracticeStep, includeHoldPoseName: Bool = false) -> String {
        var cues: [String] = []

        switch step.kind {
        case .hold:
            if includeHoldPoseName {
                cues.append(step.startPose.name)
            }
            if step.duration >= 10 {
                cues.append("Hold for \(Int(step.duration.rounded())) seconds")
            }
        case .transition:
            if let breathCue = spokenBreathCue(for: step.breathCue) {
                cues.append(breathCue)
            }
            cues.append(step.endPose?.name ?? step.title)
        }

        return cues.joined(separator: ". ")
    }

    private static func spokenBreathCue(for cue: BreathCue) -> String? {
        switch cue {
        case .inhale:
            "Inhale"
        case .exhale:
            "Exhale"
        case .natural:
            nil
        }
    }
}

@MainActor
final class PracticeNarrationPlayer {
    private let synthesizer = AVSpeechSynthesizer()

    func speak(step: PracticeStep, includeHoldPoseName: Bool = false) {
        let narration = PracticeNarrationCueBuilder.narration(for: step, includeHoldPoseName: includeHoldPoseName)
        guard !narration.isEmpty else { return }

        synthesizer.stopSpeaking(at: .immediate)

        let utterance = AVSpeechUtterance(string: narration)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.92
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0

        synthesizer.speak(utterance)
    }

    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
    }
}
