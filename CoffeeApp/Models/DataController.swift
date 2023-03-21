//
//  DataController.swift
//  CoffeeApp
//
//  Created by Szymon Kocowski on 12/2/23.
//

import CoreData
import Foundation
import SwiftUI

class DataController: ObservableObject {
    let container: NSPersistentContainer
    
    @Published var savedTransactions: [Transaction] = [] {
        didSet {
            loadItems()
        }
    }
    @Published var oneMonthTransactions: [Transaction] = []
    
    @Published var usedWords: Set<String> = []
    @Published var editTransaction: Transaction?
    @Published var currentTab: String = "Today"
    @Published var showingEditView = false
    @Published var dateRange: ClosedRange<Date>? = nil
    @Published var items = [Item]()
    @Published var startingDate: Date = Calendar.current.startOfDay(for: Date()) {
        didSet {
            fetchTransactions()
            fetchOneMonthTransactions()
        }
    }
    @Published var finishDate: Date = Date() {   // .endOfDay ?? Date()
        didSet {
            fetchTransactions()
            fetchOneMonthTransactions()
        }
    }
    
    let defaults = UserDefaults.standard
   
    
    init() {
      //  container = NSPersistentContainer(name: "CoffeeShop3")
        container = NSPersistentCloudKitContainer(name: "CoffeeShop3")
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        fetchTransactions()
        fetchOneMonthTransactions()

    }
    

    
    func fetchTransactions() {
        let request = NSFetchRequest<Transaction>(entityName: "Transaction")
        let filterKey = "date"
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        if self.startingDate <= self.finishDate {
            request.predicate = NSPredicate(format: "\(filterKey) >= %@ AND \(filterKey) < %@", argumentArray: [self.startingDate, self.finishDate.endOfDay ?? self.finishDate])
        } else {
            request.predicate = NSPredicate(format: "\(filterKey) >= %@ AND \(filterKey) < %@", argumentArray: [self.finishDate, self.startingDate.endOfDay ?? self.startingDate])
        }

        
        do {
            savedTransactions = try container.viewContext.fetch(request)
            loadItems()
        } catch {
            print("Error fetching. \(error)")
        }
    }
    
    func fetchOneMonthTransactions() {
        let request = NSFetchRequest<Transaction>(entityName: "Transaction")
        let filterKey = "date"
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        request.predicate = NSPredicate(format: "\(filterKey) >= %@ AND \(filterKey) < %@", argumentArray: [Date().startOfMonth ?? Date(), Date().endOfMonth ?? Date()])
        
        do {
            oneMonthTransactions = try container.viewContext.fetch(request)
        
        } catch {
            print("Error fetching. \(error)")
        }
    }
    
    func saveData() {
        do {
            try container.viewContext.save()
            fetchTransactions()
            fetchOneMonthTransactions()
            
        } catch {
            print("Error saving. \(error)")
        }
    }
    
    func addEditTransaction(title: String, value: Double, isExpense: Bool, date: Date, context: NSManagedObjectContext) {
        
        if let transaction = editTransaction {
            
            transaction.title = title
            transaction.value = value
            transaction.isExpense = isExpense
            transaction.date = date
      //      usedWords.insert(title)
        
        } else {
            let transaction = Transaction(context: context)
        
            transaction.title = title
            transaction.value = value
            transaction.isExpense = isExpense
            transaction.date = date
  //          usedWords.insert(title)
            
        }
 
        saveData()
    }
    
    func loadItems() {
        items.removeAll()
        
        var arrayOfTitles = [String]()
        
        for item in savedTransactions {
            arrayOfTitles.append(item.wrappedTitle)
        }
        
        let sortedArray = arrayOfTitles.removeDuplicates().sorted(by: <)
        
        for index in 0..<sortedArray.count {
            var newItem = Item()
            newItem.title = sortedArray[index]
            let itemArray = savedTransactions.filter { $0.title == sortedArray[index] }
            newItem.quantity = itemArray.count
            
            for item in itemArray {
                if !item.isExpense {
                    newItem.value += item.value
                } else {
                    newItem.value -= item.value
                }
                
            }
            
            items.append(newItem)
        }
    }
    
    func deleteItem(offsets: IndexSet) {
        withAnimation {
            offsets.map { savedTransactions[$0] }.forEach(container.viewContext.delete)
            saveData()
        }
    }
    
    func totalSellToday() -> Double {
        var sellToday: Double = 0
        
        for transaction in oneMonthTransactions {
            
            guard let transactionDate = transaction.date else { return sellToday }
            
            if Calendar.current.isDateInToday(transactionDate) {
                if transaction.isExpense {
                    sellToday -= transaction.value
                } else {
                    sellToday += transaction.value
                }
            }
        }
        
        return sellToday
    }
    
    func totalSellYesterday() -> Double {
        var sellYesterday: Double = 0
        let calendar = Calendar.current
        
        for transaction in oneMonthTransactions {
            guard let transactionDate = transaction.date else { return sellYesterday }
            if calendar.isDateInYesterday(transactionDate) {
                if transaction.isExpense {
                    sellYesterday -= transaction.value
                } else {
                    sellYesterday += transaction.value
                }
            }
        }
        
        return sellYesterday
        
    }
    
    func totalSellWeek() -> Double {
        var sellWeek: Double = 0
        guard let weekStart = Date().startOfWeek else { return sellWeek }
        
        for transaction in oneMonthTransactions {
            guard let transactionDate = transaction.date else { return sellWeek }
            if transactionDate.isBetween(weekStart, and: Date()) {
                if transaction.isExpense {
                    sellWeek -= transaction.value
                } else {
                    sellWeek += transaction.value
                }
            }
        }
        return sellWeek
    }
    
    func totalSellMonth() -> Double {
        var sellMonth: Double = 0
        
        guard let monthStart = Date().startOfMonth else { return sellMonth }
        
        for transaction in oneMonthTransactions {
            guard let transactionDate = transaction.date else { return sellMonth }
            if transactionDate.isBetween(monthStart, and: Date()) {
                if transaction.isExpense {
                    sellMonth -= transaction.value
                } else {
                    sellMonth += transaction.value
                }
            }
        }
        return sellMonth
    }

}
