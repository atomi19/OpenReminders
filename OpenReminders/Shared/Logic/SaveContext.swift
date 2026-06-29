//
//  SaveContext.swift
//  OpenReminders

import SwiftData

func saveContext(context: ModelContext) {
    do {
        try context.save()
    } catch {
        print(error)
    }
}
