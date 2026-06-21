//
//  NotificationService.swift
//  OpenReminders

import UserNotifications

class NotificationService {
    static let shared = NotificationService()
    
    func requestNotificationPermission() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
        } catch {
            print("Permission request failed: \(error)")
            return false
        }
    }
    
    func scheduleNotification(
        uuid: String,
        title: String,
        body: String,
        date: Date,
        repeatOption: RepeatOptions
    ) {
        let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            content.sound = .default
        
        var dateComponents = DateComponents()
        
        switch repeatOption {
        case .never:
            dateComponents = Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute, .second],
                from: date
            )
        case .hourly:
            dateComponents = Calendar.current.dateComponents(
                [.minute],
                from: date
            )
        case .daily:
            dateComponents = Calendar.current.dateComponents(
                [.hour, .minute],
                from: date
            )
        case .weekly:
            dateComponents = Calendar.current.dateComponents(
                [.weekday, .hour, .minute],
                from: date
            )
        case .monthly:
            dateComponents = Calendar.current.dateComponents(
                [.day, .hour, .minute],
                from: date
            )
        case .yearly:
            dateComponents = Calendar.current.dateComponents(
                [.month, .day, .hour, .minute],
                from: date
            )
        }
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: repeatOption == .never ? false : true,
        )
        
        let request = UNNotificationRequest(
            identifier: uuid,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            #if DEBUG
            if let error {
                print("Failed to add request: \(error)")
            }
            #endif
        }
    }
    
    func removeNotification(uuid: String) {
        let center = UNUserNotificationCenter.current()
        
        center.removePendingNotificationRequests(withIdentifiers: [uuid])
        center.removeDeliveredNotifications(withIdentifiers: [uuid])
    }
}
