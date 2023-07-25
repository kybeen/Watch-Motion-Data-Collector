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
    
    @State private var selectedFrequency = 4
    let HzOptions = [10, 20, 30, 40, 50, 60, 70, 80, 90, 100]
    @State var testerName = ""
    @State private var csvFolderIndex = 0
    @State private var forehandSelectedCSVFiles: [String] = [] // 선택된 파일들 (삭제용)
    @State private var backhandSelectedCSVFiles: [String] = [] // 선택된 파일들 (삭제용)
    
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
            
            //MARK: 테스터 이름 입력 (파일명에 반영됨)
            HStack {
                Text("Tester name").font(.title2).bold()
                Spacer()
                TextField("Enter name", text: $testerName).textFieldStyle(.roundedBorder)
                    .frame(width: UIScreen.main.bounds.width*0.3)
                Button("Done") {
                    print("이름 입력: \(self.testerName)")
                    phoneViewModel.session.transferUserInfo(["testerName": self.testerName])
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
                    Text("Forehand").tag(0)
                    Text("Backhand").tag(1)
                }
                .pickerStyle(.segmented)
  
                //MARK: 저장된 파일 목록
                if csvFolderIndex == 0 {
                    SavedCSVFilesView(
                        savedCSVFiles: $phoneViewModel.forehandSavedCSV,
                        selectedCSVFiles: $forehandSelectedCSVFiles,
                        swingType: "forehand"
                    )
                } else {
                    SavedCSVFilesView(
                        savedCSVFiles: $phoneViewModel.backhandSavedCSV,
                        selectedCSVFiles: $backhandSelectedCSVFiles,
                        swingType: "backhand"
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
        let forehandDirectoryURL = documentsURL.appendingPathComponent(directoryName).appendingPathComponent("Forehand")
        let backhandDirectoryURL = documentsURL.appendingPathComponent(directoryName).appendingPathComponent("Backhand")
        
        // 저장된 항목들 확인
        var forehandFileList : [String] = []
        var backhandFileList : [String] = []
        do {
            forehandFileList = try FileManager.default.contentsOfDirectory(atPath: forehandDirectoryURL.path)
        }
        catch {
            print("[Error] : \(error.localizedDescription)")
        }
        phoneViewModel.forehandSavedCSV = forehandFileList.sorted()
        
        do {
            backhandFileList = try FileManager.default.contentsOfDirectory(atPath: backhandDirectoryURL.path)
        }
        catch {
            print("[Error] : \(error.localizedDescription)")
        }
        phoneViewModel.backhandSavedCSV = backhandFileList.sorted()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
