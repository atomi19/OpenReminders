//
//  EditReminderView.swift
//  OpenReminders

import SwiftUI
import SwiftData

struct EditReminderView: View {
    @Bindable var reminder: Reminder
 
    @State private var title: String
    @State private var note: String
    @State private var date: Date
    @State private var isRemindEnabled: Bool
    
    @State private var notificationsAllowed = false
    @State private var isShowingCancelConfirmation = false
    
    init(reminder: Reminder) {
        self.reminder = reminder
        _title = State(initialValue: reminder.title)
        _note = State(initialValue: reminder.note)
        _date = State(initialValue: reminder.dateReminder ?? .now)
        _isRemindEnabled = State(initialValue: reminder.dateReminder != nil)
    }
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    var body: some View {
        ReminderFormView(
            reminder: reminder,
            title: $title,
            note: $note,
            date: $date,
            isRemindEnabled: $isRemindEnabled,
            navigationTitle: "Edit Reminder",
            onConfirm: save
        )
    }
    
    func save() {
        reminder.title = title
        reminder.note = note
        reminder.dateReminder = isRemindEnabled ? date : nil

        if(isRemindEnabled) {
            NotificationService.shared.scheduleNotification(
                title: title,
                body: note,
                date: date
            )
        }

        do {
            try context.save()
        } catch {
            print(error)
        }
        dismiss()
    }
}
