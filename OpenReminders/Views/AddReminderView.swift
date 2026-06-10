//
//  AddReminderView.swift
//  OpenReminders

import SwiftUI
import SwiftData
import UserNotifications

struct AddReminderView: View {
    @State private var title = ""
    @State private var note = ""
    
    @State private var isShowingCancelConfirmation = false
    @State private var notificationsAllowed = false
    @State private var isRemindEnabled = false
    @State private var date = Date()
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    var body: some View {
        ReminderFormView(
            reminder: nil,
            title: $title,
            note: $note,
            date: $date,
            isRemindEnabled: $isRemindEnabled,
            navigationTitle: "Add Reminder",
            onConfirm: save
        )
    }
    
    func save() {
        let newReminder = Reminder(
            title: title,
            note: note,
            isDone: false,
            timeStamp: .now,
            dateReminder: isRemindEnabled ? date : nil,
        )

        context.insert(newReminder)

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

#Preview {
    AddReminderView()
}
