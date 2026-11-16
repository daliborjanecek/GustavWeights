//
//  ControlButton.swift
//  GustavWeights
//
//  Large control button in the same style as the GustavTimer controls:
//  a pill of GustavLayout.controlHeight, tinted glass on iOS 26,
//  a solid capsule on older systems.
//

import SwiftUI
import GustavUICore

/// Big button for the main screen. Either a text label with an optional
/// description, or an SF Symbol icon (for the narrow secondary button).
///
///     ControlButton(label: "ADD WEIGHT", description: "Squat", action: addWeight)
///     ControlButton(systemImage: "chart.bar.xaxis", accessibilityLabel: "Detail",
///                   color: .gustavNeutral, action: showDetail)
struct ControlButton: View {

    private enum Content {
        case text(label: LocalizedStringKey, description: String?)
        case icon(systemImage: String, accessibilityLabel: LocalizedStringKey)
    }

    private let content: Content
    private let color: Color
    private let action: () -> Void

    init(label: LocalizedStringKey, description: String? = nil, color: Color = .gustavVolt, action: @escaping () -> Void) {
        self.content = .text(label: label, description: description)
        self.color = color
        self.action = action
    }

    init(systemImage: String, accessibilityLabel: LocalizedStringKey, color: Color = .gustavVolt, action: @escaping () -> Void) {
        self.content = .icon(systemImage: systemImage, accessibilityLabel: accessibilityLabel)
        self.color = color
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            switch content {
            case .text(let label, let description):
                ControlButtonLabel(label: label, description: description, color: color)
            case .icon(let systemImage, let accessibilityLabel):
                iconLabel(systemImage)
                    .accessibilityLabel(accessibilityLabel)
            }
        }
        .buttonStyle(.plain)
    }

    /// Volt surface gets dark text, any other surface volt text (as in GustavTimer).
    private var foreground: Color {
        color == .gustavVolt ? .gustavNeutral : .gustavVolt
    }

    private func iconLabel(_ systemImage: String) -> some View {
        Image(systemName: systemImage)
            .font(.system(size: 28, weight: .medium))
            .foregroundStyle(foreground)
            .frame(height: GustavLayout.controlHeight)
            .frame(maxWidth: .infinity)
            .controlSurface(color)
    }
}

/// Look of a text ControlButton without the Button itself.
struct ControlButtonLabel: View {
    let label: LocalizedStringKey
    var description: String? = nil
    var color: Color = .gustavVolt

    var body: some View {
        HStack {
            Text(label)
                .font(.buttonLabel)
            if let description {
                Text(verbatim: description)
                    .font(.buttonDescription)
                    .textCase(.uppercase)
                    .opacity(0.5)
            }
        }
        .lineLimit(1)
        .minimumScaleFactor(0.6)
        .padding(.horizontal, 24)
        .foregroundStyle(color == .gustavVolt ? Color.gustavNeutral : Color.gustavVolt)
        .frame(height: GustavLayout.controlHeight)
        .frame(maxWidth: .infinity)
        .controlSurface(color)
    }
}

private extension View {
    /// Button surface: tinted glass on iOS 26, otherwise a solid pill.
    @ViewBuilder
    func controlSurface(_ color: Color) -> some View {
        if #available(iOS 26.0, *) {
            self
                .glassEffect(.regular.tint(color).interactive())
                .contentShape(Rectangle())
        } else {
            self
                .background(color)
                .clipShape(Capsule())
                .contentShape(Rectangle())
        }
    }
}

#Preview {
    HStack(spacing: 16) {
        ControlButton(label: "ADD WEIGHT", description: "Bench press", action: {})
        ControlButton(systemImage: "chart.bar.xaxis", accessibilityLabel: "Detail", color: .gustavNeutral, action: {})
            .frame(width: 100)
    }
    .padding()
    .background(.black)
}
