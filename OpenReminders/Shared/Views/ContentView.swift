//
//  ContentView.swift
//  OpenReminders

import SwiftUI
import SwiftData

struct ContentView: View {
    @Query(sort: \Reminder.timeStamp)
    private var reminders: [Reminder]
    
    @State private var isShowingAddSheet = false
    @State private var selectedReminder: Reminder?
    @State private var searchText = ""
    @State private var quickAddText = ""
    @State private var quickDateChip: QuickDateChip? = nil
    
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
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
            .scrollDismissesKeyboard(.immediately)
            .listStyle(.sidebar)
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
            .navigationTitle("OpenReminders")
            .searchable(
                text: $searchText,
                prompt: "Search"
            )
            .safeAreaInset(edge: .bottom) {
                if let chip = quickDateChip {
                    Button(action: {
                        if var chip = quickDateChip {
                            chip.isSelected.toggle()
                            quickDateChip = chip
                        }
                    }) {
                        Image(systemName: "calendar")
                        Text(chip.remindDate.formatted())
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        if chip.isSelected {
                            Image(systemName: "checkmark")
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(chip.isSelected ? Color.blue : Color.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                }
            }
            #if os(iOS)
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    quickAddField
                    openAddSheetButton
                }
            }
            #elseif os(macOS)
            .safeAreaInset(edge: .bottom) {
                HStack {
                    quickAddField
                    openAddSheetButton
                }
                .padding()
            }
            #endif
        }
    }
    
    private var quickAddField: some View {
        TextField("Quick Reminder", text: $quickAddText)
            .onChange(of: quickAddText) { oldValue, newValue in
                if quickAddText.isEmpty {
                    quickDateChip = nil
                } else {
                    handleDateExtractionFromQuickField()
                }
            }
            .onSubmit(handleQuickBarAction)
    }
    
    private var openAddSheetButton: some View {
        Button(
            quickAddText.isEmpty ? "Add" : "Done",
            systemImage: quickAddText.isEmpty ? "plus" : "checkmark",
            action: handleQuickBarAction
        )
        .buttonStyle(.borderedProminent)
    }
    
    func handleQuickBarAction() {
        if quickAddText.isEmpty {
            isShowingAddSheet.toggle()
        } else {
            saveReminder(
                title: quickAddText,
                note: "",
                isDone: false,
                isRemindEnabled: quickDateChip?.isSelected ?? false,
                date: quickDateChip?.remindDate,
                repeatOption: .never,
                context: context,
            )

            quickAddText = ""
        }
    }
    
    func handleDateExtractionFromQuickField() {
        do {
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.date.rawValue)
            
            guard let match = detector.firstMatch(
                in: quickAddText,
                range: NSRange(quickAddText.startIndex..., in: quickAddText)
            ),
            let date = match.date else { return }
            
            quickDateChip = QuickDateChip(remindDate: date, isSelected: false)
        } catch {
            print(error)
        }
    }
}

private struct QuickDateChip: Identifiable {
    let id = UUID()
    let remindDate: Date
    var isSelected: Bool
}

#Preview {
    ContentView()
}
