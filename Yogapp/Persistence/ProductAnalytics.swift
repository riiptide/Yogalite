import Foundation
import SwiftData

@Model
final class ProductAnalyticsProfile {
    @Attribute(.unique) var id: String
    var anonymousInstallID: String
    var installedAt: Date
    var lastActiveDayKey: String?
    var recordedSevenDayRetention: Bool
    var recordedThirtyDayRetention: Bool

    init(
        id: String = "local-anonymous-profile",
        anonymousInstallID: String = UUID().uuidString,
        installedAt: Date = Date(),
        lastActiveDayKey: String? = nil,
        recordedSevenDayRetention: Bool = false,
        recordedThirtyDayRetention: Bool = false
    ) {
        self.id = id
        self.anonymousInstallID = anonymousInstallID
        self.installedAt = installedAt
        self.lastActiveDayKey = lastActiveDayKey
        self.recordedSevenDayRetention = recordedSevenDayRetention
        self.recordedThirtyDayRetention = recordedThirtyDayRetention
    }
}

@Model
final class ProductAnalyticsEvent {
    var id: UUID
    var name: String
    var occurredAt: Date
    var dayKey: String
    var sequenceID: String?
    var sequenceTitle: String?
    var value: Double?
    var details: String?

    init(
        name: ProductAnalyticsEventName,
        occurredAt: Date = Date(),
        dayKey: String,
        sequenceID: String? = nil,
        sequenceTitle: String? = nil,
        value: Double? = nil,
        details: String? = nil
    ) {
        self.id = UUID()
        self.name = name.rawValue
        self.occurredAt = occurredAt
        self.dayKey = dayKey
        self.sequenceID = sequenceID
        self.sequenceTitle = sequenceTitle
        self.value = value
        self.details = details
    }
}

enum ProductAnalyticsEventName: String {
    case dailyActiveUser = "daily_active_user"
    case practiceCompleted = "practice_completed"
    case favoriteFlowAdded = "favorite_flow_added"
    case favoriteFlowRemoved = "favorite_flow_removed"
    case retainedAfterSevenDays = "retained_after_7_days"
    case retainedAfterThirtyDays = "retained_after_30_days"
    case possibleCrash = "possible_crash"
}

enum ProductAnalyticsRetentionMilestone: Int, CaseIterable {
    case sevenDays = 7
    case thirtyDays = 30
}

enum ProductAnalytics {
    static let profileID = "local-anonymous-profile"

    private static let sessionWasCleanKey = "productAnalyticsSessionWasClean"
    private static let sessionStartedKey = "productAnalyticsSessionStarted"

    static func recordAppBecameActive(
        modelContext: ModelContext,
        now: Date = Date(),
        calendar: Calendar = .current
    ) {
        let profile = analyticsProfile(modelContext: modelContext, now: now)
        let key = dayKey(for: now, calendar: calendar)

        recordPossibleCrashIfNeeded(modelContext: modelContext, now: now, calendar: calendar)
        markSessionStarted()

        if profile.lastActiveDayKey != key {
            insertEvent(.dailyActiveUser, modelContext: modelContext, now: now, calendar: calendar)
            profile.lastActiveDayKey = key
        }

        let milestones = retentionMilestones(installedAt: profile.installedAt, activeAt: now, calendar: calendar)
        if milestones.contains(.sevenDays), !profile.recordedSevenDayRetention {
            insertEvent(.retainedAfterSevenDays, modelContext: modelContext, now: now, calendar: calendar)
            profile.recordedSevenDayRetention = true
        }
        if milestones.contains(.thirtyDays), !profile.recordedThirtyDayRetention {
            insertEvent(.retainedAfterThirtyDays, modelContext: modelContext, now: now, calendar: calendar)
            profile.recordedThirtyDayRetention = true
        }

        try? modelContext.save()
    }

    static func recordAppEnteredBackground() {
        UserDefaults.standard.set(true, forKey: sessionWasCleanKey)
    }

    static func recordPracticeCompleted(
        sequence: YogaSequence,
        modelContext: ModelContext,
        now: Date = Date(),
        calendar: Calendar = .current
    ) {
        insertEvent(
            .practiceCompleted,
            modelContext: modelContext,
            now: now,
            calendar: calendar,
            sequenceID: sequence.id,
            sequenceTitle: sequence.title,
            value: sequence.estimatedDuration,
            details: "rounds=\(sequence.rounds)"
        )
        try? modelContext.save()
    }

    static func recordFavoriteAdded(sequence: YogaSequence, modelContext: ModelContext) {
        recordFavorite(.favoriteFlowAdded, sequence: sequence, modelContext: modelContext)
    }

    static func recordFavoriteRemoved(sequence: YogaSequence, modelContext: ModelContext) {
        recordFavorite(.favoriteFlowRemoved, sequence: sequence, modelContext: modelContext)
    }

    static func dayKey(for date: Date, calendar: Calendar = .current) -> String {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        let year = components.year ?? 0
        let month = components.month ?? 0
        let day = components.day ?? 0
        return String(format: "%04d-%02d-%02d", year, month, day)
    }

    static func retentionMilestones(
        installedAt: Date,
        activeAt: Date,
        calendar: Calendar = .current
    ) -> Set<ProductAnalyticsRetentionMilestone> {
        let start = calendar.startOfDay(for: installedAt)
        let active = calendar.startOfDay(for: activeAt)
        let elapsedDays = calendar.dateComponents([.day], from: start, to: active).day ?? 0

        return Set(ProductAnalyticsRetentionMilestone.allCases.filter { elapsedDays >= $0.rawValue })
    }

    private static func recordFavorite(
        _ eventName: ProductAnalyticsEventName,
        sequence: YogaSequence,
        modelContext: ModelContext
    ) {
        insertEvent(
            eventName,
            modelContext: modelContext,
            sequenceID: sequence.id,
            sequenceTitle: sequence.title
        )
        try? modelContext.save()
    }

    private static func analyticsProfile(modelContext: ModelContext, now: Date) -> ProductAnalyticsProfile {
        let descriptor = FetchDescriptor<ProductAnalyticsProfile>(
            predicate: #Predicate { $0.id == profileID }
        )

        if let profile = try? modelContext.fetch(descriptor).first {
            return profile
        }

        let profile = ProductAnalyticsProfile(installedAt: now)
        modelContext.insert(profile)
        return profile
    }

    private static func recordPossibleCrashIfNeeded(
        modelContext: ModelContext,
        now: Date,
        calendar: Calendar
    ) {
        let sessionStarted = UserDefaults.standard.bool(forKey: sessionStartedKey)
        let sessionWasClean = UserDefaults.standard.bool(forKey: sessionWasCleanKey)
        guard sessionStarted, !sessionWasClean else { return }

        insertEvent(.possibleCrash, modelContext: modelContext, now: now, calendar: calendar)
    }

    private static func markSessionStarted() {
        UserDefaults.standard.set(true, forKey: sessionStartedKey)
        UserDefaults.standard.set(false, forKey: sessionWasCleanKey)
    }

    private static func insertEvent(
        _ name: ProductAnalyticsEventName,
        modelContext: ModelContext,
        now: Date = Date(),
        calendar: Calendar = .current,
        sequenceID: String? = nil,
        sequenceTitle: String? = nil,
        value: Double? = nil,
        details: String? = nil
    ) {
        modelContext.insert(
            ProductAnalyticsEvent(
                name: name,
                occurredAt: now,
                dayKey: dayKey(for: now, calendar: calendar),
                sequenceID: sequenceID,
                sequenceTitle: sequenceTitle,
                value: value,
                details: details
            )
        )
    }
}
