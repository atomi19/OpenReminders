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
        NavigationStack {
            contentSnack
                .navigationTitle("Edit Reminder")
                .toolbar {
                    // cancel
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel", systemImage: "xmark") {
                            dismiss()
                        }
                        .confirmationDialog("Discard Reminder", isPresented: $isShowingCancelConfirmation) {
                            Button("Discard Reminder", role: .destructive) {
                                dismiss()
                            }
                        }
                    }
                    // confirm
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Confirm", systemImage: "checkmark") {
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
                        .disabled(title.isEmpty)
                    }
                }
                .task {
                    notificationsAllowed = await NotificationService.shared.requestNotificationPermission()
                }
        }
    }
    
    var contentSnack: some View {
        Form {
            Section {
                TextField("Edit title", text: $title)
                    .font(.title.bold())
                
                TextField("Edit note", text: $note, axis: .vertical)
                    .multilineTextAlignment(.leading)
                    .lineLimit(5)
                    .font(.default)
            }
            
            Section("Date & Time") {
                Toggle(
                    "Remind",
                    systemImage: "calendar",
                    isOn: $isRemindEnabled,
                )
                .onChange(of: isRemindEnabled) { oldValue, newValue in
                    if newValue {
                        Task {
                            await notificationsAllowed = NotificationService.shared.requestNotificationPermission()
                        }
                    }
                }
                if isRemindEnabled {
                    DatePicker(
                        "Remind at",
                        selection: $date
                    )
                    if !notificationsAllowed {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundStyle(.orange)
                            Text("Notifications permission denied")
                                .font(.caption)
                        }
                    }
                }
            }
        }
    }
}
