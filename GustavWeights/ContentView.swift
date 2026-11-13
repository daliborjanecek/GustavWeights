//
//  ContentView.swift
//  GustavWeights
//
//  Created by Dalibor Janeček on 10.03.2024.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    
    let buttonHeight:CGFloat = 80.0
    
    // SwiftData
    @Query(sort: \Exercise.name) var exercises: [Exercise]
    @Environment(\.modelContext) var context
    
    @State private var isShowingAddExercise = false
    @State private var isShowingAddWeight = false
    @State private var exerciseToAddWeight: Exercise?
    @State private var exerciseToDetail: Exercise?
    @State private var weightToEdit: Weight?
    @State private var scrolledExercise: Exercise?
    /// Exercise that was just created and should be scrolled to
    /// as soon as it shows up in the query results.
    @State private var exerciseToScrollTo: Exercise?
    
    @AppStorage("loadFirstExercise") private var loadFirstExercise = true
    
    var body: some View {
        GeometryReader(content: { geometry in
            
            ZStack {
                Color.black.ignoresSafeArea()
                
                BGImageView(image: Image("Boxer"))
                
                VStack {
                    HStack(spacing: 5) {
                        ForEach(exercises) {exercise in
                            RoundedRectangle(cornerRadius: 10)
                                .fill( exercise == scrolledExercise ? Color("StartColor") : Color("ResetColor") )
                                .frame(height: 5)
                                
                        }
                    }
                    .padding()
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 0) {
                            ForEach(exercises, id: \.self) {exercise in
                                ExerciseView(exercise: exercise, geometry: geometry, lastExercise: (exercise == exercises.last)) {
                                    if !isShowingAddExercise {
                                        isShowingAddExercise.toggle()
                                    }
                                }
                            }
                        }
                        .scrollTargetLayout()
                    }
                    .overlay {
                        if exercises.isEmpty {
                            VStack {
                                Text("ADD EXERCISE")
                                    .font(Font.custom("MartianMono-Bold", size: 22))
                                    .padding()
                                Text("to record your lifted weight, add exercise")
                                    .fixedSize(horizontal: false, vertical: true)
                                    .multilineTextAlignment(.center)
                                Image(systemName: "plus.circle.fill")
                                    .resizable()
                                    .frame(width: 80, height: 80)
                                    .onTapGesture(perform: {isShowingAddExercise.toggle()})
                                    .padding()
                                
                            }
                            .padding()
                            .foregroundStyle(Color("StartColor"))
                        }
                    }
                    .task {
                        if exercises.isEmpty && loadFirstExercise {
                            let firstSquat = Exercise(name: "Squat")
                            let firstBench = Exercise(name: "Bench press")
                            let firstDL = Exercise(name: "Dead lift")
                            context.insert(firstSquat)
                            context.insert(firstBench)
                            context.insert(firstDL)
                            loadFirstExercise = false
                        }
                    }
                    .onChange(of: exercises, initial: true) {
                        syncScrolledExercise()
                    }
                    .scrollTargetBehavior(.viewAligned)
                    .scrollPosition(id: $scrolledExercise)
                    
                    // SHEETS
                    .sheet(isPresented: $isShowingAddExercise, content: {
                        AddExerciseSheet { exercise in
                            exerciseToScrollTo = exercise
                        }
                        .presentationDetents([.height(150)])
                    })
                    .sheet(item: $exerciseToAddWeight, content: { exercise in
                        AddWeightSheet(exercise: exercise).presentationDetents([.height(150)]) })
                    .sheet(item: $weightToEdit, content: { weight in EditWeightSheet(weight: weight) })
                    .sheet(item: $exerciseToDetail, content: { exercise in DetailSheet(exercise: exercise) })
                    
                    if !exercises.isEmpty {
                        buttonBar
                    }
                }
            }
            .font(Font.custom("MartianMono-Regular", size: 15))
            .ignoresSafeArea(edges: .bottom)
        })
    }
    
    var buttonBar: some View {
        HStack(spacing: 0) {
            Button(action: {
                exerciseToAddWeight = currentExercise
            }) {
                Color("StopColor")
                    .overlay {
                        Text("ADD WEIGHT")
                    }
                    .frame(height: buttonHeight)
            }
            Button(action: {
                exerciseToDetail = currentExercise
            }, label: {
                Color("ResetColor")
                    .overlay {
                        Text("DETAIL")
                    }
                    .frame(height: buttonHeight)
            })
        }
        .foregroundStyle(Color("StartColor"))
    }
    
    /// The exercise the buttons act on. Falls back to the first one
    /// in case the scroll position has not been reported yet.
    private var currentExercise: Exercise? {
        scrolledExercise ?? exercises.first
    }
    
    /// Keeps `scrolledExercise` pointing at an existing exercise:
    /// selects the first one on launch, jumps to a newly added one
    /// and moves away from an exercise that was just deleted.
    private func syncScrolledExercise() {
        if let newExercise = exerciseToScrollTo, exercises.contains(newExercise) {
            exerciseToScrollTo = nil
            withAnimation {
                scrolledExercise = newExercise
            }
            return
        }
        if let current = scrolledExercise, exercises.contains(current) {
            return
        }
        scrolledExercise = exercises.first
    }
}
