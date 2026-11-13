//
//  WeightPicker.swift
//  GustavWeights
//
//  Hold ADD WEIGHT and slide the finger up or down to pick a weight.
//  The step and range come from the exercise's history.
//

import SwiftUI
import GustavUICore

/// Values the hold-to-pick gesture can choose from for one exercise.
struct WeightPickerScale: Equatable {
    /// The range goes this far below and above the PR (20 %).
    static let rangeFraction = 0.2
    /// Sliding this far sideways cancels the pick.
    static let cancelDistance: CGFloat = 80
    /// Finger travel for the whole range, so any range fits on screen.
    private static let travelForWholeRange: CGFloat = 320

    let lower: Double
    let upper: Double
    let step: Double
    let start: Double
    let personalRecord: Double

    /// Nil when the exercise has no records yet, there is no PR to build a range around.
    init?(exercise: Exercise) {
        let values = exercise.weights.map(\.value)
        let pr = exercise.personalRecord
        guard pr > 0 else { return nil }

        let step = Self.step(for: values)
        let lower = max((pr * (1 - Self.rangeFraction) / step).rounded(.up) * step, 0)
        let upper = max((pr * (1 + Self.rangeFraction) / step).rounded(.down) * step, lower)
        // Start at the last logged weight: most sets are close to the previous one.
        let last = exercise.weights.max { $0.date < $1.date }?.value ?? pr

        self.step = step
        self.lower = Self.clean(lower)
        self.upper = Self.clean(upper)
        self.personalRecord = pr
        self.start = Self.clean(min(max((last / step).rounded() * step, lower), upper))
    }

    /// The coarsest step all logged values fit on: 1 kg when everything is in whole
    /// kilograms, 0.5 when there is e.g. 62.5, 0.25 for 61.25 and so on.
    static func step(for values: [Double]) -> Double {
        let candidates: [Double] = [1, 0.5, 0.25, 0.125, 0.1, 0.05]
        for candidate in candidates where values.allSatisfy({ isMultiple($0, of: candidate) }) {
            return candidate
        }
        return 0.01
    }

    private static func isMultiple(_ value: Double, of step: Double) -> Bool {
        let ratio = value / step
        return abs(ratio - ratio.rounded()) < 0.0001
    }

    /// Removes floating point noise like 82.50000000001.
    private static func clean(_ value: Double) -> Double {
        (value * 1000).rounded() / 1000
    }

    private var stepCount: Int {
        Int(((upper - lower) / step).rounded())
    }

    /// Points of vertical travel per step, between 3 and 24.
    private var pointsPerStep: CGFloat {
        guard stepCount > 0 else { return 24 }
        return min(max(Self.travelForWholeRange / CGFloat(stepCount), 3), 24)
    }

    /// Weight for a finger moved by `translation` since the pick started.
    /// Up means heavier.
    func value(for translation: CGSize) -> Double {
        let startIndex = Int(((start - lower) / step).rounded())
        let movedSteps = Int((-translation.height / pointsPerStep).rounded())
        let index = min(max(startIndex + movedSteps, 0), stepCount)
        return Self.clean(lower + Double(index) * step)
    }

    /// Position of `value` in the range, 0 = lower, 1 = upper.
    func fraction(of value: Double) -> Double {
        guard upper > lower else { return 0.5 }
        return min(max((value - lower) / (upper - lower), 0), 1)
    }

    static func isCancelled(_ translation: CGSize) -> Bool {
        abs(translation.width) > cancelDistance
    }
}

/// Full-screen preview of the weight being picked. Purely visual,
/// the finger keeps being tracked by the gesture on the ADD WEIGHT button.
struct WeightPickerOverlay: View {
    let exerciseName: String
    let scale: WeightPickerScale
    let translation: CGSize

    private let gaugeHeight: CGFloat = 240

    var body: some View {
        let value = scale.value(for: translation)
        let isCancelled = WeightPickerScale.isCancelled(translation)
        let isNewPR = value > scale.personalRecord

        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()

            HStack(alignment: .center, spacing: 24) {
                VStack(alignment: .leading, spacing: 12) {
                    Text(exerciseName.uppercased())
                        .font(.weightsBadge)
                        .opacity(0.6)

                    Text(value.formattedString(maxDecimalPlaces: 3))
                        .font(.exerciseTitle)
                        .minimumScaleFactor(0.01)
                        .lineLimit(1)
                        .frame(height: 140, alignment: .leading)
                        .contentTransition(.numericText(value: value))

                    Text("KG")
                        .font(.weightsValue)

                    if isNewPR {
                        Text("NEW PR!")
                            .font(.weightsBadge)
                            .foregroundStyle(Color.gustavWhite)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.gustavPink, in: Capsule())
                    } else {
                        Text("\(Int((value / scale.personalRecord * 100).rounded())) % OF PR")
                            .font(.bodyNumber)
                            .opacity(0.6)
                    }

                    Text(isCancelled
                         ? "RELEASE TO CANCEL"
                         : "SLIDE UP OR DOWN · RELEASE TO SAVE\nSLIDE SIDEWAYS TO CANCEL")
                        .font(.sectionFooter)
                        .opacity(0.6)
                        .padding(.top, 24)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                gauge(value: value)
            }
            .padding(30)
            .padding(.bottom, 120)
            .foregroundStyle(isCancelled ? Color.gustavNeutral : Color.gustavVolt)
        }
        .animation(.snappy(duration: 0.15), value: value)
        .animation(.easeInOut(duration: 0.15), value: isCancelled)
        .sensoryFeedback(.selection, trigger: value)
        .sensoryFeedback(.warning, trigger: isCancelled) { _, cancelled in cancelled }
    }

    /// Vertical track with the range limits, the PR mark and the picked value.
    private func gauge(value: Double) -> some View {
        VStack(spacing: 8) {
            Text(scale.upper.formattedString(maxDecimalPlaces: 3))
                .font(.chartLabel)
            ZStack(alignment: .bottom) {
                Capsule()
                    .fill(Color.gustavNeutral.opacity(0.5))
                    .frame(width: 8)
                Capsule()
                    .frame(width: 8, height: max(gaugeHeight * scale.fraction(of: value), 8))
                // PR mark
                Rectangle()
                    .fill(Color.gustavPink)
                    .frame(width: 24, height: 2)
                    .offset(y: -gaugeHeight * scale.fraction(of: scale.personalRecord))
            }
            .frame(width: 24, height: gaugeHeight)
            Text(scale.lower.formattedString(maxDecimalPlaces: 3))
                .font(.chartLabel)
        }
    }
}
