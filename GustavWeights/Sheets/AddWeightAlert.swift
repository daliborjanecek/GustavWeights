//
//  AddWeightAlert.swift
//  GustavWeights
//
//  Created by Dalibor Janeček on 16.03.2024.
//

import SwiftUI

/// System alert with a number field for logging a new value (weight, reps or time).
/// Presented while `exercise` is not nil.
struct AddWeightAlert: ViewModifier {
    @Binding var exercise: Exercise?
    
    @State private var text = ""
    
    func body(content: Content) -> some View {
        content
            .alert(exercise?.unit.addTitle ?? "Add weight", isPresented: isPresented, presenting: exercise) { exercise in
                TextField(exercise.unit.fieldPrompt, text: $text)
                    .keyboardType(exercise.unit.allowsDecimals ? .decimalPad : .numberPad)
                Button("Save") {
                    save(to: exercise)
                }
                .disabled(value(for: exercise) == nil)
                Button("Cancel", role: .cancel) {}
            } message: { exercise in
                Text(exercise.name)
            }
    }
    
    private var isPresented: Binding<Bool> {
        Binding(
            get: { exercise != nil },
            set: { isShown in
                if !isShown {
                    exercise = nil
                    // Start with an empty field next time.
                    text = ""
                }
            }
        )
    }
    
    private func value(for exercise: Exercise) -> Double? {
        Self.parseWeight(text, allowsDecimals: exercise.unit.allowsDecimals)
    }
    
    private func save(to exercise: Exercise) {
        guard let value = value(for: exercise) else { return }
        exercise.weights.append(Weight(value: value))
    }
    
    /// Accepts both decimal separators ("62.5" and "62,5"),
    /// returns nil for empty, negative or invalid input
    /// and for decimals when the unit counts whole repetitions.
    static func parseWeight(_ text: String, allowsDecimals: Bool = true) -> Double? {
        let normalized = text
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ",", with: ".")
        guard let value = Double(normalized), value.isFinite, value >= 0 else { return nil }
        guard allowsDecimals || value == value.rounded() else { return nil }
        return value
    }
}

extension View {
    /// Shows the add weight alert while `exercise` is not nil.
    func addWeightAlert(for exercise: Binding<Exercise?>) -> some View {
        modifier(AddWeightAlert(exercise: exercise))
    }
}
