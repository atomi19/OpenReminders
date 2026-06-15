//
//  SaveReminder.swift
//  OpenReminders

import Foundation
import SwiftData
import SwiftUI

func saveReminder(
    title: String,
    note: String,
    isDone: Bool,
    isRemindEnabled: Bool,
    date: Date?,
    context: ModelContext,
    dismiss: DismissAction
) {
    let newReminder = Reminder(
        title: title,
        note: note,
        isDone: false,
        timeStamp: .now,
        dateReminder: isRemindEnabled ? date : nil,
    )

    context.insert(newReminder)

    if isRemindEnabled, let date = date {
        NotificationService.shared.scheduleNotification(
            uuid: newReminder.uuid.uuidString,
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
