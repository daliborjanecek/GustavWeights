//
//  AddWeightAlert.swift
//  GustavWeights
//
//  Created by Dalibor Janeček on 16.03.2024.
//

import SwiftUI

/// System alert with a number field for logging a new weight.
/// Presented while `exercise` is not nil.
struct AddWeightAlert: ViewModifier {
    @Binding var exercise: Exercise?
    
    @State private var text = ""
    
    func body(content: Content) -> some View {
        content
            .alert("Add weight", isPresented: isPresented, presenting: exercise) { exercise in
                TextField("Weight in kg", text: $text)
                    .keyboardType(.decimalPad)
                Button("Save") {
                    save(to: exercise)
                }
                .disabled(value == nil)
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
    
    private var value: Double? {
        Self.parseWeight(text)
    }
    
    private func save(to exercise: Exercise) {
        guard let value else { return }
        exercise.weights.append(Weight(value: value))
    }
    
    /// Accepts both decimal separators ("62.5" and "62,5"),
    /// returns nil for empty, negative or invalid input.
    static func parseWeight(_ text: String) -> Double? {
        let normalized = text
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ",", with: ".")
        guard let value = Double(normalized), value.isFinite, value >= 0 else { return nil }
        return value
    }
}

extension View {
    /// Shows the add weight alert while `exercise` is not nil.
    func addWeightAlert(for exercise: Binding<Exercise?>) -> some View {
        modifier(AddWeightAlert(exercise: exercise))
    }
}
