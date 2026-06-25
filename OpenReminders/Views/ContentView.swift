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
    @State private var quickAddTextField = ""
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
                remindersList: filteredReminders(remindersList: $0.remindersList),
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
                    ContentUnavailableView {
                        Label("No reminders yet", systemImage: "exclamationmark.circle.fill")
                    } description: {
                        Text("Add reminders and they will appear here")
                    }
                } else if !searchText.isEmpty &&
                            filteredReminders(remindersList: pinned).isEmpty &&
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
                    .buttonStyle(.glass)
                    .tint(chip.isSelected ? Color.blue : Color.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                }
            }
            #if os(iOS)
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    TextField("Quick Reminder", text: $quickAddTextField)
                        .onChange(of: quickAddTextField) { oldValue, newValue in
                            if quickAddTextField.isEmpty {
                                quickDateChip = nil
                            } else {
                                handleDateExtractionFromQuickField()
                            }
                        }
                    Button("Add", systemImage: quickAddTextField.isEmpty ? "plus" : "checkmark") {
                        if quickAddTextField.isEmpty {
                            isShowingAddSheet.toggle()
                        } else {
                            saveReminder(
                                title: quickAddTextField,
                                note: "",
                                isDone: false,
                                isRemindEnabled: quickDateChip?.isSelected ?? false,
                                date: quickDateChip?.remindDate,
                                repeatOption: .never,
                                context: context,
                            )
                            
                            quickAddTextField = ""
                        }
                    }
                    .buttonStyle(.glassProminent)
                }
            }
            #elseif os(macOS)
            .safeAreaInset(edge: .bottom) {
                HStack {
                    TextField("Quick Reminder", text: $quickAddTextField)
                        .textFieldStyle(.roundedBorder)
                        .onChange(of: quickAddTextField) { oldValue, newValue in
                            if quickAddTextField.isEmpty {
                                quickDateChip = nil
                            } else {
                                handleDateExtractionFromQuickField()
                            }
                        }
                        .onSubmit {
                            if quickAddTextField.isEmpty {
                                isShowingAddSheet = true
                            } else {
                                saveReminder(
                                    title: quickAddTextField,
                                    note: "",
                                    isDone: false,
                                    isRemindEnabled: quickDateChip?.isSelected ?? false,
                                    date: quickDateChip?.remindDate,
                                    repeatOption: .never,
                                    context: context
                                )
                                
                                quickAddTextField = ""
                            }
                        }
                    Button(
                        quickAddTextField.isEmpty ? "Add" : "Done",
                        systemImage: quickAddTextField.isEmpty ? "plus" : "checkmark"
                    ) {
                        if quickAddTextField.isEmpty {
                            isShowingAddSheet.toggle()
                        } else {
                            saveReminder(
                                title: quickAddTextField,
                                note: "",
                                isDone: false,
                                isRemindEnabled: quickDateChip?.isSelected ?? false,
                                date: quickDateChip?.remindDate,
                                repeatOption: .never,
                                context: context,
                            )
                            
                            quickAddTextField = ""
                        }
                    }
                    .buttonStyle(.glassProminent)
                }
                .padding()
            }
            #endif
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
    
    func handleDateExtractionFromQuickField() {
        do {
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.date.rawValue)
            
            guard let match = detector.firstMatch(
                in: quickAddTextField,
                range: NSRange(quickAddTextField.startIndex..., in: quickAddTextField)
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

private struct RemindersSectionGroup: Identifiable {
    let id = UUID()
    var title: String
    var remindersList: [Reminder]
    var isExpandable: Bool
}

private struct ReminderSection: View {
    var sectionTitle: String
    var remindersList: [Reminder]
    var isExpandable: Bool
    let onEdit: (Reminder) -> Void
    
    @State private var isExpanded: Bool = false
    
    var body: some View {
        if !remindersList.isEmpty {
            if isExpandable {
                Section("\(sectionTitle) (\(remindersList.count))", isExpanded: $isExpanded) {
                    handleReminder
                }
            } else {
                Section("\(sectionTitle) (\(remindersList.count))") {
                    handleReminder
                }
            }
        }
    }
    
    private var handleReminder: some View {
        ForEach(remindersList) { reminder in
            ReminderRow(
                reminder: reminder,
                onEdit: onEdit
            )
        }
    }
}

private struct ReminderRow: View {
    var reminder: Reminder
    let onEdit: (Reminder) -> Void
    
    private var isOverdue: Bool {
        if let date = reminder.dateReminder {
            return date < Date()
        } else {
            return false
        }
    }
    
    @State private var isShowingEditSheet = false
    
    @Environment(\.modelContext) private var context
    
    var body: some View {
        HStack(alignment: .top) {
            Image(systemName: reminder.isDone ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(.secondary)
                .onTapGesture {
                    reminder.isDone.toggle()
                    
                    if(reminder.isDone) {
                        // remove notification (reminder marked as completed)
                        if reminder.dateReminder != nil {
                            NotificationService.shared.removeNotification(uuid: reminder.uuid.uuidString)
                        }
                    } else {
                        // add notification back (reminder is not completed)
                        if let dateReminder = reminder.dateReminder {
                            NotificationService.shared.scheduleNotification(
                                uuid: reminder.uuid.uuidString,
                                title: reminder.title,
                                body: reminder.note,
                                date: dateReminder,
                                repeatOption: reminder.repeatOption ?? .never
                            )
                        }
                    }
                    
                    saveContext(context: context)
                }
            VStack(alignment: .leading) {
                Text(reminder.title)
                    .strikethrough(reminder.isDone)
                if !reminder.note.isEmpty {
                    Text(reminder.note)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                if reminder.dateReminder != nil {
                    if let date = reminder.dateReminder {
                        Text(date.formatted())
                            .font(.subheadline)
                            .foregroundStyle(isOverdue ? .red : .secondary)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        #if os(iOS)
        .swipeActions(edge: .leading) {
            pinButton
            .tint(.blue)
        }
        .swipeActions(edge: .trailing) {
            deleteButton
            editButton
            .tint(.orange)
        }
        #elseif os(macOS)
        .contextMenu {
            pinButton
            editButton
            Divider()
            deleteButton
        }
        #endif
    }
    
    private var pinButton: some View {
        Button(
            reminder.isPinned ? "Unpin" : "Pin",
            systemImage: reminder.isPinned ? "pin.slash" : "pin"
        ) {
            handleReminderPin(reminder: reminder)
        }
    }
    
    private var editButton: some View {
        Button("Edit", systemImage: "pencil") {
            onEdit(reminder)
        }
    }
    
    private var deleteButton: some View {
        Button("Delete", systemImage: "trash", role: .destructive) {
            handleReminderDelete(reminder: reminder)
        }
    }
    
    func handleReminderPin(reminder: Reminder) {
        reminder.isPinned.toggle()
        saveContext(context: context)
    }
    
    func handleReminderDelete(reminder: Reminder) {
        NotificationService.shared.removeNotification(uuid: reminder.uuid.uuidString)
        context.delete(reminder)
        saveContext(context: context)
    }
}

#Preview {
    ContentView()
}
