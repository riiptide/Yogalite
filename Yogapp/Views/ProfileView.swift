import SwiftUI
import SwiftData
import PhotosUI
import UIKit

struct ProfileView: View {
    @Query(sort: \PracticeCompletionRecord.completedAt, order: .reverse) private var completionRecords: [PracticeCompletionRecord]
    @AppStorage("profileDisplayName") private var displayName = "Aaliyah"
    @AppStorage("selectedPracticeTags") private var selectedPracticeTags = ""
    @AppStorage("profilePhotoData") private var profilePhotoData = Data()
    @State private var isEditingName = false
    @State private var draftDisplayName = ""
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var photoToCrop: ProfilePhotoCropItem?

    private var goals: [ProfileGoal] {
        let selectedGoals = Set(OnboardingPreferences.decodeTags(selectedPracticeTags))
        return OnboardingPreferences.interestTags.compactMap { tag in
            selectedGoals.contains(tag) ? ProfileGoal(title: tag) : nil
        }
    }

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

    private var recentActivitySequence: YogaSequence? {
        guard let latestCompletion else { return nil }
        return PracticePersistence.sequence(for: latestCompletion.sequenceID)
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
                        profileLinks
                    }
                    .padding(FlowDesign.spacing)
                    .padding(.bottom, 18)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $isEditingName) {
                EditProfileNameSheet(name: $draftDisplayName) {
                    saveDisplayName()
                }
                .presentationDetents([.height(250)])
            }
            .sheet(item: $photoToCrop) { cropItem in
                ProfilePhotoCropSheet(image: cropItem.image) { croppedData in
                    profilePhotoData = croppedData
                    photoToCrop = nil
                } cancel: {
                    photoToCrop = nil
                }
            }
            .onChange(of: selectedPhotoItem) { _, newItem in
                Task {
                    await loadProfilePhoto(from: newItem)
                }
            }
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
                draftDisplayName = displayName
                isEditingName = true
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
        let avatarData = profilePhotoData

        return HStack(spacing: 18) {
            PhotosPicker(selection: $selectedPhotoItem, matching: .images, photoLibrary: .shared()) {
                ProfileAvatar(photoData: avatarData)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Profile avatar")
            .accessibilityHint("Choose a profile photo")

            VStack(alignment: .leading, spacing: 8) {
                Text(displayName)
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

            Group {
                if goals.isEmpty {
                    Text("Choose goals during onboarding to personalize recommendations.")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    FlowLayout(spacing: 10) {
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
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(14)
            .background(Color(.systemBackground).opacity(0.90))
            .clipShape(RoundedRectangle(cornerRadius: FlowDesign.cornerLarge, style: .continuous))
        }
    }

    private func loadProfilePhoto(from item: PhotosPickerItem?) async {
        guard let item,
              let data = try? await item.loadTransferable(type: Data.self),
              let image = UIImage(data: data)?.normalizedForCropping() else {
            return
        }

        await MainActor.run {
            photoToCrop = ProfilePhotoCropItem(image: image)
            selectedPhotoItem = nil
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

                if let recentActivitySequence {
                    NavigationLink {
                        PracticePlayerView(viewModel: PracticePlayerViewModel(sequence: recentActivitySequence))
                    } label: {
                        recentActivityPlayIcon(isEnabled: true)
                    }
                    .accessibilityLabel("Replay \(recentActivitySequence.title)")
                } else {
                    Button {} label: {
                        recentActivityPlayIcon(isEnabled: false)
                    }
                    .disabled(true)
                    .accessibilityLabel("Replay unavailable")
                    .accessibilityHint("Complete a practice to enable replay")
                }
            }
            .padding(16)
            .background(Color(.systemBackground).opacity(0.94))
            .clipShape(RoundedRectangle(cornerRadius: FlowDesign.cornerLarge, style: .continuous))
            .shadow(color: .black.opacity(0.05), radius: 14, x: 0, y: 8)
        }
    }

    private var recentActivityPose: Pose {
        guard let sequence = recentActivitySequence else {
            return SunSalutationData.childPose
        }
        return sequence.steps.first?.startPose ?? SunSalutationData.mountain
    }

    private func recentActivityPlayIcon(isEnabled: Bool) -> some View {
        Image(systemName: "play.fill")
            .font(.headline.weight(.bold))
            .foregroundStyle(isEnabled ? .white : FlowDesign.secondaryText.opacity(0.55))
            .frame(width: 48, height: 48)
            .background(isEnabled ? FlowDesign.teal : FlowDesign.softLine.opacity(0.70))
            .opacity(isEnabled ? 1 : 0.62)
            .clipShape(Circle())
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

    private var privacyPolicyLink: some View {
        Link(destination: URL(string: "https://splendorous-cobbler-3fd633.netlify.app/")!) {
            Label("Privacy Policy", systemImage: "lock.shield")
                .profileLinkStyle()
        }
        .accessibilityHint("Opens the Yogalite privacy policy")
    }

    private var supportLink: some View {
        Link(destination: URL(string: "https://papaya-buttercream-fe4631.netlify.app/")!) {
            Label("Support", systemImage: "questionmark.circle")
                .profileLinkStyle()
        }
        .accessibilityHint("Opens Yogalite support")
    }

    private var profileLinks: some View {
        VStack(spacing: 10) {
            privacyPolicyLink
            supportLink
        }
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.title3.weight(.bold))
            .foregroundStyle(FlowDesign.text)
    }

    private func saveDisplayName() {
        let trimmedName = draftDisplayName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        displayName = trimmedName
        isEditingName = false
    }
}

private struct ProfileAvatar: View {
    let photoData: Data

    private var profileUIImage: UIImage? {
        guard !photoData.isEmpty else { return nil }
        return UIImage(data: photoData)
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ZStack {
                Circle()
                    .fill(FlowDesign.paleAqua.opacity(0.82))

                if let profileUIImage {
                    Image(uiImage: profileUIImage)
                        .resizable()
                        .scaledToFill()
                } else {
                    PoseIllustrationView(pose: SunSalutationData.upwardSalute)
                        .padding(18)
                }
            }
            .frame(width: 118, height: 118)
            .clipShape(Circle())
            .overlay {
                Circle()
                    .stroke(Color(.systemBackground), lineWidth: 4)
            }
            .shadow(color: FlowDesign.teal.opacity(0.12), radius: 16, x: 0, y: 8)

            Image(systemName: "camera.fill")
                .font(.caption.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 30, height: 30)
                .background(FlowDesign.teal)
                .clipShape(Circle())
                .overlay {
                    Circle()
                        .stroke(Color(.systemBackground), lineWidth: 2)
                }
                .offset(x: -4, y: -4)
        }
    }
}

private struct ProfilePhotoCropItem: Identifiable {
    let id = UUID()
    let image: UIImage
}

private struct ProfilePhotoCropSheet: View {
    let image: UIImage
    let save: (Data) -> Void
    let cancel: () -> Void
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var scale: CGFloat = 1
    @State private var lastScale: CGFloat = 1
    @State private var currentCropSide: CGFloat = 512

    private let outputSideLength: CGFloat = 512
    private let minimumScale: CGFloat = 1
    private let maximumScale: CGFloat = 4

    var body: some View {
        NavigationStack {
            VStack(spacing: 22) {
                Text("Move and pinch to crop your profile photo.")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                GeometryReader { proxy in
                    let cropSide = min(proxy.size.width, proxy.size.height)

                    ZStack {
                        Color.black.opacity(0.06)

                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .scaleEffect(scale)
                            .offset(offset)
                            .frame(width: cropSide, height: cropSide)
                            .clipShape(Rectangle())
                            .gesture(cropGesture(cropSide: cropSide))

                        Circle()
                            .stroke(Color.white, lineWidth: 3)
                            .shadow(color: .black.opacity(0.24), radius: 6, x: 0, y: 2)
                            .padding(1.5)
                            .allowsHitTesting(false)

                        RoundedRectangle(cornerRadius: FlowDesign.cornerMedium, style: .continuous)
                            .stroke(FlowDesign.teal.opacity(0.34), lineWidth: 2)
                            .allowsHitTesting(false)
                    }
                    .frame(width: cropSide, height: cropSide)
                    .clipShape(RoundedRectangle(cornerRadius: FlowDesign.cornerMedium, style: .continuous))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .onAppear {
                        currentCropSide = cropSide
                        clampOffset(for: cropSide)
                    }
                    .onChange(of: cropSide) { _, newCropSide in
                        currentCropSide = newCropSide
                        clampOffset(for: newCropSide)
                    }
                    .onChange(of: scale) { _, _ in
                        clampOffset(for: cropSide)
                    }
                }
                .aspectRatio(1, contentMode: .fit)

                Button {
                    resetCrop()
                } label: {
                    Label("Reset crop", systemImage: "arrow.counterclockwise")
                        .font(.subheadline.weight(.bold))
                }
                .foregroundStyle(FlowDesign.teal)
            }
            .padding(FlowDesign.spacing)
            .background(FlowDesign.background.ignoresSafeArea())
            .navigationTitle("Crop photo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: cancel)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if let croppedData = croppedPhotoData() {
                            save(croppedData)
                        }
                    }
                    .fontWeight(.bold)
                }
            }
        }
    }

    private func cropGesture(cropSide: CGFloat) -> some Gesture {
        SimultaneousGesture(
            DragGesture()
                .onChanged { value in
                    offset = clampedOffset(
                        CGSize(width: lastOffset.width + value.translation.width, height: lastOffset.height + value.translation.height),
                        cropSide: cropSide,
                        scale: scale
                    )
                }
                .onEnded { _ in
                    offset = clampedOffset(offset, cropSide: cropSide, scale: scale)
                    lastOffset = offset
                },
            MagnificationGesture()
                .onChanged { value in
                    scale = min(max(lastScale * value, minimumScale), maximumScale)
                    offset = clampedOffset(offset, cropSide: cropSide, scale: scale)
                }
                .onEnded { _ in
                    scale = min(max(scale, minimumScale), maximumScale)
                    offset = clampedOffset(offset, cropSide: cropSide, scale: scale)
                    lastScale = scale
                    lastOffset = offset
                }
        )
    }

    private func resetCrop() {
        withAnimation(.snappy) {
            offset = .zero
            lastOffset = .zero
            scale = 1
            lastScale = 1
        }
    }

    private func clampOffset(for cropSide: CGFloat) {
        offset = clampedOffset(offset, cropSide: cropSide, scale: scale)
        lastOffset = offset
    }

    private func clampedOffset(_ proposedOffset: CGSize, cropSide: CGFloat, scale: CGFloat) -> CGSize {
        let displaySize = displayedImageSize(for: cropSide, scale: scale)
        let horizontalLimit = max((displaySize.width - cropSide) / 2, 0)
        let verticalLimit = max((displaySize.height - cropSide) / 2, 0)

        return CGSize(
            width: min(max(proposedOffset.width, -horizontalLimit), horizontalLimit),
            height: min(max(proposedOffset.height, -verticalLimit), verticalLimit)
        )
    }

    private func croppedPhotoData() -> Data? {
        ProfilePhotoProcessor.preparedImageData(
            from: image,
            cropRect: cropRect(for: currentCropSide),
            sideLength: outputSideLength
        )
    }

    private func cropRect(for cropSide: CGFloat) -> CGRect {
        let displaySize = displayedImageSize(for: cropSide, scale: scale)
        let imageScale = displaySize.width / image.size.width
        let originX = ((displaySize.width - cropSide) / 2 - offset.width) / imageScale
        let originY = ((displaySize.height - cropSide) / 2 - offset.height) / imageScale
        let sideLength = cropSide / imageScale

        return CGRect(
            x: min(max(originX, 0), image.size.width - sideLength),
            y: min(max(originY, 0), image.size.height - sideLength),
            width: sideLength,
            height: sideLength
        )
    }

    private func displayedImageSize(for cropSide: CGFloat, scale: CGFloat) -> CGSize {
        let baseScale = max(cropSide / image.size.width, cropSide / image.size.height)
        return CGSize(width: image.size.width * baseScale * scale, height: image.size.height * baseScale * scale)
    }
}

private struct EditProfileNameSheet: View {
    @Binding var name: String
    let save: () -> Void
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isNameFocused: Bool

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("Name")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(FlowDesign.text)

                TextField("Your name", text: $name)
                    .font(.title3.weight(.semibold))
                    .textInputAutocapitalization(.words)
                    .submitLabel(.done)
                    .focused($isNameFocused)
                    .padding(14)
                    .background(FlowDesign.paleAqua.opacity(0.52))
                    .clipShape(RoundedRectangle(cornerRadius: FlowDesign.cornerMedium, style: .continuous))
                    .onSubmit {
                        if canSave {
                            save()
                        }
                    }

                Spacer()
            }
            .padding(FlowDesign.spacing)
            .navigationTitle("Edit profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: save)
                        .fontWeight(.bold)
                        .disabled(!canSave)
                }
            }
            .onAppear {
                isNameFocused = true
            }
        }
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

private struct ProfileGoal: Identifiable {
    let title: String
    var systemImage: String {
        switch title {
        case "Morning":
            return "sun.max"
        case "Evening":
            return "sunset"
        case "Stress Relief":
            return "leaf"
        case "Better Sleep":
            return "moon.stars"
        case "Strength":
            return "flame"
        case "Flexibility":
            return "figure.flexibility"
        case "Mobility":
            return "figure.walk.motion"
        case "Balance":
            return "figure.yoga"
        case "Core":
            return "figure.core.training"
        case "Hips", "Hamstrings":
            return "figure.strengthtraining.functional"
        case "Back Care":
            return "figure.cooldown"
        case "Beginner":
            return "sparkles"
        case "Quick Practices":
            return "timer"
        case "Restorative":
            return "heart"
        default:
            return "tag"
        }
    }
    var id: String { title }
}

private enum ProfilePhotoProcessor {
    static func preparedImageData(from image: UIImage, cropRect: CGRect, sideLength: CGFloat = 512) -> Data? {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: sideLength, height: sideLength))
        let resizedImage = renderer.image { _ in
            let drawScale = sideLength / cropRect.width
            image.draw(
                in: CGRect(
                    x: -cropRect.minX * drawScale,
                    y: -cropRect.minY * drawScale,
                    width: image.size.width * drawScale,
                    height: image.size.height * drawScale
                )
            )
        }

        return resizedImage.jpegData(compressionQuality: 0.82)
    }
}

private extension View {
    func profileLinkStyle() -> some View {
        self
            .font(.subheadline.weight(.bold))
            .foregroundStyle(FlowDesign.teal)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color(.systemBackground).opacity(0.90))
            .clipShape(RoundedRectangle(cornerRadius: FlowDesign.cornerMedium, style: .continuous))
    }
}

private extension UIImage {
    func normalizedForCropping() -> UIImage {
        guard imageOrientation != .up else { return self }

        let format = UIGraphicsImageRendererFormat.default()
        format.scale = scale
        let renderer = UIGraphicsImageRenderer(size: size, format: format)

        return renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}

#Preview("Profile") {
    ProfileView()
}

#Preview("Profile Dark") {
    ProfileView()
        .preferredColorScheme(.dark)
}
