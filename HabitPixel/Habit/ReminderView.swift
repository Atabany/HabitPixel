//
//  ReminderView.swift
//  HabitRix
//
//  Created by Mohamed Elatabany on 22/03/2025.
//

import SwiftUI
import UserNotifications

struct ReminderView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedDays: Set<Day>
    @Binding var reminderTime: Date
    @State private var showingPermissionAlert = false
    @State private var isNotificationEnabled = false
    @State private var isCheckingPermission = true
    
    private let notificationManager = NotificationManager.shared
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    // Notification Toggle
                    Toggle("Enable Reminders", isOn: $isNotificationEnabled)
                        .onChange(of: isNotificationEnabled) { oldValue, newValue in
                            if newValue {
                                requestNotificationPermission()
                            } else {
                                selectedDays.removeAll()
                                notificationManager.removeAllNotifications()
                            }
                        }
                        .padding(.horizontal)
                        .tint(Color.theme.primary)
                    
                    if isNotificationEnabled {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("SELECT DAYS")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(Color.theme.caption)
                                .padding(.horizontal)
                            
                            HStack(spacing: 8) {
                                ForEach(Day.allCases) { day in
                                    DayButton(day: day, isSelected: selectedDays.contains(day)) {
                                        if selectedDays.contains(day) {
                                            selectedDays.remove(day)
                                        } else {
                                            selectedDays.insert(day)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                            
                            Button(action: toggleAllDays) {
                                Text(selectedDays.count == Day.allCases.count ? "Clear All" : "Select All")
                                    .font(.subheadline)
                                    .foregroundColor(Color.theme.primary)
                                    .padding(.horizontal)
                            }
                        }
                        
                        if !selectedDays.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("REMINDER TIME")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(Color.theme.caption)
                                    .padding(.horizontal)
                                
                                DatePicker("", selection: $reminderTime, displayedComponents: .hourAndMinute)
                                    .datePickerStyle(.wheel)
                                    .labelsHidden()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.theme.surface)
                                    .cornerRadius(12)
                                    .padding(.horizontal)
                            }
                        }
                    }
                }
                .padding(.top, 20)
            }
            .navigationTitle("Reminder")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Notification Permission Required", isPresented: $showingPermissionAlert) {
                Button("Settings", role: .none) {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Please enable notifications in Settings to use reminders")
            }
            .onAppear {
                checkNotificationStatus()
            }
        }
    }
    
    private func toggleAllDays() {
        if selectedDays.count == Day.allCases.count {
            selectedDays.removeAll()
        } else {
            selectedDays = Set(Day.allCases)
        }
    }
    
    private func checkNotificationStatus() {
        isCheckingPermission = true
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                isNotificationEnabled = settings.authorizationStatus == .authorized
                isCheckingPermission = false
            }
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                if !granted {
                    isNotificationEnabled = false
                    showingPermissionAlert = true
                }
                if let error = error {
                    print("Notification permission error: \(error.localizedDescription)")
                }
            }
        }
    }
}

struct DayButton: View {
    let day: Day
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(day.rawValue)
                .font(.headline)
                .fontWeight(.semibold)
                .frame(width: 44, height: 44)
                .background(isSelected ? Color.theme.primary : Color.theme.surface)
                .foregroundColor(isSelected ? .white : Color.theme.onBackground)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color.theme.primary, lineWidth: isSelected ? 0 : 1)
                )
                .shadow(color: isSelected ? Color.theme.primary.opacity(0.3) : .clear, radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
