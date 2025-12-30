//
//  GustavWeightsApp.swift
//  GustavWeights
//
//  Created by Dalibor Janeček on 10.03.2024.
//

import SwiftUI
import SwiftData

@main
struct GustavWeightsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: TrainingModel.self)
    }
}
