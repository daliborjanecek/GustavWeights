//
//  ExerciseSettingsView.swift
//  GustavWeights
//
//  Name, unit and direction of an exercise. The same fields are used
//  when adding a new exercise and when editing one in the detail.
//

import SwiftUI
import GustavUICore

/// Form sections for the exercise settings. Put them inside a `Form`.
struct ExerciseSettingsFields: View {
    @Binding var name: String
    @Binding var unit: ExerciseUnit
    @Binding var higherIsBetter: Bool
    /// True for an existing exercise: changing its unit doesn't convert logged values.
    var hasEntries = false
    /// Puts the cursor into the name field right away (new exercise).
    var focusesName = false

    @FocusState private var isNameFocused: Bool

    var body: some View {
        Section {
            TextField("Exercise name", text: $name)
                .autocorrectionDisabled(true)
                .textInputAutocapitalization(.words)
                .focused($isNameFocused)
        } header: {
            sectionHeader("NAME")
        }
        .task {
            guard focusesName else { return }
            // Focusing during the sheet's presentation animation is ignored.
            try? await Task.sleep(for: .milliseconds(400))
            isNameFocused = true
        }

        Section {
            ForEach(ExerciseUnit.allCases) { option in
                checkmarkRow(option.title, isSelected: unit == option) {
                    unit = option
                }
            }
        } header: {
            sectionHeader("UNIT")
        } footer: {
            sectionFooter(hasEntries
                          ? "Use Repetitions for exercises like pull-ups. Changing the unit only relabels the logged entries, it doesn't convert them."
                          : "Use Repetitions for exercises like pull-ups, where only the count matters.")
        }

        Section {
            checkmarkRow("Higher is better", isSelected: higherIsBetter) {
                higherIsBetter = true
            }
            checkmarkRow("Lower is better", isSelected: !higherIsBetter) {
                higherIsBetter = false
            }
        } header: {
            sectionHeader("BETTER RESULT")
        } footer: {
            sectionFooter("Decides which entry is your PR. Choose Lower is better e.g. for the time of a run.")
        }
    }

    /// Settings-style option row: the selected one has a checkmark at the trailing edge.
    private func checkmarkRow(_ title: LocalizedStringKey,
                              isSelected: Bool,
                              action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .foregroundStyle(Color.primary)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .fontWeight(.semibold)
                        .foregroundStyle(.tint)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: isSelected) { _, selected in selected }
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private func sectionHeader(_ title: LocalizedStringKey) -> some View {
        Text(title)
            .font(.sectionHeader)
            .foregroundStyle(Color.gustavNeutral)
    }

    private func sectionFooter(_ text: LocalizedStringKey) -> some View {
        Text(text)
            .font(.sectionFooter)
            .foregroundStyle(Color.gustavNeutral)
    }
}

/// Settings of an existing exercise, pushed from the detail sheet.
/// Changes are saved right away.
struct ExerciseSettingsView: View {
    @Bindable var exercise: Exercise

    @State private var name = ""

    var body: some View {
        Form {
            ExerciseSettingsFields(name: $name,
                                   unit: $exercise.unit,
                                   higherIsBetter: $exercise.higherIsBetter,
                                   hasEntries: !exercise.weights.isEmpty)
        }
        .font(.gustavBody)
        .navigationTitle("Exercise settings")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            name = exercise.name
        }
        .onChange(of: name) {
            // Never store an empty name, the card would be blank.
            let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.isEmpty {
                exercise.name = trimmed
            }
        }
    }
}
