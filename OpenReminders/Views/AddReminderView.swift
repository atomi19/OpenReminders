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
        NavigationStack {
            contentSnack
            .background(Color(.secondarySystemBackground))
            .navigationTitle("Add Reminder")
            .toolbar {
                // cancel
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", systemImage: "xmark") {
                        if title.isEmpty, note.isEmpty {
                            dismiss()
                        } else {
                            isShowingCancelConfirmation = true
                        }
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
                    .disabled(title.isEmpty)
                }
            }
        }
        .scrollDismissesKeyboard(.interactively)
    }
    
    var contentSnack: some View {
        Form {
            Section {
                TextField("Title", text: $title)
                    .font(.title.bold())
                
                TextField("Note", text: $note, axis: .vertical)
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
                            await notificationsAllowed =  NotificationService.shared.requestNotificationPermission()
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

#Preview {
    AddReminderView()
}
