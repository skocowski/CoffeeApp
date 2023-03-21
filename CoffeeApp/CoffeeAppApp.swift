//
//  CoffeeAppApp.swift
//  CoffeeApp
//
//  Created by Szymon Kocowski on 12/2/23.
//

import SwiftUI

@main
struct CoffeeAppApp: App {
    @StateObject private var dataController = DataController()
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .environmentObject(dataController)
        }
    }
}
