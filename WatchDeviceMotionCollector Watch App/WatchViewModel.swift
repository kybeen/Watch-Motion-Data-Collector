//
//  WatchViewModel.swift
//  WatchDeviceMotionCollector Watch App
//
//  Created by 김영빈 on 2023/07/09.
//

//import Foundation
//import WatchConnectivity
//import CoreMotion
//import SwiftUI
//
//class WatchViewModel: NSObject, WCSessionDelegate, ObservableObject {
//    var session: WCSession
//    init(session: WCSession = .default) {
//        self.session = session
//        super.init()
//        session.delegate = self
//        session.activate()
//    }
//    @Published var hzValue = 100
//    @Published var isSuccess = false
//
//    let motionManager = CMMotionManager()
//    //MARK: 모션 데이터 값
//    @Published var timestamp: Double = 0.0
//    @Published var accelerationX: Double = 0.0
//    @Published var accelerationY: Double = 0.0
//    @Published var accelerationZ: Double = 0.0
//    @Published var rotationRateX: Double = 0.0
//    @Published var rotationRateY: Double = 0.0
//    @Published var rotationRateZ: Double = 0.0
//    //MARK: 동작 상태, 저장될 파일명 등에 대한 정보
////    @Published var isUpdating = false
//    @Published var isSentCSV = false
////    @Published var isHandShowingGuide = true
//    @Published var csvString = ""
////    @Published var activityType = "forehand_"
////    @Published var activityLabel = "포핸드"
////    @Published var handType = "left_"
////    @Published var num = 1
////    @Published var isDetecting = true
////    @Published var isShowingModal = false // 저장하기 전 한 번 더 확인하기 위한 메세지
//
//    //MARK: 델리게이트 메서드
//    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
//    }
//
//    //MARK: 다른 기기의 세션으로부터 transferUserInfo(_:) 메서드로 데이터를 받았을 떄 호출되는 메서드
//    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
//        DispatchQueue.main.async {
//            // 받아온 데이터 저장
//            self.hzValue = userInfo["hz"] as? Int ?? 100
//            self.isSuccess = userInfo["isSuccess"] as? Bool ?? false
//        }
//    }
//
//    //MARK: Device Motion 레코딩 시작 함수
//    func startRecording() {
//        self.csvString = "Time Stamp,Acceleration X,Acceleration Y,Acceleration Z,Rotation Rate X,Rotation Rate Y,Rotation Rate Z\n"
//        // 작업 큐 설정
//        let queue = OperationQueue()
//        queue.maxConcurrentOperationCount = 1 // 동시에 실행할 수 있는 대기 중 작업의 최대 개수
//
//        // Device Motion 수집 가능한지 확인
//        guard motionManager.isDeviceMotionAvailable else {
//            print("Device motion data is not available!!!")
//            return
//        }
//
//        // 모션 갱신 주기 설정 (몇 초마다 모션 데이터를 업데이트 할 지)
//        motionManager.deviceMotionUpdateInterval = TimeInterval(1 / self.hzValue)
//        print("모션 갱신 주기 설정 : \(self.hzValue)Hz -> \(String(format: "%.2f", 1/self.hzValue))")
//        var startTime: TimeInterval = 0.0 //MARK: 시작 시간 저장 변수
//        // Device Motion 업데이트 받기 시작
//        motionManager.startDeviceMotionUpdates(to: queue) { (data, error) in
//            guard let motion = data, error == nil else {
//                print("Failed to get device motion data: \(error?.localizedDescription ?? "Unknown error")")
//                return
//            }
//            // 스윙 모션 감지에 필요한 데이터 불러오기
//            let acceleration = motion.userAcceleration
//            let rotationRate = motion.rotationRate
//
//            if startTime == 0.0 {
//                startTime = motion.timestamp //MARK: 첫 번째 데이터의 타임스탬프 저장
//            }
//            let timestamp = motion.timestamp - startTime //MARK: 시작 시간으로부터 경과한 시간 계산
//            let addCSV = "\(timestamp), \(acceleration.x), \(acceleration.y), \(acceleration.z), \(rotationRate.x), \(rotationRate.y), \(rotationRate.z)\n"
//            self.csvString = self.csvString + addCSV
//            print("Timestamp : \(timestamp)")
//
//            self.timestamp = timestamp //MARK: UI 업데이트는 메인 큐에서 실행
//            self.accelerationX = acceleration.x
//            self.accelerationY = acceleration.y
//            self.accelerationZ = acceleration.z
//            self.rotationRateX = rotationRate.x
//            self.rotationRateY = rotationRate.y
//            self.rotationRateZ = rotationRate.z
//        }
//    }
//
//    //MARK: Device Motion 레코딩 종료 함수
//    func stopRecording() {
//        motionManager.stopDeviceMotionUpdates()
//    }
//
//    //MARK: CSV 파일 만들고 아이폰으로 전송해주는 함수
//    func saveAndSendToCSV(handType: String, activityType: String, num: Int) {
//        let fileManager = FileManager.default
//        // 폴더명 설정
//        var folderName = "DeviceMotionData"
////        if selectedTab == 1 {
////            folderName += "/Lefthand"
////        } else {
////            folderName += "/Righthand"
////        }
//        // 파일명 설정
//        let csvFileName = handType + activityType + String(num) + ".csv"
//
//        //MARK: 폴더 생성
//        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
//        print("documentsURL: \(documentsURL)")
//        let directoryURL = documentsURL.appendingPathComponent(folderName)
//        if !fileManager.fileExists(atPath: directoryURL.path) {
//            do {
//                try fileManager.createDirectory(atPath: directoryURL.path, withIntermediateDirectories: true, attributes: nil)
//                print("\(folderName) 디렉토리 생성 완료!!! : \(directoryURL)")
//            } catch {
//                NSLog("Couldn't create directory.")
//            }
//        } else {
//            print("Directory URL : \(directoryURL)")
//        }
//
//        //MARK: CSV 파일 생성(저장)
//        let csvURL = directoryURL.appendingPathComponent(csvFileName)
//        print("File URL : \(csvURL)")
//        print("저장될 파일 경로 : \(csvURL)")
//        do {
//            try self.csvString.write(to: csvURL, atomically: true, encoding: .utf8)
//            print("CSV file saved at: \(csvURL)")
//            print("File name : \(csvFileName)")
//        } catch let error as NSError {
//            print("Failed to save CSV file : \(error.localizedDescription)")
//        }
//
//        //MARK: CSV 파일 아이폰으로 전송
//        session.transferFile(csvURL, metadata: ["activity": activityType, "hand": handType, "fileName": csvFileName])
//        print("CSV파일이 아이폰으로 전송됨!!!")
//        isSentCSV = true
//    }
//}







import Foundation
import WatchConnectivity

class WatchViewModel: NSObject, WCSessionDelegate, ObservableObject {
    var session: WCSession
    init(session: WCSession = .default) {
        self.session = session
        super.init()
        session.delegate = self
        session.activate()
    }

    @Published var hzValue = 100
    @Published var isSuccess = false

    //MARK: 델리게이트 메서드
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    }

    //MARK: 다른 기기의 세션으로부터 transferUserInfo(_:) 메서드로 데이터를 받았을 떄 호출되는 메서드
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        DispatchQueue.main.async {
            // 받아온 데이터 저장
            self.hzValue = userInfo["hz"] as? Int ?? 100
            self.isSuccess = userInfo["isSuccess"] as? Bool ?? false
        }
    }
}
