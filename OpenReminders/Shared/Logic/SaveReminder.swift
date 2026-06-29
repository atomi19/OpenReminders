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
    repeatOption: RepeatOptions,
    context: ModelContext,
) {
    let newReminder = Reminder(
        title: title,
        note: note,
        isDone: false,
        timeStamp: .now,
        dateReminder: isRemindEnabled ? date : nil,
        isPinned: false,
        repeatOption: repeatOption
    )

    context.insert(newReminder)

    if isRemindEnabled, let date = date {
        NotificationService.shared.scheduleNotification(
            uuid: newReminder.uuid.uuidString,
            title: title,
            body: note,
            date: date,
            repeatOption: repeatOption
        )
    }

    saveContext(context: context)
}
