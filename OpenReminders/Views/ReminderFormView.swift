//
//  ReminderFormView.swift
//  OpenReminders

import SwiftUI
import SwiftData

struct ReminderFormView: View {
    let isAddingReminder: Bool
    let reminder: Reminder?
    
    @Binding var title: String
    @Binding var note: String
    @Binding var date: Date
    @Binding var isRemindEnabled: Bool
    @Binding var selectedRepeatOption: RepeatOptions
    
    var onConfirm: () -> Void
    
    init(isAddingReminder: Bool,
         reminder: Reminder?,
         title: Binding<String>,
         note: Binding<String>,
         date: Binding<Date>,
         isRemindEnabled: Binding<Bool>,
         onConfirm: @escaping () -> Void,
         notificationsAllowed: Bool = false,
         selectedRepeatOption: Binding<RepeatOptions>
    ) {
        self.isAddingReminder = isAddingReminder
        self.reminder = reminder
        
        _title = title
        _note = note
        _date = date
        _isRemindEnabled = isRemindEnabled
        _selectedRepeatOption = selectedRepeatOption
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
                .navigationTitle(isAddingReminder ? "Add Reminder" : "Edit Reminder")
            #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
            #endif
                .toolbar {
                    // cancel
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel", systemImage: "xmark") {
                            if isAddingReminder && (!title.isEmpty || !note.isEmpty) {
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
                            dismiss()
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
        #if os(iOS)
        Form {
            Section {
                reminderTitleAndNote
            }
            
            Section("Date & Time") {
                reminderSection
            }
        }
        #elseif os(macOS)
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                reminderTitleAndNote
                
                reminderSection
            }
            .padding()
        }
        #endif
    }
    
    @ViewBuilder
    private var reminderTitleAndNote: some View {
        TextField("Title", text: $title)
            .font(.title.bold())
        
        TextField("Note", text: $note, axis: .vertical)
            .multilineTextAlignment(.leading)
            .lineLimit(5)
            .font(.default)
    }
    
    @ViewBuilder
    private var reminderSection: some View {
        Toggle(isOn: $isRemindEnabled) {
            Label {
                Text("Remind")
            } icon: {
                Image(systemName: "calendar")
                    .foregroundStyle(.secondary)
            }
        }
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
            Picker("Repeat", selection: $selectedRepeatOption) {
                ForEach(RepeatOptions.allCases) { repeatOption in
                    if repeatOption == .never {
                        Text(repeatOption.rawValue.capitalized)
                        Divider()
                    } else {
                        Text(repeatOption.rawValue.capitalized)
                    }
                }
            }
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
