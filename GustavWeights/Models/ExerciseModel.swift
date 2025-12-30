//
//  ExerciseModel.swift
//  GustavWeights
//
//  Created by Dalibor Janeček on 30.12.2025.
//

import Foundation
import SwiftData

@Model
class ExerciseModel: Identifiable {
    var id: UUID
    var exerciseType: ExerciseType
    var isVisible: Bool
    
    var weight: Double
    var units: WeightUnit
    
    var reps: Int
    
    var duration: Int
    
    init() {
        id = UUID()
        exerciseType = .squat
        isVisible = true
        weight = 0
        units = .kg
        reps = 1
        duration = 0
    }
    
    init(exerciseType: ExerciseType, weight: Double, units: WeightUnit, reps: Int, duration: Int) {
        self.id = UUID()
        self.exerciseType = exerciseType
        self.isVisible = true
        self.weight = weight
        self.units = units
        self.reps = reps
        self.duration = duration
    }
    
    func saveExercise(exerciseType: ExerciseType, weight: Double, units: WeightUnit, reps: Int, duration: Int) {
        self.exerciseType = exerciseType
        self.isVisible = true
        self.weight = weight
        self.units = units
        self.reps = reps
        self.duration = duration
    }
}

enum ExerciseType: String, Codable, CaseIterable, Identifiable {
    var id: String { rawValue }
    
    case squat = "SQUAT",
         benchpress = "BENCHPRESS",
         plank = "PLANK",
         deadlift = "DL"
}

enum WeightUnit: String, Codable, CaseIterable, Identifiable {
    var id: String { rawValue }
    
    case kg = "KG", g = "G", lb = "LB"
}
