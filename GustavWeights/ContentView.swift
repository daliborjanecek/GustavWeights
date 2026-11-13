//
//  ContentView.swift
//  GustavWeights
//
//  Created by Dalibor Janeček on 10.03.2024.
//

import SwiftUI
import GustavUICore
import SwiftData

struct ContentView: View {
    
    /// Maximum number of exercises, the app is meant for your main lifts.
    static let maxExercises = 12
    /// Height of the add exercise sheet: input field plus a control button.
    static let inputSheetHeight: CGFloat = 220
    
    // SwiftData
    @Query(sort: \Exercise.name) var exercises: [Exercise]
    @Environment(\.modelContext) var context
    
    @State private var isShowingAddExercise = false
    @State private var isShowingAddWeight = false
    @State private var exerciseToAddWeight: Exercise?
    @State private var exerciseToDetail: Exercise?
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
                                .fill( exercise == scrolledExercise ? Color.gustavVolt : Color.gustavNeutral )
                                .frame(height: 5)
                                
                        }
                    }
                    .padding()
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 0) {
                            ForEach(exercises, id: \.self) {exercise in
                                ExerciseView(exercise: exercise,
                                             geometry: geometry,
                                             lastExercise: (exercise == exercises.last),
                                             canAddExercise: exercises.count < Self.maxExercises) {
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
                                    .font(.weightsEmptyTitle)
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
                            .foregroundStyle(Color.gustavVolt)
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
                        .presentationDetents([.height(Self.inputSheetHeight)])
                    })
                    .addWeightAlert(for: $exerciseToAddWeight)
                    .sheet(item: $exerciseToDetail, content: { exercise in DetailSheet(exercise: exercise) })
                    
                    if !exercises.isEmpty {
                        buttonBar
                    }
                }
            }
            .font(.bodyNumber)
            .ignoresSafeArea(edges: .bottom)
        })
    }
    
    /// Same layout as the GustavTimer controls: a wide primary pill
    /// and a narrow secondary one.
    var buttonBar: some View {
        HStack(spacing: 16) {
            ControlButton(label: "ADD WEIGHT") {
                exerciseToAddWeight = currentExercise
            }
            ControlButton(systemImage: "chart.bar.xaxis",
                          accessibilityLabel: "Detail",
                          color: .gustavNeutral) {
                exerciseToDetail = currentExercise
            }
            .frame(width: 100)
        }
        .animation(.easeInOut, value: currentExercise)
        .frame(maxWidth: .infinity)
        .padding()
        .padding(.bottom, 5)
        .padding(.horizontal, 5)
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
