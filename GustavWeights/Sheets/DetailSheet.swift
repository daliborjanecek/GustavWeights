//
//  ExerciseToInspect.swift
//  GustavWeights
//
//  Created by Dalibor Janeček on 16.03.2024.
//

import SwiftUI
import SwiftData
import Charts

struct DetailSheet: View {
    @Bindable var exercise: Exercise
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) var context
    
    @State private var showingDialog = false
    @State private var newName = ""
    
    var body: some View {
        NavigationStack {
            List {
                ChartView(exercise: exercise)
                ForEach(exercise.weights.sorted { $0.date > $1.date }, id: \.self) { weight in
                    NavigationLink {
                        EditWeightSheet(weight: weight)
                    } label: {
                        HStack {
                            Text(weight.date.formatted(.dateTime.day().month().year()))
                            Spacer()
                            if weight.value == exercise.personalRecord {
                                Image(systemName: "trophy.fill")
                                    .foregroundStyle(Color("StopColor"))
                                    .accessibilityLabel("Personal record")
                            }
                            Text("\(weight.value.formattedString(maxDecimalPlaces: 2)) kg")
                        }
                    }
                }
                .onDelete { indexSet in
                    let sortedWeights = exercise.weights.sorted { $0.date > $1.date }
                    let weightsToDelete = indexSet.map { sortedWeights[$0] }
                    for weight in weightsToDelete {
                        exercise.weights.removeAll { $0 == weight }
                        context.delete(weight)
                    }
                }
                Section {
                    NavigationLink {
                        renameExercise
                    } label: {
                        Text("Rename")
                    }

                }
                Section {
                    Button(action: {
                        showingDialog = true
                    }, label: {
                        Text("Delete").foregroundStyle(.red)
                    })
                }
                .navigationTitle("\(exercise.name)")
                .navigationBarTitleDisplayMode(.inline)
            }
            .toolbar(content: {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            })
            .font(Font.custom("MartianMono-Regular", size: 15))
            .confirmationDialog("Do you really want to delete the exercise?",
                                isPresented: $showingDialog,
                                titleVisibility: .visible) {
                Button("Yes, delete", role: .destructive) {
                    context.delete(exercise)
                    dismiss()
                }
                
            }
        }
    }
    
    var renameExercise: some View {
        VStack {
            Form {
                TextField("Name", text: $newName)
                    .autocorrectionDisabled(true)
            }

            Spacer()
        }
        .onAppear {
            newName = exercise.name
        }
        .onChange(of: newName) {
            // Never store an empty name, the card would be blank.
            let trimmed = newName.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.isEmpty {
                exercise.name = trimmed
            }
        }
        .toolbar(content: {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button("Done") {
                    dismiss()
                }
            }
        })
    }
}
