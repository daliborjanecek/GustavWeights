//
//  ExerciseView.swift
//  GustavWeights
//
//  Created by Dalibor Janeček on 06.04.2024.
//

import SwiftUI
import GustavUICore

struct ExerciseView: View {
    var exercise: Exercise
    var geometry: GeometryProxy
    var lastExercise: Bool = false
    /// False once the maximum number of exercises is reached.
    var canAddExercise: Bool = true
    var pullToAction: (()->())?

    @State private var plusSize = 0.05
    @State private var position = 0.0
    @State private var isCelebratingPR = false
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("\(exercise.name)")
                .offset(getTitleOffset(length: exercise.name.count))
                .font(Font.custom("MartianMono-Bold", size: 500))
                .minimumScaleFactor(0.01)
                .textCase(.uppercase)
                .frame(height: geometry.size.height/3, alignment: .bottom)
            
            Spacer()
            
            if isCelebratingPR {
                Text("NEW PR!")
                    .font(Font.custom("MartianMono-Bold", size: 15))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.gustavPink, in: Capsule())
                    .transition(.scale.combined(with: .opacity))
            }
            
            PersonalRecordView(exercise: exercise)
                .font(Font.custom("MartianMono-Bold", size: 30))
                .scaleEffect(isCelebratingPR ? 1.1 : 1.0, anchor: .leading)
            
            LastLiftView(exercise: exercise)
                .font(Font.custom("MartianMono-Regular", size: 15))
                .opacity(0.8)
            
        }
        .padding(30)
        .frame(width: geometry.size.width * (lastExercise ? 1.0 : 0.85))
        .foregroundColor(Color.gustavVolt)
        .overlay { if lastExercise && canAddExercise { plusToAction } }
        // Haptic confirmation whenever a new weight is logged.
        .sensoryFeedback(trigger: exercise.weights.count) { oldCount, newCount in
            newCount > oldCount ? .success : nil
        }
        .onChange(of: exercise.personalRecord) { oldPR, newPR in
            // Celebrate only beating an existing record, not the very first entry.
            guard oldPR > 0, newPR > oldPR else { return }
            celebratePR()
        }
    }
    
    private func celebratePR() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
            isCelebratingPR = true
        }
        Task {
            try? await Task.sleep(for: .seconds(3))
            withAnimation(.easeOut) {
                isCelebratingPR = false
            }
        }
    }
    
    var plusToAction: some View {
        GeometryReader { geo in
            HStack {
                Spacer()
                VStack {
                    Spacer()
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .foregroundStyle(Color.gustavVolt)
                        .frame(width: 40 * (plusSize + 1), height: 40 * (plusSize + 1))
                        .offset(x: (-position) + 30 + (position * 1.5) - position)
                        .onChange(of: geo.frame(in: .global)) { oldValue, newValue in
                            if newValue.minX < 0 {
                                position = newValue.minX
                            } else {
                                position = 0.0
                            }
                            if position < -1 {
                                plusSize = abs(position) / 60
                            } else {
                                plusSize = 0.05
                            }
                            if position < -50 {
                                if let action = pullToAction {
                                        action()
                                }
                            }
                        }
                    Spacer()
                }
            }
        }
    }
    
    func getTitleOffset(length: Int) -> CGSize {
        switch length {
        case 0...3:
            return CGSize(width: -15, height: 30)
        case 4:
            return CGSize(width: -10, height: 20)
        case 5...7:
            return CGSize(width: -5, height: 5)
        default:
            return CGSizeZero
        }
    }
}
