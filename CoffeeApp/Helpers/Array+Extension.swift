//
//  Array+Extension.swift
//  CoffeeApp
//
//  Created by Szymon Kocowski on 7/3/23.
//

import Foundation

extension Array where Element:Equatable {
    func removeDuplicates() -> [Element] {
        var result = [Element]()

        for value in self {
            if result.contains(value) == false {
                result.append(value)
            }
        }

        return result
    }
}
