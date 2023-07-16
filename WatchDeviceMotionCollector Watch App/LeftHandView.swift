//
//  HomeView.swift
//  WatchDeviceMotionCollector Watch App
//
//  Created by 김영빈 on 2023/07/09.
//

import SwiftUI
import CoreMotion

struct LeftHandView: View {
    let motionManager = CMMotionManager()
    @ObservedObject var watchViewModel: WatchViewModel
    
    //MARK: 모션 데이터 값
    @State var timestamp: Double = 0.0
    //MARK: 동작 상태, 저장될 파일명 등에 대한 정보
    @State private var isUpdating = false
    @State var isSentCSV = false
    @State var isLeftShowingGuide = true
    @Binding var selectedTab: Int
    @State var csvString = ""
    @State var activityType = "forehand_"
    @State var activityLabel = "포핸드"
    @State var handType = "left_"
    @State var num = 1
    @State var isDetecting = true
    @State var isShowingModal = false // 저장하기 전 한 번 더 확인하기 위한 메세지
    
    var body: some View {
        if isLeftShowingGuide {
            Text("애플워치를 왼손에 착용해주세요.").font(.largeTitle).bold()
                .onTapGesture {
                    isLeftShowingGuide = false
                    selectedTab = 1
                }
        } else {
            VStack {
                //MARK: 저장될 파일명 / 모션 데이터 frequency / 경과 시간 확인
                Text("\(handType)\(activityType)\(num).csv").bold()
                HStack {
                    Text("\(watchViewModel.hzValue)Hz - ").bold().foregroundColor(.indigo)
                    Text("\(timestamp)") // 타임스탬프
                }
                HStack {
                    //MARK: 저장 파일명 번호 설정
                    Button("-") {
                        if num > 1 {
                            num -= 1
                        }
                    }.frame(width: 50, height: 50)
                    Text("\(num)")
                    Button("+") {
                        num += 1
                    }.frame(width: 50, height: 50)
                }
                HStack {
                    //MARK: 자세 선택 버튼
                    Button(activityLabel) {
                        if activityType == "forehand_" {
                            activityType = "backhand_"
                            activityLabel = "백핸드"
                            num = 1
                        }
                        else {
                            activityType = "forehand_"
                            activityLabel = "포핸드"
                            num = 1
                        }
                    }
                    .foregroundColor(activityType=="forehand_" ? .orange : .purple)
                    
                    if isUpdating {
                        //MARK: 기록 중료 버튼
                        Button("Stop") {
                            stopRecording()
                            isUpdating = false
                            isDetecting = false
                            isShowingModal = true
                        }.foregroundColor(.red)
                    }
                    else {
                        //MARK: 기록 시작 버튼
                        Button("Start") {
                            startRecording()
                            isUpdating = true
                            isSentCSV = false
                            isDetecting = true
                        }.foregroundColor(.green)
                    }
                }
                
                HStack {
                    Text("왼손잡이").foregroundColor(.yellow).font(.headline).bold()
                    //MARK: 전송 완료 시 전송완료 메세지
                    if isSentCSV {
                        HStack {
                            if isDetecting == false {
                                Text("전송!").bold().foregroundColor(.blue)
                                if watchViewModel.isSuccess {
                                    Text("성공").bold().foregroundColor(.green)
                                } else {
                                    Text("실패").bold().foregroundColor(.red)
                                }
                            }
                        }
                    }
                }
            }
            .padding()
            .fullScreenCover(isPresented: $isShowingModal) {
                VStack {
                    Text("정말로 저장하시겠습니까?")
                    Button {
                        isShowingModal = false
                        // .csv 파일로 만들고 전송
                        saveAndSendToCSV()
                    } label: {
                        Text("네")
                    }
                    Button {
                        isShowingModal = false
                    } label: {
                        Text("아니오").foregroundColor(.red)
                    }
                }
            }
        }
    }
}

extension LeftHandView {
    //MARK: Device Motion 레코딩 시작 함수
    func startRecording() {
        self.csvString = "Time Stamp,Acceleration X,Acceleration Y,Acceleration Z,Rotation Rate X,Rotation Rate Y,Rotation Rate Z\n"
        // 작업 큐 설정
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1 // 동시에 실행할 수 있는 대기 중 작업의 최대 개수
        
        // Device Motion 수집 가능한지 확인
        guard motionManager.isDeviceMotionAvailable else {
            print("Device motion data is not available.")
            return
        }
        
        // 모션 갱신 주기 설정 (몇 초마다 모션 데이터를 업데이트 할 지)
        motionManager.deviceMotionUpdateInterval = TimeInterval(1 / watchViewModel.hzValue)
        print("모션 갱신 주기 설정 : \(watchViewModel.hzValue)Hz -> \(String(format: "%.2f", 1/watchViewModel.hzValue))")
        var startTime: TimeInterval = 0.0 //MARK: 시작 시간 저장 변수
        // Device Motion 업데이트 받기 시작
        motionManager.startDeviceMotionUpdates(to: queue) { (data, error) in
            guard let motion = data, error == nil else {
                print("Failed to get device motion data: \(error?.localizedDescription ?? "Uknown error")")
                return
            }
            // 스윙 모션 감지에 필요한 데이터 불러오기
            let acceleration = motion.userAcceleration
            let rotationRate = motion.rotationRate
            
            if startTime == 0.0 {
                startTime = motion.timestamp //MARK: 첫 번째 데이터의 타임스탬프 저장
            }
            let timestamp = motion.timestamp - startTime //MARK: 시작 시간으로부터 경과한 시간 계산
            let addCSV = "\(timestamp), \(acceleration.x), \(acceleration.y), \(acceleration.z), \(rotationRate.x), \(rotationRate.y), \(rotationRate.z)\n"
            csvString = csvString + addCSV
            print("Timestamp : \(timestamp)")
            
            self.timestamp = timestamp //MARK: UI 업데이트는 메인 큐에서 실행
        }
    }
    
    //MARK: Device Motion 레코딩 종료 함수
    func stopRecording() {
        motionManager.stopDeviceMotionUpdates()
    }
    
    //MARK: CSV 파일 만들고 아이폰으로 전송해주는 함수
    func saveAndSendToCSV() {
        let fileManager = FileManager.default
        
        // 폴더명 설정
        let folderName = "DeviceMotionData"
        // 파일명 설정
        let csvFileName = self.handType + self.activityType + String(num) + ".csv"

        //MARK: 폴더 생성
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        print("documentsURL: \(documentsURL)")
        let directoryURL = documentsURL.appendingPathComponent(folderName)
        if !fileManager.fileExists(atPath: directoryURL.path) {
            do {
                try fileManager.createDirectory(atPath: directoryURL.path, withIntermediateDirectories: true, attributes: nil)
                print("DeviceMotionData 디렉토리 생성 완료!!! : \(directoryURL)")
            } catch {
                NSLog("Couldn't create directory")
            }
        } else {
            print("Directory URL : \(directoryURL)")
        }

        //MARK: CSV 파일 생성(저장)
        let csvURL = directoryURL.appendingPathComponent(csvFileName)
        print("File URL : \(csvURL)")
        print("저장될 파일 경로 : \(csvURL)")
        do {
            try self.csvString.write(to: csvURL, atomically: true, encoding: .utf8)
            print("CSV file saved at: \(csvURL)")
            print("File name : \(csvFileName)")
        }
        catch let error as NSError {
            print("Failed to save CSV file: \(error.localizedDescription)")
        }
        
        //MARK: CSV 파일 아이폰으로 전송
        watchViewModel.session.transferFile(csvURL, metadata: ["activity": activityType, "hand": handType, "fileName": csvFileName])
        print("CSV파일이 아이폰으로 전송됨!!!")
        isSentCSV = true
    }
}
//struct LeftHandView_Previews: PreviewProvider {
//    static var previews: some View {
//        LeftHandView()
//    }
//}
