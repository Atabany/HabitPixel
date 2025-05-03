//
//  ReminderView.swift
//  HabitPixel
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
    let colors = AppColors.currentColorScheme
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                // Notification Toggle
                Toggle("Enable Reminders", isOn: $isNotificationEnabled)
                    .onChange(of: isNotificationEnabled) { oldValue, newValue in
                        if newValue {
                            requestNotificationPermission()
                        } else {
                            selectedDays.removeAll()
                        }
                    }
                    .padding(.horizontal)
                    .tint(colors.primary)
                
                if isNotificationEnabled {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("SELECT DAYS")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(colors.caption)
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
                                .foregroundColor(colors.primary)
                                .padding(.horizontal)
                        }
                    }
                    
                    if !selectedDays.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("REMINDER TIME")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(colors.caption)
                                .padding(.horizontal)
                            
                            DatePicker("", selection: $reminderTime, displayedComponents: .hourAndMinute)
                                .datePickerStyle(.wheel)
                                .labelsHidden()
                        }
                    }
                }
                
                Spacer()
            }
            .padding(.top, 20)
            .navigationTitle("Reminder")
            .navigationBarTitleDisplayMode(.large)
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
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                isNotificationEnabled = settings.authorizationStatus == .authorized
            }
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, _ in
            DispatchQueue.main.async {
                if !granted {
                    isNotificationEnabled = false
                    showingPermissionAlert = true
                }
            }
        }
    }
}

struct DayButton: View {
    let day: Day
    let isSelected: Bool
    let action: () -> Void
    let colors = AppColors.currentColorScheme
    
    var body: some View {
        Button(action: action) {
            Text(day.rawValue)
                .font(.headline)
                .fontWeight(.semibold)
                .frame(width: 44, height: 44)
                .background(isSelected ? colors.primary : colors.surface)
                .foregroundColor(isSelected ? colors.onPrimary : colors.onBackground)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(colors.primary, lineWidth: isSelected ? 0 : 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
