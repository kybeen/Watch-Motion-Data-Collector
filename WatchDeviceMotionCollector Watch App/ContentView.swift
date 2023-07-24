//
//  ContentView.swift
//  WatchDeviceMotionCollector Watch App
//
//  Created by 김영빈 on 2023/07/08.
//

import SwiftUI

struct ContentView: View {
    @State var selectedTab = 1
    @State var isShowingGuide = true
    let watchViewModel = WatchViewModel()
    
    var body: some View {
        if isShowingGuide {
            Text("애플워치를 오른손에 착용해주세요.").font(.largeTitle).bold()
                .onTapGesture {
                    isShowingGuide = false
                }
        }
        else {
            TabView(selection: $selectedTab) {
                ForehandView(watchViewModel: watchViewModel, selectedTab: $selectedTab)
                    .tag(1)
                BackhandView(watchViewModel: watchViewModel, selectedTab: $selectedTab)
                    .tag(2)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
