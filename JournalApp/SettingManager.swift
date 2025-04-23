//
//  SettingManager.swift
//  JournalApp
//
//  Created by Kristina Yaroshenko on 23.04.2025.
//

import UserNotifications

class SettingsManager: ObservableObject {
    static let shared = SettingsManager()
    
    func explainNotificationsFirst() {
        permissionAlertMessage = "Daily reminders require notification permissions. We'll only use them for your journal reminders."
        showPermissionAlert = true
    }
    
    @Published var dailyReminderEnabled: Bool {
        didSet {
            UserDefaults.standard.set(dailyReminderEnabled, forKey: "dailyReminderEnabled")
            if dailyReminderEnabled {
                explainNotificationsFirst()
            } else {
                cancelReminders()
            }
        }
    }
    
    @Published var dailyReminderTime: Date {
        didSet {
            UserDefaults.standard.set(dailyReminderTime, forKey: "dailyReminderTime")
            if dailyReminderEnabled {
                updateReminder()
            }
        }
    }
    
    @Published var showPermissionAlert = false
    @Published var permissionAlertMessage = ""
    
    private init() {
        self.dailyReminderEnabled = UserDefaults.standard.bool(forKey: "dailyReminderEnabled")
        
        if let savedTime = UserDefaults.standard.object(forKey: "dailyReminderTime") as? Date {
            self.dailyReminderTime = savedTime
        } else {
            // Default to 8 PM
            var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
            components.hour = 20
            components.minute = 0
            self.dailyReminderTime = Calendar.current.date(from: components) ?? Date()
        }
    }
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .notDetermined:
                    // First time - ask for permission
                    self.askForNotificationPermission()
                case .denied:
                    // Previously denied - show alert
                    self.showPermissionAlert(message: "Notifications are disabled. Please enable them in Settings to get reminders.")
                case .authorized, .provisional, .ephemeral:
                    // Already authorized - schedule reminders
                    if self.dailyReminderEnabled {
                        self.updateReminder()
                    }
                @unknown default:
                    break
                }
            }
        }
    }
    
    private func askForNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.showPermissionAlert(message: "Error: \(error.localizedDescription)")
                    return
                }
                
                if granted {
                    if self.dailyReminderEnabled {
                        self.updateReminder()
                    }
                } else {
                    self.dailyReminderEnabled = false
                    self.showPermissionAlert(message: "Notifications are disabled. You won't receive reminders.")
                }
            }
        }
    }
    
    private func showPermissionAlert(message: String) {
        permissionAlertMessage = message
        showPermissionAlert = true
    }
    
    private func updateReminder() {
        cancelReminders()
        scheduleDailyReminder()
    }
    
    private func cancelReminders() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    private func scheduleDailyReminder() {
        let content = UNMutableNotificationContent()
        content.title = "Time for Your Daily Journal"
        content.body = "Don't forget to write your daily journal entry!"
        content.sound = UNNotificationSound.default
        
        let components = Calendar.current.dateComponents([.hour, .minute], from: dailyReminderTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: "dailyJournalReminder",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling daily reminder: \(error.localizedDescription)")
            } else {
                print("Daily reminder scheduled for \(components.hour!):\(components.minute!)")
            }
        }
    }
}
