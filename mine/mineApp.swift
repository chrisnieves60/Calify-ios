//
//  CalifyApp.swift
//  Calify
//
//  Created by christopher on 3/29/25.
//

import SwiftUI

@main //this is like the index.js or main file for the entire app. starting point.
struct CalifyApp: App {
    var body: some Scene { //think of body like return, it defines whats displayed
        WindowGroup { //represents window for the app, if this was macos, this owuld be a window. on ios, its main screen.
            ContentView()
        }
    }
}

struct ContentView: View {
    var body: some View {
        TabView { //this is container for bottom tabs
            HomeView() //object, this is a view
                .tabItem { //call method on object, this method being, tabitem?
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            
            HistoryView() //object, this is a view
                .tabItem { //call method on object, this method being, tabitem?
                    Image(systemName: "clock.fill")
                    Text("History")
                }
            
            ProfileView() //object, this is a view
                .tabItem { //call method on object, this method being, tabitem?
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
        }
    }
}
