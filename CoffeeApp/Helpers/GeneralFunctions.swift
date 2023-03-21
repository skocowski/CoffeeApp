//
//  GeneralFunctions.swift
//  CoffeeApp
//
//  Created by Szymon Kocowski on 19/2/23.
//

import Foundation

func asCurrency(value: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    
    return formatter.string(from: NSNumber(value: value)) ?? ""
}

func asNumber(value: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.groupingSeparator = " "
    
    return formatter.string(from: NSNumber(value: value)) ?? ""
}

func calcTimeSince(date: Date) -> String {
    let minutes = Int(-date.timeIntervalSinceNow) / 60
    let hours = minutes / 60
    let days = hours / 24
    
    if minutes < 120 {
        return "\(minutes) min ago"
    } else if minutes >= 120 && hours < 48 {
        return "\(hours) hrs ago"
    } else {
        return "\(days) days ago"
    }
}
