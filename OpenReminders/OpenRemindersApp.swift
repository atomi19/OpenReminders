//
//  OpenRemindersApp.swift
//  OpenReminders

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
