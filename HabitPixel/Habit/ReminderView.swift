//
//  ReminderView.swift
//  HabitPixel
//
//  Created by Mohamed Elatabany on 22/03/2025.
//

import SwiftUI

struct ReminderView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedDays: Set<Day>
    @State private var reminderTime = Date()
    let colors = AppColors.currentColorScheme
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
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
                
                Spacer()
            }
            .padding(.top, 20)
            .navigationTitle("Reminder")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private func toggleAllDays() {
        if selectedDays.count == Day.allCases.count {
            selectedDays.removeAll()
        } else {
            selectedDays = Set(Day.allCases)
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
