import Foundation

struct ProductAnalyticsProfile: Codable {
    var id: String
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

struct ProductAnalyticsEvent: Codable {
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

    private static let profileStorageKey = "productAnalyticsProfile"
    private static let sessionWasCleanKey = "productAnalyticsSessionWasClean"
    private static let sessionStartedKey = "productAnalyticsSessionStarted"

    static func recordAppBecameActive(
        now: Date = Date(),
        calendar: Calendar = .current
    ) {
        var profile = analyticsProfile(now: now)
        let key = dayKey(for: now, calendar: calendar)

        recordPossibleCrashIfNeeded(now: now, calendar: calendar)
        markSessionStarted()

        if profile.lastActiveDayKey != key {
            appendEvent(.dailyActiveUser, now: now, calendar: calendar)
            profile.lastActiveDayKey = key
        }

        let milestones = retentionMilestones(installedAt: profile.installedAt, activeAt: now, calendar: calendar)
        if milestones.contains(.sevenDays), !profile.recordedSevenDayRetention {
            appendEvent(.retainedAfterSevenDays, now: now, calendar: calendar)
            profile.recordedSevenDayRetention = true
        }
        if milestones.contains(.thirtyDays), !profile.recordedThirtyDayRetention {
            appendEvent(.retainedAfterThirtyDays, now: now, calendar: calendar)
            profile.recordedThirtyDayRetention = true
        }

        saveProfile(profile)
    }

    static func recordAppEnteredBackground() {
        UserDefaults.standard.set(true, forKey: sessionWasCleanKey)
    }

    static func recordPracticeCompleted(
        sequence: YogaSequence,
        now: Date = Date(),
        calendar: Calendar = .current
    ) {
        appendEvent(
            .practiceCompleted,
            now: now,
            calendar: calendar,
            sequenceID: sequence.id,
            sequenceTitle: sequence.title,
            value: sequence.estimatedDuration,
            details: "rounds=\(sequence.rounds)"
        )
    }

    static func recordFavoriteAdded(sequence: YogaSequence) {
        recordFavorite(.favoriteFlowAdded, sequence: sequence)
    }

    static func recordFavoriteRemoved(sequence: YogaSequence) {
        recordFavorite(.favoriteFlowRemoved, sequence: sequence)
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
        sequence: YogaSequence
    ) {
        appendEvent(
            eventName,
            sequenceID: sequence.id,
            sequenceTitle: sequence.title
        )
    }

    private static func analyticsProfile(now: Date) -> ProductAnalyticsProfile {
        if let data = UserDefaults.standard.data(forKey: profileStorageKey),
           let profile = try? JSONDecoder().decode(ProductAnalyticsProfile.self, from: data) {
            return profile
        }

        return ProductAnalyticsProfile(installedAt: now)
    }

    private static func saveProfile(_ profile: ProductAnalyticsProfile) {
        guard let data = try? JSONEncoder().encode(profile) else { return }
        UserDefaults.standard.set(data, forKey: profileStorageKey)
    }

    private static func recordPossibleCrashIfNeeded(
        now: Date,
        calendar: Calendar
    ) {
        let sessionStarted = UserDefaults.standard.bool(forKey: sessionStartedKey)
        let sessionWasClean = UserDefaults.standard.bool(forKey: sessionWasCleanKey)
        guard sessionStarted, !sessionWasClean else { return }

        appendEvent(.possibleCrash, now: now, calendar: calendar)
    }

    private static func markSessionStarted() {
        UserDefaults.standard.set(true, forKey: sessionStartedKey)
        UserDefaults.standard.set(false, forKey: sessionWasCleanKey)
    }

    private static func appendEvent(
        _ name: ProductAnalyticsEventName,
        now: Date = Date(),
        calendar: Calendar = .current,
        sequenceID: String? = nil,
        sequenceTitle: String? = nil,
        value: Double? = nil,
        details: String? = nil
    ) {
        let event = ProductAnalyticsEvent(
            name: name,
            occurredAt: now,
            dayKey: dayKey(for: now, calendar: calendar),
            sequenceID: sequenceID,
            sequenceTitle: sequenceTitle,
            value: value,
            details: details
        )
        guard let data = try? JSONEncoder().encode(event) else { return }

        let fileURL = analyticsEventsURL()
        try? FileManager.default.createDirectory(
            at: fileURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )

        if FileManager.default.fileExists(atPath: fileURL.path),
           let handle = try? FileHandle(forWritingTo: fileURL) {
            defer { try? handle.close() }
            try? handle.seekToEnd()
            try? handle.write(contentsOf: data)
            try? handle.write(contentsOf: Data("\n".utf8))
        } else {
            var line = data
            line.append(Data("\n".utf8))
            try? line.write(to: fileURL, options: .atomic)
        }
    }

    private static func analyticsEventsURL() -> URL {
        let baseURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        return baseURL
            .appendingPathComponent("Yogalite", isDirectory: true)
            .appendingPathComponent("product-analytics.jsonl")
    }
}
