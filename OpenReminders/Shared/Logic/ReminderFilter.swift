//
//  ReminderFilter.swift
//  OpenReminders

import Foundation

struct ReminderFilter {
    let now = Date()
    let calendar = Calendar.current
    
    func pinned(_ reminders: [Reminder]) -> [Reminder] {
        reminders.filter { $0.isPinned && !$0.isDone }
    }
    
    func overdue(_ reminders: [Reminder]) -> [Reminder] {
        reminders.filter {
            guard let date = $0.dateReminder else {return false}
            return date < now && !$0.isDone && !$0.isPinned
        }
    }
    
    func today(_ reminders: [Reminder]) -> [Reminder] {
        reminders.filter {
            guard let date = $0.dateReminder else {return false}
            return calendar.isDateInToday(date)
            && !$0.isDone
            && !$0.isPinned
            && date > now
        }
    }
    
    func tomorrow(_ reminders: [Reminder]) -> [Reminder] {
        reminders.filter {
            guard let date = $0.dateReminder else {return false}
            return calendar.isDateInTomorrow(date)
            && !$0.isDone
            && !$0.isPinned
        }
    }
    
    func upcoming(_ reminders: [Reminder]) -> [Reminder] {
        reminders.filter {
            guard let date = $0.dateReminder else {return false}
            return date > now &&
            !calendar.isDateInToday(date) &&
            !calendar.isDateInTomorrow(date) &&
            !$0.isDone &&
            !$0.isPinned
        }
    }
    func withoutDate(_ reminders: [Reminder]) -> [Reminder] {
        reminders.filter { $0.dateReminder == nil && !$0.isDone && !$0.isPinned }
    }
    
    func completed(_ reminders: [Reminder]) -> [Reminder] {
        reminders.filter { $0.isDone }
    }
}
