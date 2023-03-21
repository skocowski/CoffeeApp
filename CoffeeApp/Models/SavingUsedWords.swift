//
//  SavingWords.swift
//  CoffeeApp
//
//  Created by Szymon Kocowski on 10/3/23.
//

import Foundation

class SavingUsedWords: ObservableObject, Codable {
    var usedWords: Set<String>
    
    var saveKey = "usedWords"
    
    init() {
        // Load saved data
        if let data = UserDefaults.standard.data(forKey: saveKey) {
            if let decoded = try? JSONDecoder().decode(Set<String>.self, from: data) {
                usedWords = decoded
                return
            }
        }
        usedWords = []
    }
    
    func add(_ newWord: String) {
        objectWillChange.send()
        usedWords.insert(newWord)
        save()
    }
    
    func save() {
        if let encoded = try? JSONEncoder().encode(usedWords) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
}
