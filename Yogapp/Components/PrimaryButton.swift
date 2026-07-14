import SwiftUI

struct PrimaryButton: View {
    let title: String
    let systemImage: String?
    let action: () -> Void

    init(_ title: String, systemImage: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.systemImage = systemImage
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: systemImage ?? "play.fill")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 17)
                .background(FlowDesign.teal)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: FlowDesign.cornerLarge, style: .continuous))
        }
        .accessibilityLabel(title)
    }
}

#Preview {
    PrimaryButton("Start Practice", systemImage: "play.fill") {}
        .padding()
}
