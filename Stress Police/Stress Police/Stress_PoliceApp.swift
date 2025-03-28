//
//  Stress_PoliceApp.swift
//  Stress Police
//
//  Created by Saketh Reddy on 17/02/25.
//

import SwiftUI

@main
struct Stress_PoliceApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
