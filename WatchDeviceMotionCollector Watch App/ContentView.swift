//
//  ContentView.swift
//  WatchDeviceMotionCollector Watch App
//
//  Created by 김영빈 on 2023/07/08.
//

import SwiftUI

struct ContentView: View {
    @State var selectedTab = 1
    
    var body: some View {
        TabView(selection: $selectedTab) {
            LeftHandView(selectedTab: $selectedTab)
                .tag(1)
            RightHandView(selectedTab: $selectedTab)
                .tag(2)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
