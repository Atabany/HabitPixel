import UserNotifications
import SwiftUI

class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()
    
    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    // Handle foreground notifications
    func userNotificationCenter(_ center: UNUserNotificationCenter, 
                              willPresent notification: UNNotification,
                              withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show banner and play sound when app is in foreground
        completionHandler([.banner, .sound])
    }
    
    func scheduleNotifications(for habit: HabitEntity) {
        // Remove existing notifications for this habit
        removeNotifications(for: habit)
        
        guard !habit.reminderDays.isEmpty,
              let reminderTime = habit.reminderTime else { return }
        
        let calendar = Calendar.current
        let timeComponents = calendar.dateComponents([.hour, .minute], from: reminderTime)
        
        for dayString in habit.reminderDays {
            guard let day = Day(rawValue: dayString) else { continue }
            let weekday = day.weekdayNumber
            let content = UNMutableNotificationContent()
            content.title = "Time for \(habit.title)"
            content.body = "Don't forget to maintain your habit streak!"
            content.sound = .default
            
            var dateComponents = DateComponents()
            dateComponents.hour = timeComponents.hour
            dateComponents.minute = timeComponents.minute
            dateComponents.weekday = weekday
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let identifier = "habit-\(habit.id)-\(dayString)"
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request)
        }
    }
    
    func removeNotifications(for habit: HabitEntity) {
        let identifiers = habit.reminderDays.map { "habit-\(habit.id)-\($0)" }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
    func removeAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
}
