//
//  OpenRemindersApp.swift
//  OpenReminders
//
//  Created by Anton on 04.06.2026.
//

import SwiftUI
import SwiftData

@main
struct OpenRemindersApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Reminder.self)
    }
}
