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
    /// Raw value of `ExerciseUnit`. Existing exercises are in kilograms.
    var unitRawValue: String = ExerciseUnit.kilograms.rawValue
    /// True when a smaller number is a better result, e.g. the time of a run.
    /// Stored inverted (see `higherIsBetter`): when SwiftData migrates exercises
    /// created before this property existed, it fills the new column with
    /// false and ignores the default value written here. With a stored
    /// `higherIsBetter = true` those exercises became "lower is better",
    /// so their PR turned into the lowest weight ever logged.
    var lowerIsBetter: Bool = false
    /// Deleting an exercise deletes all of its records too,
    /// so no orphaned `Weight` objects stay in the store.
    @Relationship(deleteRule: .cascade) var weights: [Weight]

    init(name: String, order: Int = 0, unit: ExerciseUnit = .kilograms, higherIsBetter: Bool = true) {
        self.name = name
        self.order = order
        self.unitRawValue = unit.rawValue
        self.lowerIsBetter = !higherIsBetter
        self.weights = []
    }
}

extension Exercise {
    /// Order of exercises everywhere in the app.
    static var sortOrder: [SortDescriptor<Exercise>] {
        [SortDescriptor(\.order), SortDescriptor(\.name)]
    }

    var unit: ExerciseUnit {
        get { ExerciseUnit(rawValue: unitRawValue) ?? .kilograms }
        set { unitRawValue = newValue.rawValue }
    }

    /// True when a bigger number is a better result (weight, reps),
    /// false e.g. for the time of a run.
    var higherIsBetter: Bool {
        get { !lowerIsBetter }
        set { lowerIsBetter = !newValue }
    }

    /// The best value ever logged (the highest, or the lowest when lower
    /// is better), 0 when there is no record yet.
    var personalRecord: Double {
        let values = weights.map(\.value)
        return (higherIsBetter ? values.max() : values.min()) ?? 0
    }

    /// True when `value` is a better result than `other` for this exercise.
    func isBetter(_ value: Double, than other: Double) -> Bool {
        higherIsBetter ? value > other : value < other
    }
}
