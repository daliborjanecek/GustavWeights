//
//  DetailSheet.swift
//  GustavWeights
//
//  Created by Dalibor Janeček on 16.03.2024.
//

import SwiftUI
import GustavUICore
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
                Section {
                    ChartView(exercise: exercise)
                }
                
                if !exercise.weights.isEmpty {
                    Section {
                        ForEach(sortedWeights) { weight in
                            NavigationLink {
                                EditWeightSheet(weight: weight)
                            } label: {
                                historyRow(weight)
                            }
                        }
                        .onDelete { indexSet in
                            let weightsToDelete = indexSet.map { sortedWeights[$0] }
                            for weight in weightsToDelete {
                                exercise.weights.removeAll { $0 == weight }
                                context.delete(weight)
                            }
                        }
                    } header: {
                        sectionHeader("HISTORY")
                    } footer: {
                        Text("Tap an entry to edit it, swipe left to delete it.")
                            .font(.sectionFooter)
                            .foregroundStyle(Color.gustavNeutral)
                    }
                }
                
                Section {
                    NavigationLink {
                        renameExercise
                    } label: {
                        Text("Rename")
                    }
                    NavigationLink {
                        ReorderExercisesView()
                    } label: {
                        Text("Reorder exercises")
                    }
                    Button(action: {
                        showingDialog = true
                    }, label: {
                        Text("Delete exercise").foregroundStyle(.red)
                    })
                } header: {
                    sectionHeader("EXERCISE")
                }
            }
            .navigationTitle(exercise.name.uppercased())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            })
            .font(.gustavBody)
            .tint(Color.gustavNavigationItemsColor)
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
    
    /// Newest entries first.
    private var sortedWeights: [Weight] {
        exercise.weights.sorted { $0.date > $1.date }
    }
    
    private func historyRow(_ weight: Weight) -> some View {
        HStack {
            Text(weight.date.formatted(.dateTime.day().month().year()))
            Spacer()
            if weight.value == exercise.personalRecord {
                Text("PR")
                    .font(.sectionHeader)
                    .foregroundStyle(Color.gustavWhite)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.gustavPink, in: Capsule())
                    .accessibilityLabel("Personal record")
            }
            Text("\(weight.value.formattedString(maxDecimalPlaces: 2)) kg")
                .font(.bodyNumber)
        }
    }
    
    private func sectionHeader(_ title: LocalizedStringKey) -> some View {
        Text(title)
            .font(.sectionHeader)
            .foregroundStyle(Color.gustavNeutral)
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
