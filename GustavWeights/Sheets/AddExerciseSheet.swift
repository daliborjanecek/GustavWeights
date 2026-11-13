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
                let exercise = Exercise(name: trimmedName)
                context.insert(exercise)
                onAdd(exercise)
                dismiss()
            }
    }
    
    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
