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
    @State private var repeatOption: RepeatOptions = .never
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    var body: some View {
        ReminderFormView(
            isAddingReminder: true,
            reminder: nil,
            title: $title,
            note: $note,
            date: $date,
            isRemindEnabled: $isRemindEnabled,
            onConfirm: save,
            selectedRepeatOption: $repeatOption
        )
    }
    
    func save() {
        saveReminder(
            title: title,
            note: note,
            isDone: false,
            isRemindEnabled: isRemindEnabled,
            date: date,
            repeatOption: repeatOption,
            context: context,
        )
    }
}

#Preview {
    AddReminderView()
}
