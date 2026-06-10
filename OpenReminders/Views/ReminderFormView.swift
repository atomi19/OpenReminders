//
//  ReminderFormView.swift
//  OpenReminders

import SwiftUI
import SwiftData

struct ReminderFormView: View {
    let reminder: Reminder?
    
    @Binding var title: String
    @Binding var note: String
    @Binding var date: Date
    @Binding var isRemindEnabled: Bool
    
    var navigationTitle: String
    var onConfirm: () -> Void
    
    init(reminder: Reminder?, title: Binding<String>, note: Binding<String>, date: Binding<Date>, isRemindEnabled: Binding<Bool>, navigationTitle: String, onConfirm: @escaping () -> Void, notificationsAllowed: Bool = false,) {
        self.reminder = reminder
        
        _title = title
        _note = note
        _date = date
        _isRemindEnabled = isRemindEnabled
        self.navigationTitle = navigationTitle
        self.onConfirm = onConfirm
        self.notificationsAllowed = notificationsAllowed
    }
    
    @State var notificationsAllowed = false
    @State var isShowingCancelConfirmation = false
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    var body: some View {
        NavigationStack {
            contentSnack
                .navigationTitle(navigationTitle)
                .toolbar {
                    // cancel
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel", systemImage: "xmark") {
                            if !title.isEmpty || !note.isEmpty {
                                isShowingCancelConfirmation = true
                            } else {
                                dismiss()
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
                            onConfirm()
                        }
                        .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }
                .task {
                    notificationsAllowed = await NotificationService.shared.requestNotificationPermission()
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
