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
    
    let now = Date()
    let calendar = Calendar.current
    
    var overdue: [Reminder] {
        reminders.filter {
            guard let date = $0.dateReminder else {return false}
            return date < now && !$0.isDone
        }
    }
    
    var today: [Reminder] {
        reminders.filter {
            guard let date = $0.dateReminder else {return false}
            return calendar.isDateInToday(date) && !$0.isDone && date > now
        }
    }
    
    var tomorrow: [Reminder] {
        reminders.filter {
            guard let date = $0.dateReminder else {return false}
            return calendar.isDateInTomorrow(date) && !$0.isDone
        }
    }
    
    var upcoming: [Reminder] {
        reminders.filter {
            guard let date = $0.dateReminder else {return false}
            return date > now &&
            !calendar.isDateInToday(date) &&
            !calendar.isDateInTomorrow(date) &&
            !$0.isDone
        }
    }
    
    var withoutDate: [Reminder] {
        reminders.filter { $0.dateReminder == nil && !$0.isDone }
    }
    
    var completed: [Reminder] {
        reminders.filter { $0.isDone }
    }
    
    var body: some View {
        let sectionGroups: [RemindersSectionGroup] = [
            RemindersSectionGroup(title: "Overdue", remindersList: overdue, isExpandable: false),
            RemindersSectionGroup(title: "Today", remindersList: today, isExpandable: false),
            RemindersSectionGroup(title: "Tomorrow", remindersList: tomorrow, isExpandable: false),
            RemindersSectionGroup(title: "Upcoming", remindersList: upcoming, isExpandable: false),
            RemindersSectionGroup(title: "No Date", remindersList: withoutDate, isExpandable: false),
            RemindersSectionGroup(title: "Completed", remindersList: completed, isExpandable: true)
        ]
        
        var filteredSectionGroup: [RemindersSectionGroup] {
            sectionGroups
                .map {
                    RemindersSectionGroup(
                        title: $0.title,
                        remindersList: filteredReminders(remindersList: filteredReminders(remindersList: $0.remindersList)),
                        isExpandable: $0.isExpandable
                    )
                }
        }
        
        NavigationStack {
            List {
                ForEach(filteredSectionGroup) { group in
                    ReminderSection(
                        sectionTitle: group.title,
                        remindersList: group.remindersList,
                        isExpandable: group.isExpandable
                    )
                }
            }
            .listStyle(.sidebar)
            .overlay {
                if reminders.isEmpty {
                    ContentUnavailableView {
                        Label("No reminders yet", systemImage: "exclamationmark.circle.fill")
                    } description: {
                        Text("Add reminders and they will appear here")
                    }
                } else if !searchText.isEmpty &&
                            filteredReminders(remindersList: overdue).isEmpty &&
                            filteredReminders(remindersList: today).isEmpty &&
                            filteredReminders(remindersList: tomorrow).isEmpty &&
                            filteredReminders(remindersList: upcoming).isEmpty &&
                            filteredReminders(remindersList: withoutDate).isEmpty &&
                            filteredReminders(remindersList: completed).isEmpty
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
    var isExpandable: Bool
}

struct ReminderSection: View {
    var sectionTitle: String
    var remindersList: [Reminder]
    var isExpandable: Bool
    
    @State private var isExpanded: Bool = false
    
    var body: some View {
        if !remindersList.isEmpty {
            if isExpandable {
                Section("\(sectionTitle) (\(remindersList.count))", isExpanded: $isExpanded) {
                    ForEach(remindersList) { reminder in
                        ReminderRow(reminder: reminder)
                    }
                }
            } else {
                Section("\(sectionTitle) (\(remindersList.count))") {
                    ForEach(remindersList) { reminder in
                        ReminderRow(reminder: reminder)
                    }
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
