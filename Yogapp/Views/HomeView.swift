import SwiftUI

struct HomeView: View {
    private let sequences = SunSalutationData.allSequences
    @State private var path: [HomeRoute] = []

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                FlowDesign.background.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 26) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Ready to practice?")
                                .font(.largeTitle.weight(.bold))
                                .foregroundStyle(FlowDesign.text)
                            Text("A calm daily flow, built for steady breath and warm joints.")
                                .font(.body)
                                .foregroundStyle(.secondary)
                        }

                        VStack(spacing: 16) {
                            ForEach(sequences) { sequence in
                                NavigationLink(value: HomeRoute.sequence(sequence.id)) {
                                    SequenceCard(sequence: sequence)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(FlowDesign.spacing)
                }
            }
            .navigationTitle("Flow")
            .navigationDestination(for: HomeRoute.self) { route in
                switch route {
                case .sequence(let id):
                    let sequence = sequences.first { $0.id == id } ?? SunSalutationData.sunSalutationA
                    SequenceDetailView(sequence: sequence, endWorkoutAction: returnHome)
                }
            }
        }
    }

    private func returnHome() {
        path.removeAll()
    }
}

private enum HomeRoute: Hashable {
    case sequence(String)
}

#Preview("Home") {
    HomeView()
}

#Preview("Home Dark") {
    HomeView()
        .preferredColorScheme(.dark)
}
