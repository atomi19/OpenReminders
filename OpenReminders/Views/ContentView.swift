//
//  ContentView.swift
//  QuickReminders

import SwiftUI
import SwiftData

struct ContentView: View {
    @Query(sort: \Reminder.timeStamp)
    private var reminders: [Reminder]
    
    @State private var isShowingAddSheet = false
    
    @Environment(\.modelContext) private var context
    
    var body: some View {
        let remindersWithoutDate = reminders.filter {$0.dateReminder == nil}
        let remindersWithDate = reminders.filter {$0.dateReminder != nil}
        
        NavigationStack {
            List {
                // reminders without date
                if !remindersWithoutDate.isEmpty {
                    Section ("No Date") {
                        ForEach(remindersWithoutDate) { reminder in
                            ReminderRow(reminder: reminder)
                        }
                    }
                }
                
                // reminders with date
                if !remindersWithDate.isEmpty {
                    Section("Scheduled") {
                        ForEach(remindersWithDate) { reminder in
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
                }
            }
            .sheet(isPresented: $isShowingAddSheet) {
                AddReminderView()
            }
            .navigationTitle("QuickReminders")
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
        .swipeActions(edge: .trailing) {
            Button("Delete", systemImage: "trash", role: .destructive) {
                context.delete(reminder)
                
                do {
                    try context.save()
                } catch {
                    print(error)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
