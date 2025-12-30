//
//  TrainingModel.swift
//  GustavWeights
//
//  Created by Dalibor Janeček on 30.12.2025.
//

import Foundation
import SwiftData

@Model
class TrainingModel {
    var sets: [ExerciseSetModel]
    var date: Date
    
    init() {
        self.sets = []
        self.date = Date()
    }
    
    func insertExerciseSet() {
        sets.append(ExerciseSetModel())
    }
    
    func insertExercise() {
        let set =  ExerciseSetModel()
        set.exercises.append(ExerciseModel())
        
        sets.append(set)
    }
}

@Model
class ExerciseSetModel {
    var id: UUID
    var rounds: Int
    var exercises: [ExerciseModel]
    
    init() {
        id = UUID()
        rounds = 1
        exercises = []
    }
    
    func insertExercise() {
        exercises.append(ExerciseModel())
    }
}


