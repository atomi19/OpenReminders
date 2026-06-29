//
//  FilteredReminders.swift
//  OpenReminders

import Foundation

// search reminders in through given reminders
func filteredReminders(searchText: String, remindersList: [Reminder]) -> [Reminder] {
    guard !searchText.isEmpty else {return remindersList}
    
    return remindersList.filter {
        $0.title.localizedCaseInsensitiveContains(searchText) ||
        $0.note.localizedCaseInsensitiveContains(searchText)
    }
}
