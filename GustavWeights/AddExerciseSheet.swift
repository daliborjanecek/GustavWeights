//
//  AddExerciseSheet.swift
//  GustavWeights
//
//  Created by Dalibor Janeček on 30.12.2025.
//

import SwiftUI
import SwiftData

struct AddExerciseSheet: View {
    
    // SwiftData
    @Query(sort: \TrainingModel.date) var trainings: [TrainingModel]
    @Environment(\.modelContext) var context
    
    @Environment(\.dismiss) var dismiss
    
    var exercise: ExerciseModel?
    
    @State private var selectedExercise: ExerciseType
    @State private var weight: Double
    @State private var selectedWeightUnit: WeightUnit
    @State private var reps: Int
    @State private var duration: Int
    
    init(exercise: ExerciseModel) {
        self.selectedExercise = exercise.exerciseType
        self.weight = exercise.weight
        self.selectedWeightUnit = exercise.units
        self.reps = exercise.reps
        self.duration = exercise.duration
        self.exercise = exercise
    }
    
    init() {
        self.exercise = nil
        self.selectedExercise = .squat
        self.weight = 0.0
        self.selectedWeightUnit = .kg
        self.reps = 0
        self.duration = 0
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("Select exercise: ")
                Picker("Select exercise", selection: $selectedExercise) {
                    ForEach(ExerciseType.allCases) { exercise in
                        Text(exercise.rawValue)
                            .tag(exercise)
                    }
                }
            }
            
            HStack {
                Text("Set weight: ")
                TextField("Weight", value: $weight, format: .number)
                    .frame(width: 100)
                    .padding(8)
                    .background(Color.light)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                Picker("Select weight unit", selection: $selectedWeightUnit) {
                    ForEach(WeightUnit.allCases) { exercise in
                        Text(exercise.rawValue)
                            .tag(exercise)
                    }
                }
            }
            
            HStack {
                Text("Reps: ")
                TextField("Reps", value: $reps, format: .number)
                    .frame(width: 100)
                    .padding(8)
                    .background(Color.light)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            
            HStack {
                Text("Duration: ")
                TextField("Duration", value: $duration, format: .number)
                    .frame(width: 100)
                    .padding(8)
                    .background(Color.light)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            
            Button("Save") {
               saveExercise()
                dismiss()
            }
            .padding()
            
        }
    }
    
    func saveExercise() {
        if let exercise {
            exercise.saveExercise(exerciseType: selectedExercise, weight: weight, units: selectedWeightUnit, reps: reps, duration: duration)
        }
    }
}

#Preview {
    AddExerciseSheet()
}
