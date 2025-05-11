//
//  FitnessTabView.swift
//  FitSwift
//
//  Created by csuftitan on 4/7/25.
//

import SwiftUI

struct FitnessTabView: View {
    @State var selectedTab = "Home"
    
    init() {
        let apparence = UITabBarAppearance()
        apparence.configureWithOpaqueBackground()
        apparence.stackedLayoutAppearance.selected.iconColor = .fitSwiftRed
        apparence.stackedLayoutAppearance.selected.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.fitSwiftRed]
        UITabBar.appearance().scrollEdgeAppearance = apparence
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tag("Home")
                .tabItem {
                    Image(systemName: "house")
                    
                    Text("Home")
                }
            
            ChartsView()
                .tag("Charts")
                .tabItem {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                    
                    Text("Charts")
                }
            
            ChatView(selectedTab: $selectedTab)
                .tag("Chat")
                .tabItem {
                    Image(systemName: "message.fill")
                    Text("Chat")
                }
        }
    }
}


struct FitnessTabView_Previews: PreviewProvider {
    static var previews: some View {
        FitnessTabView()
    }
}
