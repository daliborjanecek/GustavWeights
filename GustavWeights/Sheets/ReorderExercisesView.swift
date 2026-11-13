//
//  ReorderExercisesView.swift
//  GustavWeights
//
//  Drag exercises to change their order on the main screen.
//

import SwiftUI
import SwiftData
import GustavUICore

struct ReorderExercisesView: View {
    @Query(sort: Exercise.sortOrder) private var exercises: [Exercise]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        List {
            Section {
                ForEach(exercises) { exercise in
                    Text(exercise.name.uppercased())
                        .font(.bodyNumber)
                }
                .onMove(perform: move)
            } footer: {
                Text("Drag the handles to change the order of exercises on the main screen.")
                    .font(.sectionFooter)
                    .foregroundStyle(Color.gustavNeutral)
            }
        }
        // Always in edit mode, so the drag handles are visible right away.
        .environment(\.editMode, .constant(.active))
        .font(.gustavBody)
        .navigationTitle("Reorder exercises")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") {
                    dismiss()
                }
            }
        }
    }
    
    /// Stores the new order of all exercises as 0, 1, 2, …
    private func move(from source: IndexSet, to destination: Int) {
        var reordered = exercises
        reordered.move(fromOffsets: source, toOffset: destination)
        for (index, exercise) in reordered.enumerated() {
            exercise.order = index
        }
    }
}
