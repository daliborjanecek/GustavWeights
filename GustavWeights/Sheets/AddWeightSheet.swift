//
//  AddWeightSheet.swift
//  GustavWeights
//
//  Created by Dalibor Janeček on 16.03.2024.
//

import SwiftUI

struct AddWeightSheet: View {
    
    @Bindable var exercise: Exercise
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var value: Double?
    
    var body: some View {
        SingleValueEditView(
            textFieldPlaceholder: "Weight",
            buttonLabelText: "Save",
            number: $value,
            isButtonEnabled: isValueValid) {
            if let value = value, isValueValid {
                let weight = Weight(value: value)
                exercise.weights.append(weight)
            }
            dismiss()
        }
    }
    
    private var isValueValid: Bool {
        guard let value else { return false }
        return value.isFinite && value >= 0
    }
}
