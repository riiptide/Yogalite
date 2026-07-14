import Foundation
import SwiftData

@Model
final class SavedPracticeRecord {
    @Attribute(.unique) var sequenceID: String
    var savedAt: Date

    init(sequenceID: String, savedAt: Date = Date()) {
        self.sequenceID = sequenceID
        self.savedAt = savedAt
    }
}

@Model
final class PracticeCompletionRecord {
    var id: UUID
    var sequenceID: String
    var sequenceTitle: String
    var completedAt: Date
    var duration: TimeInterval
    var rounds: Int

    init(
        id: UUID = UUID(),
        sequenceID: String,
        sequenceTitle: String,
        completedAt: Date = Date(),
        duration: TimeInterval,
        rounds: Int
    ) {
        self.id = id
        self.sequenceID = sequenceID
        self.sequenceTitle = sequenceTitle
        self.completedAt = completedAt
        self.duration = duration
        self.rounds = rounds
    }
}

enum PracticePersistence {
    static let defaultSavedSequenceIDs = [
        SunSalutationData.sunSalutationA.id,
        SunSalutationData.sunSalutationB.id
    ]

    static func sequence(for id: String) -> YogaSequence? {
        SunSalutationData.allSequences.first { $0.id == id }
    }

    static func seedSavedPracticesIfNeeded(modelContext: ModelContext, didSeed: inout Bool) {
        guard !didSeed else { return }
        for sequenceID in defaultSavedSequenceIDs {
            modelContext.insert(SavedPracticeRecord(sequenceID: sequenceID))
        }
        try? modelContext.save()
        didSeed = true
    }
}

extension Array where Element == PracticeCompletionRecord {
    var totalMinutesPracticed: Int {
        Int((reduce(0) { $0 + $1.duration } / 60).rounded())
    }

    var dayStreak: Int {
        let calendar = Calendar.current
        let completedDays = Set(map { calendar.startOfDay(for: $0.completedAt) })
        guard !completedDays.isEmpty else { return 0 }

        var streak = 0
        var day = calendar.startOfDay(for: Date())

        if !completedDays.contains(day),
           let yesterday = calendar.date(byAdding: .day, value: -1, to: day) {
            day = yesterday
        }

        while completedDays.contains(day) {
            streak += 1
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: day) else { break }
            day = previousDay
        }

        return streak
    }
}
