//
//  ExerciseUnit.swift
//  GustavWeights
//
//  What the numbers of an exercise mean: a weight, a number of
//  repetitions (e.g. pull-ups) or a time.
//

import SwiftUI

enum ExerciseUnit: String, CaseIterable, Identifiable {
    case kilograms = "kg"
    case pounds = "lb"
    case reps
    case seconds = "s"

    var id: String { rawValue }

    /// Short unit shown after values, e.g. "kg" or "reps".
    var symbol: String {
        switch self {
        case .kilograms: "kg"
        case .pounds: "lb"
        case .reps: "reps"
        case .seconds: "s"
        }
    }

    /// Label of the unit picker.
    var pickerTitle: LocalizedStringKey {
        switch self {
        case .kilograms: "KG"
        case .pounds: "LB"
        case .reps: "REPS"
        case .seconds: "SEC"
        }
    }

    /// Repetitions are whole numbers, everything else may have decimals.
    var allowsDecimals: Bool {
        self != .reps
    }

    /// Label of the main button on the main screen.
    var addButtonLabel: LocalizedStringKey {
        switch self {
        case .kilograms, .pounds: "ADD WEIGHT"
        case .reps: "ADD REPS"
        case .seconds: "ADD TIME"
        }
    }

    /// Title of the alert for logging a value.
    var addTitle: LocalizedStringKey {
        switch self {
        case .kilograms, .pounds: "Add weight"
        case .reps: "Add reps"
        case .seconds: "Add time"
        }
    }

    /// Placeholder of the number field.
    var fieldPrompt: LocalizedStringKey {
        switch self {
        case .kilograms: "Weight in kg"
        case .pounds: "Weight in lb"
        case .reps: "Number of reps"
        case .seconds: "Time in seconds"
        }
    }

    /// "100 kg", "12 reps", "45 s".
    func format(_ value: Double) -> String {
        "\(value.formattedString(maxDecimalPlaces: 2)) \(symbol)"
    }

    /// Uppercase variant for the big labels on the card: "100KG", "12 REPS", "45S".
    func compactFormat(_ value: Double) -> String {
        let separator = self == .reps ? " " : ""
        return "\(value.formattedString(maxDecimalPlaces: 2))\(separator)\(symbol.uppercased())"
    }
}
