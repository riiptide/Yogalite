import SwiftUI

struct ProgramsView: View {
    @State private var path: [ProgramsRoute] = []
    private let programs = YogaProgramData.allPrograms

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                FlowDesign.background.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        header
                        programList
                    }
                    .padding(FlowDesign.spacing)
                    .padding(.bottom, 24)
                }
            }
            .navigationDestination(for: ProgramsRoute.self) { route in
                switch route {
                case .program(let id):
                    if let program = YogaProgramData.program(for: id) {
                        ProgramDetailView(program: program, endWorkoutAction: returnToProgramsRoot)
                    }
                }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Programs")
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(FlowDesign.text)
                .fixedSize(horizontal: false, vertical: true)

            Text("Follow a guided path")
                .font(.system(.largeTitle, design: .serif, weight: .bold))
                .foregroundStyle(FlowDesign.text)
                .fixedSize(horizontal: false, vertical: true)

            Text("Choose a multi-day pack and move through each flow in order.")
                .font(.body)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var programList: some View {
        VStack(spacing: 14) {
            ForEach(programs) { program in
                NavigationLink(value: ProgramsRoute.program(program.id)) {
                    ProgramCard(program: program)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func returnToProgramsRoot() {
        path.removeAll()
    }
}

private enum ProgramsRoute: Hashable {
    case program(String)
}

private struct ProgramCard: View {
    let program: YogaProgram

    var body: some View {
        HStack(spacing: 14) {
            PoseIllustrationView(pose: program.thumbnailPose)
                .frame(width: 58, height: 58)
                .background(FlowDesign.paleAqua)
                .clipShape(RoundedRectangle(cornerRadius: FlowDesign.cornerMedium, style: .continuous))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 8) {
                Text(program.title)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(FlowDesign.text)
                    .lineLimit(2)

                Text(program.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)

                HStack(spacing: 10) {
                    MetadataLabel(title: program.dayCountText, systemImage: "calendar")
                    MetadataLabel(title: "\(program.totalMinutes) min", systemImage: "clock")
                }
                .font(.caption)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Image(systemName: "chevron.right")
                .font(.headline.weight(.bold))
                .foregroundStyle(FlowDesign.teal)
        }
        .padding(18)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: FlowDesign.cornerLarge, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 16, x: 0, y: 8)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(program.title), \(program.dayCountText), \(program.totalMinutes) total minutes")
    }
}

private struct ProgramDetailView: View {
    let program: YogaProgram
    let endWorkoutAction: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            FlowDesign.background.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    header
                    flowList
                }
                .padding(FlowDesign.spacing)
                .padding(.bottom, 24)
            }
        }
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .navigationBar)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 18) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(FlowDesign.teal)
                    .frame(width: 44, height: 44)
                    .background(Color(.systemBackground).opacity(0.85))
                    .clipShape(Circle())
            }
            .accessibilityLabel("Back")

            VStack(alignment: .leading, spacing: 12) {
                Label(program.dayCountText, systemImage: program.systemImage)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(FlowDesign.teal)

                Text(program.title)
                    .font(.system(.largeTitle, design: .serif, weight: .bold))
                    .foregroundStyle(FlowDesign.text)
                    .fixedSize(horizontal: false, vertical: true)

                Text(program.subtitle)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 12) {
                    MetadataLabel(title: program.dayCountText, systemImage: "calendar")
                    MetadataLabel(title: "\(program.totalMinutes) min", systemImage: "clock")
                }
                .font(.subheadline)
            }
        }
    }

    private var flowList: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Program flows")
                .font(.headline.weight(.bold))
                .foregroundStyle(FlowDesign.text)

            ForEach(program.flows) { flow in
                ProgramFlowCard(flow: flow, endWorkoutAction: endWorkoutAction)
            }
        }
    }
}

private struct ProgramFlowCard: View {
    let flow: ProgramFlow
    let endWorkoutAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                VStack(spacing: 4) {
                    
                    Text("Day")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.secondary)
                    
                    Text("\(flow.day)")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(FlowDesign.teal)
                        .frame(width: 38, height: 38)
                        .background(FlowDesign.paleAqua)
                        .clipShape(Circle())

                    
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Day \(flow.day)")

                NavigationLink {
                    SequenceDetailView(sequence: flow.sequence, endWorkoutAction: endWorkoutAction)
                } label: {
                    SequenceCard(sequence: flow.sequence)
                }
                .buttonStyle(.plain)
            }

            NavigationLink {
                PracticePlayerView(
                    viewModel: PracticePlayerViewModel(sequence: flow.sequence),
                    endWorkoutAction: endWorkoutAction
                )
            } label: {
                Label("Start Practice", systemImage: "play.fill")
                    .font(.headline.weight(.bold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(FlowDesign.teal)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: FlowDesign.cornerLarge, style: .continuous))
            }
            .accessibilityLabel("Start day \(flow.day), \(flow.sequence.title)")
        }
    }
}

#Preview("Programs") {
    ProgramsView()
}

#Preview("Program Detail") {
    NavigationStack {
        ProgramDetailView(program: YogaProgramData.allPrograms[0], endWorkoutAction: {})
    }
}
