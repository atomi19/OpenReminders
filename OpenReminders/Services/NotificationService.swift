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
    
    // at date: Date
    func scheduleNotification(
        title: String,
        body: String,
        date: Date,
    ) {
        let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            content.sound = .default
        
        let dateComponents = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: date
        )
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: false,
        )
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) {error in
            if let error {
                print("Failed to add request: \(error)")
            } else {
                print("Notification added")
            }
        }
    }
}
