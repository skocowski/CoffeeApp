//
//  Transaction+CoreDataProperties.swift
//  CoffeeApp
//
//  Created by Szymon Kocowski on 8/3/23.
//
//

import Foundation
import CoreData


extension Transaction {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Transaction> {
        return NSFetchRequest<Transaction>(entityName: "Transaction")
    }

    @NSManaged public var date: Date?
    @NSManaged public var isExpense: Bool
    @NSManaged public var title: String?
    @NSManaged public var value: Double

    var wrappedDate: Date {
        date ?? Date()
    }
    
    var wrappedTitle: String {
        title ?? "Unknown title"
    }
}

extension Transaction : Identifiable {

}
