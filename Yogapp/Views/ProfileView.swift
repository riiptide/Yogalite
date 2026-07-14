import SwiftUI
import SwiftData

struct ProfileView: View {
    @Query(sort: \PracticeCompletionRecord.completedAt, order: .reverse) private var completionRecords: [PracticeCompletionRecord]

    private let goals = [
        ProfileGoal(title: "Morning", systemImage: "sun.max"),
        ProfileGoal(title: "Flexibility", systemImage: "figure.flexibility"),
        ProfileGoal(title: "Stress Relief", systemImage: "leaf"),
        ProfileGoal(title: "Beginner", systemImage: "figure.yoga")
    ]

    private let settings = [
        ProfileSetting(title: "Notifications", systemImage: "bell"),
        ProfileSetting(title: "Reminders", systemImage: "clock"),
        ProfileSetting(title: "Download flows", systemImage: "arrow.down.to.line"),
        ProfileSetting(title: "Help & Support", systemImage: "questionmark.circle")
    ]

    private var completedFlowsText: String {
        "\(completionRecords.count)"
    }

    private var minutesPracticedText: String {
        "\(completionRecords.totalMinutesPracticed)"
    }

    private var streakText: String {
        "\(completionRecords.dayStreak)"
    }

    private var latestCompletion: PracticeCompletionRecord? {
        completionRecords.first
    }

    var body: some View {
        NavigationStack {
            ZStack {
                FlowDesign.background.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 26) {
                        header
                        profileSummary
                        statsGrid
                        goalsSection
                        recentActivity
                        settingsSection
                    }
                    .padding(FlowDesign.spacing)
                    .padding(.bottom, 18)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private var header: some View {
        HStack(alignment: .center) {
            Text("Profile")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundStyle(FlowDesign.text)
                .lineLimit(1)
                .minimumScaleFactor(0.72)

            Spacer()

            Button {
            } label: {
                Image(systemName: "pencil")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(FlowDesign.teal)
                    .frame(width: 52, height: 52)
                    .background(Color(.systemBackground).opacity(0.90))
                    .clipShape(RoundedRectangle(cornerRadius: FlowDesign.cornerMedium, style: .continuous))
                    .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 6)
            }
            .accessibilityLabel("Edit profile")
        }
    }

    private var profileSummary: some View {
        HStack(spacing: 18) {
            ZStack {
                Circle()
                    .fill(FlowDesign.paleAqua.opacity(0.82))
                PoseIllustrationView(pose: SunSalutationData.upwardSalute)
                    .padding(18)
            }
            .frame(width: 118, height: 118)
            .overlay {
                Circle()
                    .stroke(Color(.systemBackground), lineWidth: 4)
            }
            .shadow(color: FlowDesign.teal.opacity(0.12), radius: 16, x: 0, y: 8)
            .accessibilityLabel("Profile avatar")

            VStack(alignment: .leading, spacing: 8) {
                Text("Aaliyah")
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(FlowDesign.text)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                HStack(spacing: 6) {
                    Text("Yoga journey in progress")
                    Image(systemName: "heart")
                        .foregroundStyle(FlowDesign.teal)
                }
                .font(.body)
                .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var statsGrid: some View {
        HStack(spacing: 12) {
            ProfileStatCard(value: streakText, title: "day streak", systemImage: "flame.fill")
            ProfileStatCard(value: completedFlowsText, title: "flows done", systemImage: "figure.yoga")
            ProfileStatCard(value: minutesPracticedText, title: "min practiced", systemImage: "clock.fill")
        }
    }

    private var goalsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionTitle("Your goals")

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(goals) { goal in
                        Label(goal.title, systemImage: goal.systemImage)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(FlowDesign.teal)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                            .background(FlowDesign.paleAqua.opacity(0.76))
                            .clipShape(Capsule())
                            .accessibilityLabel(goal.title)
                    }
                }
                .padding(.vertical, 2)
            }
            .padding(14)
            .background(Color(.systemBackground).opacity(0.90))
            .clipShape(RoundedRectangle(cornerRadius: FlowDesign.cornerLarge, style: .continuous))
        }
    }

    private var recentActivity: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionTitle("Recent activity")

            HStack(spacing: 14) {
                PoseIllustrationView(pose: recentActivityPose)
                    .frame(width: 92, height: 74)
                    .background(FlowDesign.paleAqua.opacity(0.70))
                    .clipShape(RoundedRectangle(cornerRadius: FlowDesign.cornerMedium, style: .continuous))

                VStack(alignment: .leading, spacing: 6) {
                    Text(recentActivityTitle)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(FlowDesign.text)
                        .lineLimit(2)
                    Text(recentActivitySubtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Button {
                } label: {
                    Image(systemName: "play.fill")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.white)
                        .frame(width: 48, height: 48)
                        .background(FlowDesign.teal)
                        .clipShape(Circle())
                }
                .accessibilityLabel("Replay Gentle Evening Flow")
            }
            .padding(16)
            .background(Color(.systemBackground).opacity(0.94))
            .clipShape(RoundedRectangle(cornerRadius: FlowDesign.cornerLarge, style: .continuous))
            .shadow(color: .black.opacity(0.05), radius: 14, x: 0, y: 8)
        }
    }

    private var recentActivityPose: Pose {
        guard let latestCompletion,
              let sequence = PracticePersistence.sequence(for: latestCompletion.sequenceID) else {
            return SunSalutationData.childPose
        }
        return sequence.steps.first?.startPose ?? SunSalutationData.mountain
    }

    private var recentActivityTitle: String {
        latestCompletion?.sequenceTitle ?? "No practices completed yet"
    }

    private var recentActivitySubtitle: String {
        guard let latestCompletion else {
            return "Finish a flow to build your history"
        }

        let dayText = Calendar.current.isDateInToday(latestCompletion.completedAt)
            ? "today"
            : latestCompletion.completedAt.formatted(date: .abbreviated, time: .omitted)
        return "Completed \(dayText) · \(latestCompletion.duration.minutesText)"
    }

    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionTitle("Settings")

            VStack(spacing: 0) {
                ForEach(settings) { setting in
                    ProfileSettingsRow(setting: setting)
                    if setting.id != settings.last?.id {
                        Divider()
                            .padding(.leading, 48)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color(.systemBackground).opacity(0.94))
            .clipShape(RoundedRectangle(cornerRadius: FlowDesign.cornerLarge, style: .continuous))
        }
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.title3.weight(.bold))
            .foregroundStyle(FlowDesign.text)
    }
}

private struct ProfileStatCard: View {
    let value: String
    let title: String
    let systemImage: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: systemImage)
                .font(.headline.weight(.bold))
                .foregroundStyle(FlowDesign.teal)
                .frame(width: 42, height: 42)
                .background(FlowDesign.paleAqua)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(FlowDesign.text)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color(.systemBackground).opacity(0.92))
        .clipShape(RoundedRectangle(cornerRadius: FlowDesign.cornerMedium, style: .continuous))
        .shadow(color: .black.opacity(0.04), radius: 12, x: 0, y: 6)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(value) \(title)")
    }
}

private struct ProfileSettingsRow: View {
    let setting: ProfileSetting

    var body: some View {
        Button {
        } label: {
            HStack(spacing: 14) {
                Image(systemName: setting.systemImage)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(FlowDesign.teal)
                    .frame(width: 32, height: 32)

                Text(setting.title)
                    .font(.body)
                    .foregroundStyle(FlowDesign.text)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 13)
        }
        .accessibilityLabel(setting.title)
    }
}

private struct ProfileGoal: Identifiable {
    let title: String
    let systemImage: String
    var id: String { title }
}

private struct ProfileSetting: Identifiable {
    let title: String
    let systemImage: String
    var id: String { title }
}

#Preview("Profile") {
    ProfileView()
}

#Preview("Profile Dark") {
    ProfileView()
        .preferredColorScheme(.dark)
}
