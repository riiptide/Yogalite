import SwiftUI

enum FlowDesign {
    static let background = Color(red: 0.98, green: 0.97, blue: 0.94)
    static let surface = Color(.secondarySystemBackground)
    static let text = Color(red: 0.08, green: 0.12, blue: 0.12)
    static let secondaryText = Color.secondary
    static let teal = Color(red: 0.0, green: 0.50, blue: 0.48)
    static let paleAqua = Color(red: 0.86, green: 0.95, blue: 0.94)
    static let softLine = Color.primary.opacity(0.10)

    static let cornerSmall: CGFloat = 10
    static let cornerMedium: CGFloat = 16
    static let cornerLarge: CGFloat = 26
    static let spacing: CGFloat = 20
}

extension TimeInterval {
    var secondsText: String {
        "\(Int(rounded()))s"
    }

    var minutesText: String {
        let minutes = max(1, Int((self / 60).rounded()))
        return "\(minutes) min"
    }
}
