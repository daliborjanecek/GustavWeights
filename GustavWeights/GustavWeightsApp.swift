//
//  GustavWeightsApp.swift
//  GustavWeights
//
//  Created by Dalibor Janeček on 10.03.2024.
//

import SwiftUI
import SwiftData
import GustavUICore

@main
struct GustavWeightsApp: App {
    
    init() {
        // Martian fonts and Gustav colors come from the shared GustavUI package.
        GustavDesign.registerFonts()
    }
    
    let container: ModelContainer = {
        let schema = Schema([Exercise.self])
        let container = try! ModelContainer(for: schema, configurations: [])
        return container
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
}
