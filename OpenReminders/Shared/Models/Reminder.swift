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
    // optional to migrate old data 
    var repeatOption: RepeatOptions? = RepeatOptions.never
    
    init(title: String, note: String, isDone: Bool, timeStamp: Date, dateReminder: Date? = nil, isPinned: Bool, repeatOption: RepeatOptions? = .never) {
        self.title = title
        self.note = note
        self.isDone = isDone
        self.timeStamp = timeStamp
        self.dateReminder = dateReminder
        self.isPinned = isPinned
        self.repeatOption = repeatOption
    }
}
