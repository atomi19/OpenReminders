//
//  NoRemindersView.swift
//  OpenReminders

import SwiftUI

struct NoRemindersView: View {
    var body: some View {
        ContentUnavailableView {
            Label("No reminders yet", systemImage: "exclamationmark.circle.fill")
        } description: {
            Text("Add reminders and they will appear here")
        }
    }
}
