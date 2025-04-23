//
//  SettingView.swift
//  JournalApp
//
//  Created by Kristina Yaroshenko on 23.04.2025.
//

import SwiftUICore
import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings = SettingsManager.shared
    @State private var showingSettingsAlert = false
    
    var body: some View {
        Form {
            Section(header: Text("Daily Reminder")) {
                Toggle("Enable Daily Reminder", isOn: $settings.dailyReminderEnabled)
                
                if settings.dailyReminderEnabled {
                    DatePicker(
                        "Reminder Time",
                        selection: $settings.dailyReminderTime,
                        displayedComponents: .hourAndMinute
                    )
                    .datePickerStyle(WheelDatePickerStyle())
                }
            }
        }
        .navigationTitle("Settings")
        .alert(isPresented: $settings.showPermissionAlert) {
            Alert(
                title: Text("Notification Permission"),
                message: Text(settings.permissionAlertMessage),
                primaryButton: .default(Text("Open Settings")) {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                },
                secondaryButton: .cancel()
            )
        }
    }
}
