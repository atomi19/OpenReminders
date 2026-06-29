//
//  ReminderRow.swift
//  OpenReminders

import SwiftUI
import SwiftData

struct ReminderRow: View {
    var reminder: Reminder
    let onEdit: (Reminder) -> Void
    
    private var isOverdue: Bool {
        if let date = reminder.dateReminder {
            return date < Date()
        } else {
            return false
        }
    }
    
    @State private var isShowingEditSheet = false
    
    @Environment(\.modelContext) private var context
    
    var body: some View {
        HStack(alignment: .top) {
            Image(systemName: reminder.isDone ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(.secondary)
                .onTapGesture {
                    reminder.isDone.toggle()
                    
                    if(reminder.isDone) {
                        // remove notification (reminder marked as completed)
                        if reminder.dateReminder != nil {
                            NotificationService.shared.removeNotification(uuid: reminder.uuid.uuidString)
                        }
                    } else {
                        // add notification back (reminder is not completed)
                        if let dateReminder = reminder.dateReminder {
                            NotificationService.shared.scheduleNotification(
                                uuid: reminder.uuid.uuidString,
                                title: reminder.title,
                                body: reminder.note,
                                date: dateReminder,
                                repeatOption: reminder.repeatOption ?? .never
                            )
                        }
                    }
                    
                    saveContext(context: context)
                }
            VStack(alignment: .leading) {
                Text(reminder.title)
                    .strikethrough(reminder.isDone)
                if !reminder.note.isEmpty {
                    Text(reminder.note)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                if reminder.dateReminder != nil {
                    if let date = reminder.dateReminder {
                        Text(date.formatted())
                            .font(.subheadline)
                            .foregroundStyle(isOverdue ? .red : .secondary)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        #if os(iOS) || os(watchOS)
        .swipeActions(edge: .leading) {
            pinButton
            .tint(.blue)
        }
        .swipeActions(edge: .trailing) {
            deleteButton
            editButton
            .tint(.orange)
        }
        #elseif os(macOS)
        .contextMenu {
            pinButton
            editButton
            Divider()
            deleteButton
        }
        #endif
    }
    
    private var pinButton: some View {
        Button(
            reminder.isPinned ? "Unpin" : "Pin",
            systemImage: reminder.isPinned ? "pin.slash" : "pin"
        ) {
            handleReminderPin(reminder: reminder)
        }
    }
    
    private var editButton: some View {
        Button("Edit", systemImage: "pencil") {
            onEdit(reminder)
        }
    }
    
    private var deleteButton: some View {
        Button("Delete", systemImage: "trash", role: .destructive) {
            handleReminderDelete(reminder: reminder)
        }
    }
    
    func handleReminderPin(reminder: Reminder) {
        reminder.isPinned.toggle()
        saveContext(context: context)
    }
    
    func handleReminderDelete(reminder: Reminder) {
        NotificationService.shared.removeNotification(uuid: reminder.uuid.uuidString)
        context.delete(reminder)
        saveContext(context: context)
    }
}
