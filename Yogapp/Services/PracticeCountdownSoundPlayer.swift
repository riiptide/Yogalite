import AudioToolbox
import Foundation

enum PracticeCountdownSoundPlayer {
    static func playCountBeep() {
        AudioServicesPlaySystemSound(1104)
    }

    static func playBeginBeep() {
        AudioServicesPlaySystemSound(1025)
    }
}
