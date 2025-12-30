//
//  ContentView.swift
//  GustavWeights
//
//  Created by Dalibor Janeček on 10.03.2024.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    
    // SwiftData
    @Query(sort: \TrainingModel.date) var trainings: [TrainingModel]
    @Environment(\.modelContext) var context
    
    @State private var showAddSheet: Bool = false
    
    @State private var selectedExercise: ExerciseModel? = nil
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(trainings) { training in
                    VStack {
                        HStack {
                            Text("Training: \(training.date.formatted())")
                            Spacer()
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                                .onTapGesture {
                                    context.delete(training)
                                }
                        }
                        ForEach(training.sets) { set in
                            Text("SET")
                            if set.exercises.count > 1 {
                                ForEach(set.exercises) { exercise in
                                    Text("EXERCISE: \(exercise.exerciseType.rawValue)")
                                        .onTapGesture {
                                            selectedExercise = exercise
                                        }
                                }
                            } else if let exercise = set.exercises.first {
                                Text("EXERCISE: \(exercise.exerciseType.rawValue)")
                                    .onTapGesture {
                                        selectedExercise = exercise
                                    }
                            }
                            Button("Add exercise into set") {
                                set.insertExercise()
                            }
                        }
                        Button("Add set") {
                            training.insertExerciseSet()
                        }
                        
                        Button("Add exercise") {
                            training.insertExercise()
                        }
                    }
                    .padding()
                    .background(Color.green)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                
                Button("Add Exercise") {
                    selectedExercise = ExerciseModel()
                }
                
                
                Button("Add Training") {
                    context.insert(TrainingModel())
                }
            }
            .padding()
        }
        .sheet(item: $selectedExercise) { exercise in
            AddExerciseSheet(exercise: exercise)
        }
    }
}

#Preview {
    ContentView()
}
