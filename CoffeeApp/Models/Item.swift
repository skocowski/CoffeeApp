//
//  Item.swift
//  CoffeeApp
//
//  Created by Szymon Kocowski on 18/3/23.
//

import Foundation

// That struct is needed to do summary of sold items within the rang eof dates.
struct Item: Hashable {
    var title: String = ""
    var value: Double = 0.0
    var quantity: Int = 0
}
