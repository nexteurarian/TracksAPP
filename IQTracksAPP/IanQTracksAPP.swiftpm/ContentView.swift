// Created by Ian Quibete

import SwiftUI

struct ContentView: View {
    @State private var courses: [Course] = []
    @StateObject private var rewardsManager = RewardsManager()
    
    var body: some View {
        TabView {
            Courses(courses: $courses)
                .tabItem {
                    Image(systemName: "rectangle.fill.on.rectangle.angled.fill")
                    Text("Courses")
                }
            Assignments(courses: courses)
                .environmentObject(rewardsManager)
                .tabItem {
                    Image(systemName: "tray.2.fill")
                    Text("Assignments")
                }
            
            Rewards(rewardsManager: rewardsManager)
                .tabItem {
                    Image(systemName: "wand.and.stars")
                    Text("Rewards")
                }
            Info()
                .tabItem {
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                    Text("Info")
                }
        }
        .accentColor(.orange)
    }
}

