//
//  ReminderSection.swift
//  OpenReminders

import SwiftUI

struct ReminderSection: View {
    var sectionTitle: String
    var remindersList: [Reminder]
    var isExpandable: Bool
    let onEdit: (Reminder) -> Void
    
    @State private var isExpanded: Bool = false
    
    var body: some View {
        if !remindersList.isEmpty {
            if isExpandable {
                Section("\(sectionTitle) (\(remindersList.count))", isExpanded: $isExpanded) {
                    handleReminder
                }
            } else {
                Section("\(sectionTitle) (\(remindersList.count))") {
                    handleReminder
                }
            }
        }
    }
    
    private var handleReminder: some View {
        ForEach(remindersList) { reminder in
            ReminderRow(
                reminder: reminder,
                onEdit: onEdit
            )
        }
    }
}
