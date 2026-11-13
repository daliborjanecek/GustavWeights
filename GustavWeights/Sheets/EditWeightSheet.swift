//
//  EditWeightSheet.swift
//  GustavWeights
//
//  Created by Dalibor Janeček on 16.03.2024.
//

import SwiftUI

struct EditWeightSheet: View {
    @Bindable var weight: Weight
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) var context
    
    var body: some View {
        NavigationStack {
                Form {
                    HStack {
                        TextField("Weight", value: $weight.value, format: .number)
                            .keyboardType(.decimalPad)
                        Text("kg")
                            .foregroundStyle(.secondary)
                    }
                    // Lets you fix the date of an entry or log a session afterwards.
                    DatePicker("Date",
                               selection: $weight.date,
                               in: ...Date.now,
                               displayedComponents: [.date, .hourAndMinute])
                }
            
            .navigationTitle("Edit weight")
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
}
