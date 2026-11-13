//
//  SingleValueEditView.swift
//  GustavWeights
//
//  Created by Dalibor Janeček on 16.03.2024.
//

import SwiftUI
import GustavUICore

struct SingleValueEditView: View {
    
    enum FocusedField {
        case weight
    }
    
    var textFieldPlaceholder: String
    var buttonLabelText: String
    var isButtonEnabled: Bool
    
    @Binding var number: Double?
    @Binding var text: String?
    @FocusState private var focusedField: FocusedField?
    
    var buttonFunction: () -> ()
    
    init(textFieldPlaceholder: String, buttonLabelText: String, number: Binding<Double?>?, isButtonEnabled: Bool = true, focusedField: FocusedField? = nil, buttonFunction: @escaping () -> Void) {
        self.textFieldPlaceholder = textFieldPlaceholder
        self.buttonLabelText = buttonLabelText
        self.isButtonEnabled = isButtonEnabled
        self._number = number ?? Binding.constant(nil)
        self._text = Binding.constant(nil)
        self._focusedField = FocusState()
        self.buttonFunction = buttonFunction
    }
    
    init(textFieldPlaceholder: String, buttonLabelText: String, text: Binding<String>, isButtonEnabled: Bool = true, focusedField: FocusedField? = nil, buttonFunction: @escaping () -> Void) {
        self.textFieldPlaceholder = textFieldPlaceholder
        self.buttonLabelText = buttonLabelText
        self.isButtonEnabled = isButtonEnabled
        self._number = Binding.constant(nil)
        self._text = Binding(text)
        self._focusedField = FocusState()
        self.buttonFunction = buttonFunction
    }
    
    var body: some View {
            VStack {
                Spacer()
                if text == nil {
                    TextField(textFieldPlaceholder.uppercased(), value: $number, format: .number)
                        .keyboardType(.decimalPad)
                        .font(Font.custom("MartianMono-Bold", size: 30))
                        .focused($focusedField, equals: .weight)
                        .multilineTextAlignment(.center)
                        .onAppear() {
                            focusedField = .weight
                        }
                } else {
                    TextField(textFieldPlaceholder, text: $text.toUnwrapped(defaultValue: ""))
                        .keyboardType(.default)
                        .autocorrectionDisabled(true)
                        .textCase(.uppercase)
                        .font(Font.custom("MartianMono-Bold", size: 30))
                        .focused($focusedField, equals: .weight)
                        .multilineTextAlignment(.center)
                        .submitLabel(.done)
                        .onSubmit {
                            if isButtonEnabled {
                                buttonFunction()
                            }
                        }
                        .onAppear {
                            focusedField = .weight
                        }
                }
                Spacer()
                Button(action: buttonFunction,
                       label: {
                    Color.gustavVolt
                        .overlay {
                            Text(buttonLabelText)
                                .foregroundStyle(Color.gustavNeutral)
                        }
                        .frame(height: 80)
                        .opacity(isButtonEnabled ? 1.0 : 0.4)
                })
                .disabled(!isButtonEnabled)
            }
        }
    }


extension Binding {
     func toUnwrapped<T>(defaultValue: T) -> Binding<T> where Value == Optional<T>  {
        Binding<T>(get: { self.wrappedValue ?? defaultValue }, set: { self.wrappedValue = $0 })
    }
}

//#Preview {
//    SingleValueEditView()
//}
