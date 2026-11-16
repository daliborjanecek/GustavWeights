//
//  PersonalRecordView.swift
//  GustavWeights
//
//  Created by Dalibor Janeček on 17.03.2024.
//

import SwiftUI

struct PersonalRecordView: View {
    let exercise: Exercise
    
    var body: some View {
        Text("PR:\(exercise.unit.compactFormat(exercise.personalRecord))")
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

extension Double {
    func formattedString(maxDecimalPlaces: Int) -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = maxDecimalPlaces
        return String(formatter.string(from: NSNumber(value: self)) ?? "")
    }
}
