//
//  RepeatOptions.swift
//  OpenReminders

enum RepeatOptions: String, CaseIterable, Identifiable, Codable {
    case never, hourly, daily, weekly, monthly, yearly
    var id: Self { self }
}
