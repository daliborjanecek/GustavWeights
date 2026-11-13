//
//  AddExerciseSheet.swift
//  GustavWeights
//
//  Created by Dalibor Janeček on 16.03.2024.
//

import SwiftUI
import SwiftData

struct AddExerciseSheet: View {
    @Environment(\.modelContext) var context
    @Environment(\.dismiss) private var dismiss
    
    @Query(sort: Exercise.sortOrder) private var exercises: [Exercise]
    
    @State private var name: String = ""
    
    /// Called with the newly created exercise, so the caller can scroll to it.
    var onAdd: (Exercise) -> Void = { _ in }
    
    var body: some View {
        SingleValueEditView(
            textFieldPlaceholder: "Exercise",
            buttonLabelText: "Add",
            text: $name,
            isButtonEnabled: !trimmedName.isEmpty) {
                guard !trimmedName.isEmpty else { return }
                // A new exercise goes to the end of the list.
                let nextOrder = (exercises.map(\.order).max() ?? -1) + 1
                let exercise = Exercise(name: trimmedName, order: nextOrder)
                context.insert(exercise)
                onAdd(exercise)
                dismiss()
            }
    }
    
    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
