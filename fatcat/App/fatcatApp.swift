//
//  fatcatApp.swift
//  fatcat
//
//  Created by 佐伯小遥 on 2025/06/16.
//

import SwiftUI

@main
struct fatcatApp: App {
    @StateObject var dataStore = CatDataStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dataStore)
        }
    }
}
