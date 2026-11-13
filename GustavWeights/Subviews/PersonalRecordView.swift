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
        Text("PR:\(exercise.personalRecord.formattedString(maxDecimalPlaces: 2))KG")
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// Shows the last logged weight and how long ago it was,
/// so you know what to put on the bar today.
struct LastLiftView: View {
    let exercise: Exercise
    
    var body: some View {
        if let last = exercise.lastWeight {
            Text("LAST:\(last.value.formattedString(maxDecimalPlaces: 2))KG · \(relativeDay(last.date).uppercased())")
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    /// "today", "yesterday", "3 days ago" – counted in calendar days,
    /// because the time of day doesn't matter for a training log.
    private func relativeDay(_ date: Date) -> String {
        let calendar = Calendar.current
        let days = calendar.dateComponents(
            [.day],
            from: calendar.startOfDay(for: date),
            to: calendar.startOfDay(for: .now)
        ).day ?? 0
        let formatter = RelativeDateTimeFormatter()
        formatter.dateTimeStyle = .named
        return formatter.localizedString(from: DateComponents(day: -days))
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
