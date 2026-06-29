//
//  OpenReminders_Watch_App.swift
//  OpenReminders Watch App

import SwiftUI
import SwiftData

@main
struct OpenReminders_Watch_App: App {
    var body: some Scene {
        WindowGroup {
            WatchHomeView()
        }
        .modelContainer(for: Reminder.self)
    }
}
