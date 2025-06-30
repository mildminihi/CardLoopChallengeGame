//
//  ContentView.swift
//  CardLoopChallengeGameApp
//
//  Created by Supanat.w on 25/6/2568 BE.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            HomePage()
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

#Preview {
    ContentView()
}
