//
//  AddExerciseAlert.swift
//  GustavWeights
//
//  Created by Dalibor Janeček on 16.03.2024.
//

import SwiftUI
import SwiftData

/// System alert with a text field for adding a new exercise.
struct AddExerciseAlert: ViewModifier {
    @Binding var isPresented: Bool
    /// Called with the newly created exercise, so the caller can scroll to it.
    let onAdd: (Exercise) -> Void
    
    @Environment(\.modelContext) private var context
    @Query(sort: Exercise.sortOrder) private var exercises: [Exercise]
    
    @State private var name = ""
    
    func body(content: Content) -> some View {
        content
            .alert("Add exercise", isPresented: presented) {
                TextField("Exercise name", text: $name)
                    .autocorrectionDisabled(true)
                    .textInputAutocapitalization(.words)
                Button("Add") {
                    add()
                }
                .disabled(trimmedName.isEmpty)
                Button("Cancel", role: .cancel) {}
            }
    }
    
    private var presented: Binding<Bool> {
        Binding(
            get: { isPresented },
            set: { isShown in
                isPresented = isShown
                if !isShown {
                    // Start with an empty field next time.
                    name = ""
                }
            }
        )
    }
    
    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func add() {
        guard !trimmedName.isEmpty else { return }
        // A new exercise goes to the end of the list.
        let nextOrder = (exercises.map(\.order).max() ?? -1) + 1
        let exercise = Exercise(name: trimmedName, order: nextOrder)
        context.insert(exercise)
        onAdd(exercise)
    }
}

extension View {
    /// Shows the add exercise alert while `isPresented` is true.
    func addExerciseAlert(isPresented: Binding<Bool>, onAdd: @escaping (Exercise) -> Void) -> some View {
        modifier(AddExerciseAlert(isPresented: isPresented, onAdd: onAdd))
    }
}
