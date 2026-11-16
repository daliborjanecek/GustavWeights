//
//  AddExerciseSheet.swift
//  GustavWeights
//
//  Created by Dalibor Janeček on 16.03.2024.
//

import SwiftUI
import SwiftData
import GustavUICore

/// Sheet for a new exercise: its name, unit and whether a higher value is better.
struct AddExerciseSheet: View {
    /// Called with the newly created exercise, so the caller can scroll to it.
    let onAdd: (Exercise) -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Query(sort: Exercise.sortOrder) private var exercises: [Exercise]

    @State private var name = ""
    @State private var unit: ExerciseUnit = .kilograms
    @State private var higherIsBetter = true

    var body: some View {
        NavigationStack {
            Form {
                ExerciseSettingsFields(name: $name,
                                       unit: $unit,
                                       higherIsBetter: $higherIsBetter,
                                       focusesName: true)
            }
            .font(.gustavBody)
            .navigationTitle("NEW EXERCISE")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        add()
                    }
                    .disabled(trimmedName.isEmpty)
                }
            }
        }
        .tint(Color.gustavNavigationItemsColor)
    }

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func add() {
        guard !trimmedName.isEmpty else { return }
        // A new exercise goes to the end of the list.
        let nextOrder = (exercises.map(\.order).max() ?? -1) + 1
        let exercise = Exercise(name: trimmedName,
                                order: nextOrder,
                                unit: unit,
                                higherIsBetter: higherIsBetter)
        context.insert(exercise)
        onAdd(exercise)
        dismiss()
    }
}

#Preview {
    AddExerciseSheet { _ in }
        .modelContainer(for: Exercise.self, inMemory: true)
}
