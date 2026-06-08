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
        let overdueReminders = reminders.filter {
            guard let date = $0.dateReminder else {return false}
            return date < Date()
        }
        
        let remindersToday = reminders.filter {
            guard let date = $0.dateReminder else {return false}
            return Calendar.current.isDateInToday(date) && !$0.isDone && date > Date()
        }
        
        let remindersTomorrow = reminders.filter {
            guard let date = $0.dateReminder else {return false}
            return Calendar.current.isDateInTomorrow(date) && !$0.isDone
        }
        
        let upcomingReminders = reminders.filter{
            guard let date = $0.dateReminder else {return false}
            return date > Date() &&
            !Calendar.current.isDateInToday(date) &&
            !Calendar.current.isDateInTomorrow(date) &&
            !$0.isDone
        }
        
        let remindersWithoutDate = reminders.filter {
            $0.dateReminder == nil && !$0.isDone
        }
        
        let completeReminders = reminders.filter {$0.isDone}
        
        let sectionGroups: [RemindersSectionGroup] = [
            RemindersSectionGroup(title: "Overdue", remindersList: overdueReminders),
            RemindersSectionGroup(title: "Today", remindersList: remindersToday),
            RemindersSectionGroup(title: "Tomorrow", remindersList: remindersTomorrow),
            RemindersSectionGroup(title: "Upcoming", remindersList: upcomingReminders),
            RemindersSectionGroup(title: "No Date", remindersList: remindersWithoutDate),
            RemindersSectionGroup(title: "Completed", remindersList: completeReminders)
        ]
        
        var filteredSectionGroup: [RemindersSectionGroup] {
            sectionGroups
                .map {
                    RemindersSectionGroup(
                        title: $0.title,
                        remindersList: filteredReminders(remindersList: filteredReminders(remindersList: $0.remindersList))
                    )
                }
        }
        
        NavigationStack {
            List {
                ForEach(filteredSectionGroup) { group in
                    ReminderSection(
                        sectionTitle: group.title,
                        remindersList: group.remindersList
                    )
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
                            filteredReminders(remindersList: overdueReminders).isEmpty &&
                            filteredReminders(remindersList: remindersToday).isEmpty &&
                            filteredReminders(remindersList: remindersTomorrow).isEmpty &&
                            filteredReminders(remindersList: upcomingReminders).isEmpty &&
                            filteredReminders(remindersList: remindersWithoutDate).isEmpty &&
                            filteredReminders(remindersList: completeReminders).isEmpty
                {
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
    
    // search reminders in through given reminders
    func filteredReminders(remindersList: [Reminder]) -> [Reminder] {
        guard !searchText.isEmpty else {return remindersList}
        
        return remindersList.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.note.localizedCaseInsensitiveContains(searchText)
        }
    }
}

struct RemindersSectionGroup: Identifiable {
    let id = UUID()
    var title: String
    var remindersList: [Reminder]
}

struct ReminderSection: View {
    var sectionTitle: String
    var remindersList: [Reminder]
    
    var body: some View {
        if !remindersList.isEmpty {
            Section(sectionTitle) {
                ForEach(remindersList) { reminder in
                    ReminderRow(reminder: reminder)
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
