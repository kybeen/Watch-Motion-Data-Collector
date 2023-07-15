//
//  ContentView.swift
//  WatchDeviceMotionCollector Watch App
//
//  Created by 김영빈 on 2023/07/08.
//

import SwiftUI

struct ContentView: View {
    @State var selectedTab = 1
    let watchViewModel = WatchViewModel()
    
    var body: some View {
        TabView(selection: $selectedTab) {
            LeftHandView(watchViewModel: watchViewModel, selectedTab: $selectedTab)
                .tag(1)
            RightHandView(watchViewModel: watchViewModel, selectedTab: $selectedTab)
                .tag(2)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
