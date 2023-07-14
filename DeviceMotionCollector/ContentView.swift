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
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                Text("Frequency select").font(.title).bold()
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
            }
            .padding()
            
            VStack(alignment: .leading) {
                HStack {
                    Text("Received\ndata").font(.title).bold()
                    Spacer()
                    VStack {
                        Button("Update") {
                            if self.phoneViewModel.session.isReachable {
                                self.reachable = "Yes"
                                print("YES!!!")
                            } else {
                                self.reachable = "No"
                                print("NO...")
                            }
                        }
                        .padding(5)
                        .background(.blue)
                        .foregroundColor(.white)
                        .cornerRadius(5)
                        
                        Text("Reachable: \(reachable)")
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
                    Text("Saved\ndata").font(.title).bold()
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
                
                
                List {
                    Section(header: Text("Saved Files")) {
                        if csvFolderIndex == 0 {
                            //MARK: 왼손잡이 데이터
                            if let savedCSVFiles = phoneViewModel.leftSavedCSV {
                                ForEach(savedCSVFiles, id: \.self) { savedCSVFile in
                                    Text(savedCSVFile)
                                }
                            }
                        } else {
                            //MARK: 오른손잡이 데이터
                            if let savedCSVFiles = phoneViewModel.rightSavedCSV {
                                ForEach(savedCSVFiles, id: \.self) { savedCSVFile in
                                    Text(savedCSVFile)
                                }
                            }
                        }
                    }
                }
                .cornerRadius(10)
            }
            .padding()
        }
        .padding()
        .onAppear() {
            // 처음 화면이 로드될 때 디렉토리 생성 체크하고, 저장된 CSV 파일들 목록을 불러옴
            createDirectory()
            loadCSVFiles()
        }
    }
}

extension ContentView {
    //MARK: CSV 파일을 저장할 디렉토리를 만드는 함수
    func createDirectory() {
        // 파일을 저장할 경로 설정
        let fileManager = FileManager.default // FileManager 인스턴스 생성
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0] // documents 디렉토리 경로 (계속 바뀌기 때문에 새로 불러와야 함)
        print("documentsURL: \(documentsURL)")
        let directoryName = "DeviceMotionData" // 디렉토리명

        // 디렉토리 만들기
        let leftDirectoryURL = documentsURL.appendingPathComponent(directoryName).appendingPathComponent("Lefthand")
        let rightDirectoryURL = documentsURL.appendingPathComponent(directoryName).appendingPathComponent("Righthand")
        //MARK: DeviceMotionData 폴더가 이미 존재하는지 확인 후 생성
        // 왼쪽
        if !fileManager.fileExists(atPath: leftDirectoryURL.path) {
            do {
                try fileManager.createDirectory(atPath: leftDirectoryURL.path, withIntermediateDirectories: true, attributes: nil)
                print("DeviceMotionData/Lefthand 디렉토리 생성 완료!!! : \(leftDirectoryURL)")
            } catch {
                NSLog("Couldn't create DeviceMotionData/Lefthand directory.")
            }
        } else {
            print("Lefthand 디렉토리가 이미 존재하기 때문에 생성하지 않았습니다.\nDirectory URL : \(leftDirectoryURL)")
        }
        // 오른쪽
        if !fileManager.fileExists(atPath: rightDirectoryURL.path) {
            do {
                try fileManager.createDirectory(atPath: rightDirectoryURL.path, withIntermediateDirectories: true, attributes: nil)
                print("DeviceMotionData/Righthand 디렉토리 생성 완료!!! : \(rightDirectoryURL)")
            } catch {
                NSLog("Couldn't create DeviceMotionData/Righthand directory.")
            }
        } else {
            print("Righthand 디렉토리가 이미 존재하기 때문에 생성하지 않았습니다.\nDirectory URL : \(rightDirectoryURL)")
        }
    }
    
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
        print("Lefthand 디렉토리 내용 확인: \(phoneViewModel.leftSavedCSV!)")
        
        do {
            rightFileList = try FileManager.default.contentsOfDirectory(atPath: rightDirectoryURL.path)
        }
        catch {
            print("[Error] : \(error.localizedDescription)")
        }
        phoneViewModel.rightSavedCSV = rightFileList.sorted()
        print("Righthand 디렉토리 내용 확인: \(phoneViewModel.rightSavedCSV!)")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
