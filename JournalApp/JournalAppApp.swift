//
//  JournalAppApp.swift
//  JournalApp
//
//  Created by Kristina Yaroshenko on 23.04.2025.
//

import SwiftUI
import UserNotifications

@main
struct JournalAppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    // Check notification status on app launch
                    SettingsManager.shared.requestNotificationPermission()
                }
        }
    }
}
