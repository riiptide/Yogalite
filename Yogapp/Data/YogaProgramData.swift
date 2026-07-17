import Foundation

struct YogaProgram: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let systemImage: String
    let flows: [ProgramFlow]

    var dayCountText: String {
        flows.count == 1 ? "1 day" : "\(flows.count) days"
    }

    var totalMinutes: Int {
        flows.reduce(0) { $0 + $1.sequence.estimatedMinutes }
    }

    var thumbnailPose: Pose {
        let poses = flows.reduce(into: [Pose]()) { poses, flow in
            let pose = flow.sequence.thumbnailPose
            guard !poses.contains(where: { $0.id == pose.id }) else { return }
            poses.append(pose)
        }

        guard !poses.isEmpty else {
            return SunSalutationData.mountain
        }

        let seed = id.unicodeScalars.reduce(0) { $0 + Int($1.value) }
        return poses[seed % poses.count]
    }
}

struct ProgramFlow: Identifiable {
    let day: Int
    let sequence: YogaSequence

    var id: String {
        "\(day)-\(sequence.id)"
    }
}

enum YogaProgramData {
    static let allPrograms: [YogaProgram] = [
        YogaProgram(
            id: "seven-day-intro-to-yoga",
            title: "7-Day Intro to Yoga",
            subtitle: "A gentle first week that builds comfort with foundational poses.",
            systemImage: "sparkles",
            flows: days([
                SunSalutationData.fiveMinuteWakeUpStretch,
                SunSalutationData.quickMorningMobility,
                SunSalutationData.gentleSunSalutationFlow,
                SunSalutationData.beginnerBalanceFlow,
                SunSalutationData.beginnerCoreFoundations,
                SunSalutationData.fullBodyBeginnerFlow,
                SunSalutationData.gentleRecoveryFlow
            ])
        ),
        YogaProgram(
            id: "seven-day-power-yoga",
            title: "7-Day Power Yoga",
            subtitle: "A stronger week for heat, core, balance, and full-body stamina.",
            systemImage: "flame",
            flows: days([
                SunSalutationData.standingStrengthFlow,
                SunSalutationData.coreStrengthFlow,
                SunSalutationData.gluteLegStrengthFlow,
                SunSalutationData.balanceAndStabilityFlow,
                SunSalutationData.armBalancePreparationFlow,
                SunSalutationData.powerVinyasaFlow,
                SunSalutationData.completeThirtyMinutePractice
            ])
        ),
        YogaProgram(
            id: "ten-day-morning-sunrise-pack",
            title: "10-Day Morning Sunrise Pack",
            subtitle: "A bright morning path from quick mobility to a full weekend practice.",
            systemImage: "sun.max",
            flows: days([
                SunSalutationData.fiveMinuteWakeUpStretch,
                SunSalutationData.sunriseMobilityFlow,
                SunSalutationData.quickMorningMobility,
                SunSalutationData.beginnerMorningFlow,
                SunSalutationData.gentleSunSalutationFlow,
                SunSalutationData.morningEnergyBuilder,
                SunSalutationData.dailyBeginnerFlow,
                SunSalutationData.morningCoreActivation,
                SunSalutationData.energizingMorningFlow,
                SunSalutationData.weekendMorningPractice
            ])
        ),
        YogaProgram(
            id: "ten-day-evening-wind-down-pack",
            title: "10-Day Evening Wind-Down Pack",
            subtitle: "A calming evening progression for hips, spine, sleep, and rest.",
            systemImage: "moon.stars",
            flows: days([
                SunSalutationData.fiveMinuteEveningReset,
                SunSalutationData.calmAfterWork,
                SunSalutationData.bedtimeStretch,
                SunSalutationData.unwindYourHips,
                SunSalutationData.gentleSpineRelease,
                SunSalutationData.calmBodyCalmMind,
                SunSalutationData.eveningRecoveryFlow,
                SunSalutationData.fullBodyEveningStretch,
                SunSalutationData.restoreAndRecharge,
                SunSalutationData.longEveningWindDown
            ])
        ),
        YogaProgram(
            id: "fifteen-day-yoga-mind",
            title: "15-Day Yoga Mind",
            subtitle: "A quiet path for stress relief, posture, recovery, and deep rest.",
            systemImage: "leaf",
            flows: days([
                SunSalutationData.fiveMinuteCalmReset,
                SunSalutationData.gentleMoonFlow,
                SunSalutationData.stressReliefFlow,
                SunSalutationData.calmAfterWork,
                SunSalutationData.tenMinuteBedtimeFlow,
                SunSalutationData.gentleRecoveryFlow,
                SunSalutationData.wristFreeFloorFlow,
                SunSalutationData.postureUpperBackFlow,
                SunSalutationData.twistingFlow,
                SunSalutationData.calmBodyCalmMind,
                SunSalutationData.kneeFriendlyGentleFlow,
                SunSalutationData.restorativeWindDown,
                SunSalutationData.eveningRecoveryFlow,
                SunSalutationData.restoreAndRecharge,
                SunSalutationData.longEveningWindDown
            ])
        ),
        YogaProgram(
            id: "thirty-day-yoga-glow",
            title: "30-Day Yoga Glow",
            subtitle: "A month-long progression from beginner foundations to energizing strength.",
            systemImage: "calendar.badge.checkmark",
            flows: days([
                SunSalutationData.fiveMinuteWakeUpStretch,
                SunSalutationData.sunriseMobilityFlow,
                SunSalutationData.gentleSunSalutationFlow,
                SunSalutationData.beginnerMorningFlow,
                SunSalutationData.beginnerCoreFoundations,
                SunSalutationData.beginnerBalanceFlow,
                SunSalutationData.gentleRecoveryFlow,
                SunSalutationData.fullBodyBeginnerFlow,
                SunSalutationData.morningEnergyBuilder,
                SunSalutationData.hipOpeningFlow,
                SunSalutationData.postureUpperBackFlow,
                SunSalutationData.standingConfidenceFlow,
                SunSalutationData.dailyBeginnerFlow,
                SunSalutationData.restorativeWindDown,
                SunSalutationData.sunSalutationA,
                SunSalutationData.lowerBodyMobilityFlow,
                SunSalutationData.morningCoreActivation,
                SunSalutationData.hamstringFlow,
                SunSalutationData.beginnerMorningStrength,
                SunSalutationData.balanceAndStabilityFlow,
                SunSalutationData.stressReliefFlow,
                SunSalutationData.sunSalutationB,
                SunSalutationData.standingStrengthFlow,
                SunSalutationData.gluteLegStrengthFlow,
                SunSalutationData.shoulderChestOpeningFlow,
                SunSalutationData.energizingMorningFlow,
                SunSalutationData.halfMoonPeakFlow,
                SunSalutationData.slowFullBodyFlow,
                SunSalutationData.powerVinyasaFlow,
                SunSalutationData.completeThirtyMinutePractice
            ])
        ),
        YogaProgram(
            id: "seven-day-yin-yoga",
            title: "7-Day Yin Yoga",
            subtitle: "A slow, floor-based week for deep release and evening calm.",
            systemImage: "circle.lefthalf.filled",
            flows: days([
                SunSalutationData.fiveMinuteCalmReset,
                SunSalutationData.unwindYourHips,
                SunSalutationData.wristFreeFloorFlow,
                SunSalutationData.bedtimeStretch,
                SunSalutationData.restorativeWindDown,
                SunSalutationData.restoreAndRecharge,
                SunSalutationData.longEveningWindDown
            ])
        )
    ]

    static func program(for id: String) -> YogaProgram? {
        allPrograms.first { $0.id == id }
    }

    private static func days(_ sequences: [YogaSequence]) -> [ProgramFlow] {
        sequences.enumerated().map { index, sequence in
            ProgramFlow(day: index + 1, sequence: sequence)
        }
    }
}
