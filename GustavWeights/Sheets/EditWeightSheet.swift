//
//  EditWeightSheet.swift
//  GustavWeights
//
//  Created by Dalibor Janeček on 16.03.2024.
//

import SwiftUI
import GustavUICore

struct EditWeightSheet: View {
    @Bindable var weight: Weight
    let unit: ExerciseUnit
    @Environment(\.dismiss) private var dismiss
    
    // Pushed from DetailSheet's NavigationStack, so it has no stack of its own.
    var body: some View {
        Form {
            HStack {
                TextField("Value", value: $weight.value, format: .number)
                    .keyboardType(unit.allowsDecimals ? .decimalPad : .numberPad)
                    .font(.bodyNumber)
                Text(unit.symbol)
                    .foregroundStyle(Color.gustavNeutral)
            }
            // Lets you fix the date of an entry or log a session afterwards.
            DatePicker("Date",
                       selection: $weight.date,
                       in: ...Date.now,
                       displayedComponents: [.date, .hourAndMinute])
        }
        .font(.gustavBody)
        .navigationTitle("Edit entry")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(content: {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button("Done") {
                    dismiss()
                }
            }
        })
    }
}
