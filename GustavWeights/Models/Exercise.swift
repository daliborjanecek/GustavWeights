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
    /// Position on the main screen, set by the user in Reorder exercises.
    /// Exercises with the same order (e.g. all existing ones = 0) are sorted by name.
    var order: Int = 0
    /// Deleting an exercise deletes all of its records too,
    /// so no orphaned `Weight` objects stay in the store.
    @Relationship(deleteRule: .cascade) var weights: [Weight]
    
    init(name: String, order: Int = 0) {
        self.name = name
        self.order = order
        self.weights = []
    }
}

extension Exercise {
    /// Order of exercises everywhere in the app.
    static var sortOrder: [SortDescriptor<Exercise>] {
        [SortDescriptor(\.order), SortDescriptor(\.name)]
    }
    
    /// The heaviest weight ever logged, or 0 when there is no record yet.
    var personalRecord: Double {
        weights.map(\.value).max() ?? 0
    }
}
