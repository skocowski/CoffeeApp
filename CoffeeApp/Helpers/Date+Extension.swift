//
//  Data+Extension.swift
//  CoffeeApp
//
//  Created by Szymon Kocowski on 20/2/23.
//

import Foundation

// Some useful extensions, not all used in the project.
extension Date {
    func startOfTheWeek(using calendar: Calendar = .current) -> Date {
        calendar.dateComponents([.calendar, .yearForWeekOfYear, .weekOfYear], from: self).date!
    }
    
    func isBetween(_ date1: Date, and date2: Date) -> Bool {
       return (min(date1, date2) ... max(date1, date2)).contains(self)
    }
    
    var startOfDay: Date? {
        let calendar = Calendar.current
        return calendar.dateInterval(of: .day, for: self)?.start
    }
    
    var endOfDay: Date? {
        let calendar = Calendar.current
        return calendar.dateInterval(of: .day, for: self)?.end
    }

    var startOfWeek: Date? {
       let calendar = Calendar.current
       return calendar.dateInterval(of: .weekOfMonth, for: self)?.start
    }

    var endOfWeek: Date? {
        let calendar = Calendar.current
        return calendar.dateInterval(of: .weekOfMonth, for: self)?.end
    }

    var startOfMonth: Date? {
        let calendar = Calendar.current
        return calendar.dateInterval(of: .month, for: self)?.start
    }

    var endOfMonth: Date? {
        let calendar = Calendar.current
        return calendar.dateInterval(of: .month, for: self)?.end
    }

    var weekNumber: Int? {
        let calendar = Calendar.current
        let currentComponents = calendar.dateComponents([.weekOfYear], from: self)
        return currentComponents.weekOfYear
    }

//    var monthNumber: Int? {
//        let calendar = Calendar.current
//        let currentComponents = calendar.dateComponents([.month], from: self)
//        return currentComponents.month
//    }
}

func formattingDate(date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "d-MMM-yy"
    
    return formatter.string(from: date)
}
