//
//  NoSearchResultsView.swift
//  OpenReminders

import SwiftUI

struct NoSearchResultsView: View {
    var body: some View {
        ContentUnavailableView {
            Label("No reminders found", systemImage: "magnifyingglass")
        } description: {
            Text("Try searching by note or title")
        }
    }
}
