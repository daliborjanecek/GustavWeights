//
//  Exercise.swift
//  GustavWeights
//
//  Created by Dalibor Janeček on 10.03.2024.
//

import Foundation
import SwiftData

@Model
class Exercise {
    var name: String
    /// Deleting an exercise deletes all of its records too,
    /// so no orphaned `Weight` objects stay in the store.
    @Relationship(deleteRule: .cascade) var weights: [Weight]
    
    init(name: String) {
        self.name = name
        self.weights = []
    }
}
