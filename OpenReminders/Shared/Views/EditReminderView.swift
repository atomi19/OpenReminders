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
    @State private var selectedRepeatOption: RepeatOptions
    
    @State private var notificationsAllowed = false
    @State private var isShowingCancelConfirmation = false
    
    init(reminder: Reminder) {
        self.reminder = reminder
        _title = State(initialValue: reminder.title)
        _note = State(initialValue: reminder.note)
        _date = State(initialValue: reminder.dateReminder ?? .now)
        _isRemindEnabled = State(initialValue: reminder.dateReminder != nil)
        _selectedRepeatOption = State(initialValue: reminder.repeatOption ?? .never)
    }
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    var body: some View {
        ReminderFormView(
            isAddingReminder: false,
            reminder: reminder,
            title: $title,
            note: $note,
            date: $date,
            isRemindEnabled: $isRemindEnabled,
            onConfirm: save,
            selectedRepeatOption: $selectedRepeatOption
        )
    }
    
    func save() {
        reminder.title = title
        reminder.note = note
        reminder.dateReminder = isRemindEnabled ? date : nil
        reminder.repeatOption = selectedRepeatOption

        if(isRemindEnabled) {
            NotificationService.shared.scheduleNotification(
                uuid: reminder.uuid.uuidString,
                title: title,
                body: note,
                date: date,
                repeatOption: selectedRepeatOption
            )
        }
        
        saveContext(context: context)
    }
}
