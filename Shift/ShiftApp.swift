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
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Company.self,
            Shift.self,
            Holiday.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    


    var body: some Scene {
        WindowGroup {
            MainTabView()
                .onAppear {
                    print(URL.applicationSupportDirectory.path(percentEncoded: false))
                }
        }
        .modelContainer(sharedModelContainer)
        
    }
}
