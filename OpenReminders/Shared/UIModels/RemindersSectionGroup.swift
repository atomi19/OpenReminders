//
//  RemindersSectionGroup.swift
//  OpenReminders

import Foundation

struct RemindersSectionGroup: Identifiable {
    let id = UUID()
    var title: String
    var remindersList: [Reminder]
    var isExpandable: Bool
}
