//
//  WatchHomeView.swift
//  OpenReminders Watch App

import SwiftUI
import SwiftData

struct WatchHomeView: View {
    @Query(sort: \Reminder.timeStamp)
    private var reminders: [Reminder]
    
    @State private var isShowingAddSheet = false
    @State private var selectedReminder: Reminder?
    @State private var searchText = ""
    
    let filter = ReminderFilter()
    
    var pinned: [Reminder] { filter.pinned(reminders) }
    var overdue: [Reminder] { filter.overdue(reminders) }
    var today: [Reminder] { filter.today(reminders) }
    var tomorrow: [Reminder] { filter.tomorrow(reminders) }
    var upcoming: [Reminder] { filter.upcoming(reminders) }
    var withoutDate: [Reminder] { filter.withoutDate(reminders) }
    var completed: [Reminder] { filter.completed(reminders) }
    
    private var hasSearchResults: Bool {
        filteredSectionGroups.contains { !$0.remindersList.isEmpty }
    }
    
    private var sectionGroups: [RemindersSectionGroup] {
        [
            .init(title: "Pinned", remindersList: pinned, isExpandable: false),
            .init(title: "Overdue", remindersList: overdue, isExpandable: false),
            .init(title: "Today", remindersList: today, isExpandable: false),
            .init(title: "Tomorrow", remindersList: tomorrow, isExpandable: false),
            .init(title: "Upcoming", remindersList: upcoming, isExpandable: false),
            .init(title: "No Date", remindersList: withoutDate, isExpandable: false),
            .init(title: "Completed", remindersList: completed, isExpandable: true)
        ]
    }
    
    private var filteredSectionGroups: [RemindersSectionGroup] {
        sectionGroups.map {
            RemindersSectionGroup(
                title: $0.title,
                remindersList: filteredReminders(searchText: searchText, remindersList: $0.remindersList),
                isExpandable: $0.isExpandable
            )
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredSectionGroups) { group in
                    ReminderSection(
                        sectionTitle: group.title,
                        remindersList: group.remindersList,
                        isExpandable: group.isExpandable,
                        onEdit: { reminder in
                            selectedReminder = reminder
                        }
                    )
                }
            }
            .overlay {
                if reminders.isEmpty {
                    NoRemindersView()
                } else if !searchText.isEmpty && !hasSearchResults {
                    NoSearchResultsView()
                }
            }
            .sheet(isPresented: $isShowingAddSheet) {
                AddReminderView()
            }
            .sheet(item: $selectedReminder) { reminder in
                EditReminderView(reminder: reminder)
            }
            .searchable(
                text: $searchText,
                prompt: "Search"
            )
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Add", systemImage: "plus") {
                        isShowingAddSheet.toggle()
                    }
                }
            }
        }
    }
}

#Preview {
    WatchHomeView()
}
