import SwiftUI

struct MetadataLabel: View {
    let title: String
    let systemImage: String

    var body: some View {
        Label(title, systemImage: systemImage)
            .font(.caption.weight(.semibold))
            .foregroundStyle(FlowDesign.secondaryText)
            .labelStyle(.titleAndIcon)
            .lineLimit(1)
            .minimumScaleFactor(0.82)
            .accessibilityElement(children: .combine)
    }
}

#Preview {
    MetadataLabel(title: "Beginner", systemImage: "chart.bar")
        .padding()
}
