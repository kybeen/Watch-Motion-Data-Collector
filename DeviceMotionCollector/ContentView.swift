//
//  ContentView.swift
//  DeviceMotionCollector
//
//  Created by 김영빈 on 2023/07/08.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var phoneViewModel = PhoneViewModel()
    @State var reachable = "No" // 연결 상태 확인
    
    @State private var selectedFrequency = 9
    let HzOptions = [10, 20, 30, 40, 50, 60, 70, 80, 90, 100]
    @State private var csvFolderIndex = 0
    @State private var leftSelectedCSVFiles: [String] = [] // 선택된 파일들 (삭제용)
    @State private var rightSelectedCSVFiles: [String] = [] // 선택된 파일들 (삭제용)
    
    var body: some View {
        VStack(alignment: .leading) {
            //MARK: Frequency 선택
            HStack(alignment: .top) {
                Text("Frequency select").font(.title2).bold()
                Spacer()
                Picker("Frequency", selection: $selectedFrequency) {
                    ForEach(0..<HzOptions.count) { index in
                        Text("\(HzOptions[index])Hz")
                    }
                }
                .pickerStyle(.automatic)
                .onChange(of: selectedFrequency) { newValue in
                    phoneViewModel.session.transferUserInfo(["hz": self.HzOptions[newValue]])
                }
                Button {
                    phoneViewModel.session.transferUserInfo(["hz": self.HzOptions[selectedFrequency]])
                } label: {
                    Image(systemName: "arrow.clockwise").bold()
                }
            }
            .padding()
            
            //MARK: 워치 데이터 수신 확인
            VStack(alignment: .leading) {
                HStack {
                    Text("Received\ndata").font(.title).bold()
                    Spacer()
                    HStack {
                        Text("Reachable: \(reachable)")
                        Button {
                            if self.phoneViewModel.session.isReachable {
                                self.reachable = "Yes"
                                print("YES!!!")
                            } else {
                                self.reachable = "No"
                                print("NO...")
                            }
                        } label: {
                            Image(systemName: "arrow.clockwise").bold()
                        }
                    }
                }
                HStack {
                    Text("CSV file name : ").bold()
                    Text(phoneViewModel.csvFileName).italic().bold()
                }
            }
            .padding()
            
            VStack(alignment: .leading) {
                HStack {
                    Text("Saved data").font(.title).bold()
                    Spacer()
                    Text("Save Status :")
                    Text(phoneViewModel.isSucceeded)
                        .foregroundColor(phoneViewModel.isSucceeded=="Success!!!" ? .green : .red)
                        .bold()
                }
                Picker("CSV Folder", selection: $csvFolderIndex) {
                    Text("Left").tag(0)
                    Text("Right").tag(1)
                }
                .pickerStyle(.segmented)
  
                //MARK: 저장된 파일 목록
                if csvFolderIndex == 0 {
                    SavedCSVFilesView(
                        savedCSVFiles: $phoneViewModel.leftSavedCSV,
                        selectedCSVFiles: $leftSelectedCSVFiles,
                        hand: "left"
                    )
                } else {
                    SavedCSVFilesView(
                        savedCSVFiles: $phoneViewModel.rightSavedCSV,
                        selectedCSVFiles: $rightSelectedCSVFiles,
                        hand: "right"
                    )
                }
            }
            .padding()
        }
        .padding()
        .onAppear() {
            // 처음 화면이 로드될 때 저장된 CSV 파일들 목록을 불러옴
            loadCSVFiles()
        }
    }
}

extension ContentView {
    //MARK: CSV 파일을 불러오는 함수
    func loadCSVFiles() {
        let fileManager = FileManager.default // FileManager 인스턴스 생성
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0] // documents 디렉토리 경로 (계속 바뀌기 때문에 새로 불러와야 함)
        print("documentsURL: \(documentsURL)")
        let directoryName = "DeviceMotionData" // 디렉토리명
        let leftDirectoryURL = documentsURL.appendingPathComponent(directoryName).appendingPathComponent("Lefthand")
        let rightDirectoryURL = documentsURL.appendingPathComponent(directoryName).appendingPathComponent("Righthand")
        
        // 저장된 항목들 확인
        var leftFileList : [String] = []
        var rightFileList : [String] = []
        do {
            leftFileList = try FileManager.default.contentsOfDirectory(atPath: leftDirectoryURL.path)
        }
        catch {
            print("[Error] : \(error.localizedDescription)")
        }
        phoneViewModel.leftSavedCSV = leftFileList.sorted()
        
        do {
            rightFileList = try FileManager.default.contentsOfDirectory(atPath: rightDirectoryURL.path)
        }
        catch {
            print("[Error] : \(error.localizedDescription)")
        }
        phoneViewModel.rightSavedCSV = rightFileList.sorted()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
