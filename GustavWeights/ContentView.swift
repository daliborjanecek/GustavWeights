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
    
    // SwiftData
    @Query(sort: Exercise.sortOrder) var exercises: [Exercise]
    @Environment(\.modelContext) var context
    
    @State private var isShowingAddExercise = false
    @State private var exerciseToAddWeight: Exercise?
    @State private var exerciseToDetail: Exercise?
    @State private var scrolledExercise: Exercise?
    /// Exercise that was just created and should be scrolled to
    /// as soon as it shows up in the query results.
    @State private var exerciseToScrollTo: Exercise?
    /// True while the finger is on the page indicator.
    @State private var isScrubbingIndicator = false
    /// True while the finger is held down on the exercise cards and
    /// scrubs as if it were on the page indicator. Resets itself when
    /// the gesture ends or is cancelled.
    @GestureState private var isHoldScrubbing = false
    /// Page indicator bar in global coordinates, used to map a finger
    /// held anywhere on the screen to an exercise.
    @State private var indicatorFrame: CGRect = .zero
    /// Finger movement since holding ADD WEIGHT started, nil when not picking.
    @GestureState private var weightPickTranslation: CGSize?
    
    @AppStorage("loadFirstExercise") private var loadFirstExercise = true
    
    var body: some View {
        GeometryReader(content: { geometry in
            
            ZStack {
                Color.black.ignoresSafeArea()
                
                BGImageView(image: Image("Boxer"))
                
                VStack {
                    pageIndicator
                    
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
                    // Hold a finger on the cards to scrub like on the page indicator.
                    .simultaneousGesture(holdToScrubGesture)
                    // While scrubbing, the finger must not also drag the cards.
                    .scrollDisabled(isHoldScrubbing)
                    .sensoryFeedback(.impact(weight: .medium), trigger: isHoldScrubbing) { _, isActive in
                        isActive
                    }
                    
                    // ALERTS AND SHEETS
                    .addWeightAlert(for: $exerciseToAddWeight)
                    .sheet(item: $exerciseToDetail, content: { exercise in DetailSheet(exercise: exercise) })
                    
                    if !exercises.isEmpty {
                        buttonBar
                    }
                }
                
                if let translation = weightPickTranslation,
                   let exercise = currentExercise,
                   let scale = WeightPickerScale(exercise: exercise) {
                    WeightPickerOverlay(exerciseName: exercise.name,
                                        scale: scale,
                                        translation: translation)
                        // The finger is tracked by the button's gesture, not by the overlay.
                        .allowsHitTesting(false)
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.2), value: weightPickTranslation == nil)
            // Kept on a different view than the add weight alert,
            // two alerts on one view don't work reliably.
            .addExerciseAlert(isPresented: $isShowingAddExercise) { exercise in
                exerciseToScrollTo = exercise
            }
            .font(.bodyNumber)
            .ignoresSafeArea(edges: .bottom)
        })
    }
    
    /// One segment per exercise at the top of the screen.
    /// Touch it and slide the finger along it to scrub through exercises:
    /// the page switches while the finger is still down. A tap jumps directly.
    var pageIndicator: some View {
        HStack(spacing: 5) {
            ForEach(exercises) { exercise in
                RoundedRectangle(cornerRadius: 10)
                    .fill(exercise == currentExercise ? Color.gustavVolt : Color.gustavNeutral)
                    // Bars grow while scrubbing, so it's clear the finger controls them.
                    .frame(height: isScrubbing ? 10 : 5)
            }
        }
        // Fixed height, so the content below doesn't move while the bars grow.
        .frame(height: 10)
        .onGeometryChange(for: CGRect.self) { proxy in
            proxy.frame(in: .global)
        } action: { frame in
            indicatorFrame = frame
        }
        // 37 pt tall touch area in total, the bars themselves are tiny.
        .padding(.vertical, 13.5)
        .overlay {
            GeometryReader { geometry in
                Color.clear
                    .contentShape(Rectangle())
                    .gesture(scrubGesture(width: geometry.size.width))
            }
        }
        .padding(.horizontal)
        .animation(.snappy(duration: 0.2), value: isScrubbing)
        // Tick on every exercise change (scrubbing, tap or swipe), not on launch.
        .sensoryFeedback(.selection, trigger: scrolledExercise) { oldValue, newValue in
            oldValue != nil && newValue != nil
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Exercises")
        .accessibilityValue(currentExercise?.name ?? "")
        .accessibilityHint("Swipe up or down to switch the exercise.")
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment: selectNeighbourExercise(offset: 1)
            case .decrement: selectNeighbourExercise(offset: -1)
            @unknown default: break
            }
        }
    }
    
    /// Starts reacting on touch down (minimumDistance 0), so both a tap
    /// and a slide along the bar switch the exercise immediately.
    private func scrubGesture(width: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                isScrubbingIndicator = true
                selectExercise(atIndicatorX: value.location.x, width: width)
            }
            .onEnded { value in
                selectExercise(atIndicatorX: value.location.x, width: width)
                isScrubbingIndicator = false
            }
    }
    
    /// Finger on the page indicator or held on the cards.
    private var isScrubbing: Bool {
        isScrubbingIndicator || isHoldScrubbing
    }
    
    /// Long press anywhere on the cards, then slide: the finger's horizontal
    /// position picks the exercise exactly as if it were on the page indicator.
    /// Moving before the press is recognised keeps normal swiping between cards.
    private var holdToScrubGesture: some Gesture {
        LongPressGesture(minimumDuration: 0.35)
            .sequenced(before: DragGesture(minimumDistance: 0, coordinateSpace: .global))
            .updating($isHoldScrubbing) { value, isActive, _ in
                if case .second(true, _) = value {
                    isActive = true
                }
            }
            .onChanged { value in
                guard case .second(true, let drag?) = value else { return }
                selectExercise(atIndicatorX: drag.location.x - indicatorFrame.minX,
                               width: indicatorFrame.width)
            }
    }
    
    /// Maps a horizontal position on the indicator to an exercise and scrolls to it.
    private func selectExercise(atIndicatorX x: CGFloat, width: CGFloat) {
        guard !exercises.isEmpty, width > 0 else { return }
        let index = Int(x / width * CGFloat(exercises.count))
        let exercise = exercises[min(max(index, 0), exercises.count - 1)]
        guard exercise != scrolledExercise else { return }
        // A short animation keeps up with a fast finger.
        withAnimation(.snappy(duration: 0.15)) {
            scrolledExercise = exercise
        }
    }
    
    private func selectNeighbourExercise(offset: Int) {
        guard let current = currentExercise,
              let index = exercises.firstIndex(of: current),
              exercises.indices.contains(index + offset) else { return }
        withAnimation {
            scrolledExercise = exercises[index + offset]
        }
    }
    
    /// Same layout as the GustavTimer controls: a wide primary pill
    /// and a narrow secondary one.
    var buttonBar: some View {
        HStack(spacing: 16) {
            addWeightButton
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
    
    /// Tap: alert with a number field. Hold and slide up/down: pick the weight
    /// from a range around the PR, release to save (see WeightPicker.swift).
    var addWeightButton: some View {
        ControlButtonLabel(label: "ADD WEIGHT")
            .contentShape(Rectangle())
            .gesture(
                holdToPickWeightGesture.exclusively(
                    before: TapGesture().onEnded {
                        exerciseToAddWeight = currentExercise
                    }
                )
            )
            .sensoryFeedback(.impact(weight: .medium), trigger: weightPickTranslation != nil) { _, isPicking in
                isPicking
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Add weight")
            .accessibilityAddTraits(.isButton)
            .accessibilityAction {
                exerciseToAddWeight = currentExercise
            }
    }
    
    private var holdToPickWeightGesture: some Gesture {
        LongPressGesture(minimumDuration: 0.3)
            .sequenced(before: DragGesture(minimumDistance: 0))
            .updating($weightPickTranslation) { value, translation, _ in
                if case .second(true, let drag) = value {
                    translation = drag?.translation ?? .zero
                }
            }
            .onEnded { value in
                guard case .second(true, let drag) = value,
                      let exercise = currentExercise else { return }
                // Without records there is no PR to pick around, use the alert instead.
                guard let scale = WeightPickerScale(exercise: exercise) else {
                    exerciseToAddWeight = exercise
                    return
                }
                let translation = drag?.translation ?? .zero
                guard !WeightPickerScale.isCancelled(translation) else { return }
                exercise.weights.append(Weight(value: scale.value(for: translation)))
            }
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
