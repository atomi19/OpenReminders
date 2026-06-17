//
//  ReminderModel.swift
//  OpenReminders

import Foundation
import SwiftData

@Model
class Reminder {
    var uuid: UUID = UUID()
    var title: String
    var note: String
    var isDone: Bool
    var timeStamp: Date
    var dateReminder: Date?
    var isPinned: Bool = false
    
    init(title: String, note: String, isDone: Bool, timeStamp: Date, dateReminder: Date? = nil, isPinned: Bool) {
        self.title = title
        self.note = note
        self.isDone = isDone
        self.timeStamp = timeStamp
        self.dateReminder = dateReminder
        self.isPinned = isPinned
    }
}
