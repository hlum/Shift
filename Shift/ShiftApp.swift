//
//  ShiftApp.swift
//  Shift
//
//  Created by cmStudent on 2025/05/02.
//

import SwiftUI
import SwiftData

@main
struct ShiftApp: App {
    private let container: ContainerProtocol
    
    init() {
        let schema = Schema([
            Company.self,
            Shift.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            let modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
            self.container = DependencyContainer(modelContainer: modelContainer)
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .injectDependencies(container)
                .onAppear {
                    print(URL.applicationSupportDirectory.path(percentEncoded: false))
                }
        }
        .modelContainer(container.modelContext.container)
    }
}
