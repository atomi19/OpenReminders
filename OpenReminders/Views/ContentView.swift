//
//  ContentView.swift
//  OpenReminders

import SwiftUI
import SwiftData

struct ContentView: View {
    @Query(sort: \Reminder.timeStamp)
    private var reminders: [Reminder]
    
    @State private var isShowingAddSheet = false
    @State private var searchText = ""
    
    @Environment(\.modelContext) private var context
    
    var body: some View {
        let remindersWithoutDate = reminders.filter {$0.dateReminder == nil}
        let remindersWithDate = reminders.filter {$0.dateReminder != nil}
        
        var filteredRemindersWithDate: [Reminder] {
            guard !searchText.isEmpty else { return remindersWithDate }
            return remindersWithDate.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.note.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        var filteredRemindersWithoutDate: [Reminder] {
            guard !searchText.isEmpty else { return remindersWithoutDate }
            return remindersWithoutDate.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.note.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        NavigationStack {
            List {
                // reminders without date
                if !filteredRemindersWithoutDate.isEmpty {
                    Section ("No Date") {
                        ForEach(filteredRemindersWithoutDate) { reminder in
                            ReminderRow(reminder: reminder)
                        }
                    }
                }
                
                // reminders with date
                if !filteredRemindersWithDate.isEmpty {
                    Section("Scheduled") {
                        ForEach(filteredRemindersWithDate) { reminder in
                            ReminderRow(reminder: reminder)
                        }
                    }
                }
            }
            .overlay {
                if reminders.isEmpty {
                    ContentUnavailableView {
                        Label("No reminders yet", systemImage: "exclamationmark.circle.fill")
                    } description: {
                        Text("Add reminders and they will appear here")
                    }
                } else if !searchText.isEmpty &&
                            filteredRemindersWithDate.isEmpty &&
                            filteredRemindersWithoutDate.isEmpty {
                    ContentUnavailableView {
                        Label("No reminders found", systemImage: "magnifyingglass")
                    } description: {
                        Text("Try searching by note or title")
                    }
                }
            }
            .sheet(isPresented: $isShowingAddSheet) {
                AddReminderView()
            }
            .navigationTitle("OpenReminders")
            .searchable(
                text: $searchText,
                prompt: "Search"
            )
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    Spacer()
                    Button("Add", systemImage: "plus") {
                        isShowingAddSheet.toggle()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
    }
}

struct ReminderRow: View {
    var reminder: Reminder
    
    @State private var isShowingEditSheet = false
    
    @Environment(\.modelContext) private var context
    
    var body: some View {
        HStack {
            Image(systemName: reminder.isDone ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(.secondary)
                .onTapGesture {
                    reminder.isDone.toggle()
                    
                    do {
                        try context.save()
                    } catch {
                        print(error)
                    }
                }
            VStack(alignment: .leading) {
                if reminder.dateReminder != nil {
                    if let date = reminder.dateReminder {
                        Text(date.formatted())
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                Text(reminder.title)
                    .strikethrough(reminder.isDone)
                if !reminder.note.isEmpty {
                    Text(reminder.note)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .sheet(isPresented: $isShowingEditSheet, content: {
            EditReminderView(reminder: reminder)
        })
        .swipeActions(edge: .trailing) {
            Button("Delete", systemImage: "trash", role: .destructive) {
                context.delete(reminder)
                
                do {
                    try context.save()
                } catch {
                    print(error)
                }
            }
            Button("Edit", systemImage: "pencil") {
                isShowingEditSheet = true
            }
            .tint(.orange)
        }
    }
}

#Preview {
    ContentView()
}
