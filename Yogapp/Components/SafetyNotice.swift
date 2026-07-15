import SwiftUI

struct SafetyNotice: View {
    var body: some View {
        Label {
            Text("Yogalite is for general wellness, not medical advice. Move gently, stop for pain or dizziness, and check with a professional when needed.")
                .font(.caption.weight(.semibold))
                .fixedSize(horizontal: false, vertical: true)
        } icon: {
            Image(systemName: "heart.text.square.fill")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(FlowDesign.teal)
        }
        .foregroundStyle(.secondary)
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground).opacity(0.88))
        .clipShape(RoundedRectangle(cornerRadius: FlowDesign.cornerMedium, style: .continuous))
        .accessibilityElement(children: .combine)
    }
}
