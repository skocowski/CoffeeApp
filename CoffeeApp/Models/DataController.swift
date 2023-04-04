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
        // Loading items. Needed to have proper transactions summary.
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
        // Fetching data whenever user change the date.
        didSet {
            fetchTransactions()
            fetchOneMonthTransactions()
        }
    }
    @Published var finishDate: Date = Date() {
        // Fetching data whenever user change the date.
        didSet {
            fetchTransactions()
            fetchOneMonthTransactions()
        }
    }
    
    let defaults = UserDefaults.standard
   
    
    init() {
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
    

    // Fetching transactions within the date range.
    func fetchTransactions() {
        let request = NSFetchRequest<Transaction>(entityName: "Transaction")
        let filterKey = "date"
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        // If-else statement is necessary to work properly in case user choose starting date later than finish date.
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
    
    // Fetching one month transactions. Needed to display sell in Home View.
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
    
    // Saving transaction into CoreData and fetching new lists.
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
        
        // Editing transaction.
        if let transaction = editTransaction {
            
            transaction.title = title
            transaction.value = value
            transaction.isExpense = isExpense
            transaction.date = date
        
        // If editTransaction == nil then the function adds a new transaction.
        } else {
            let transaction = Transaction(context: context)
        
            transaction.title = title
            transaction.value = value
            transaction.isExpense = isExpense
            transaction.date = date

        }
        // Saving into CoreData.
        saveData()
    }
    
    // This function is necessary to prepare transactions summary withing the range of dates.
    func loadItems() {
        items.removeAll()
        
        // Titles of transactions
        var arrayOfTitles = [String]()
        
        // Title of all fetched transactions
        for item in savedTransactions {
            arrayOfTitles.append(item.wrappedTitle)
        }
        
        // Sorting and removing duplicate in titles so we having all the titles unique
        let sortedArray = arrayOfTitles.removeDuplicates().sorted(by: <)
        
        // This loop counts the amount of each item sold.
        for index in 0..<sortedArray.count {
            var newItem = Item()
            newItem.title = sortedArray[index]
            let itemArray = savedTransactions.filter { $0.title == sortedArray[index] }
            newItem.quantity = itemArray.count
            
            // This loop sums up the value of each sold item. For example if we sold 5 cafes, each costed a dollar, the result will be 5 dollars.
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
    
    // Deleting transaction by swiping the list row.
    func deleteItem(offsets: IndexSet) {
        withAnimation {
            offsets.map { savedTransactions[$0] }.forEach(container.viewContext.delete)
            saveData()
        }
    }
    
    // Calculating total sell today. Displayed in Home View.
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
    
    // Calculating total yserday sell. Displayed in Home View.
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
    
    // Calculating total sell in current week. Displayed in Home View.
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
    
    // Calculating total sell in current month. Displayed in Home View.
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
