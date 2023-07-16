//
//  PhoneViewModel.swift
//  DeviceMotionCollector
//
//  Created by 김영빈 on 2023/07/09.
//

import Foundation
import WatchConnectivity

class PhoneViewModel: NSObject, WCSessionDelegate, ObservableObject {
    var session: WCSession
    init(session: WCSession = .default) {
        self.session = session
        super.init()
        session.delegate = self
        session.activate()
    }

    @Published var csvFileName = ""
    @Published var handType = "left_"
    @Published var isSucceeded = "Fail..."
    @Published var leftSavedCSV: [String] = []
    @Published var rightSavedCSV: [String] = []
    
    //MARK: 델리게이트 메서드 3개 정의
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    }
    func sessionDidBecomeInactive(_ session: WCSession) {
    }
    func sessionDidDeactivate(_ session: WCSession) {
    }
    
//    //MARK: 다른 기기의 세션으로부터 transferUserInfo(_:) 메서드로 데이터를 받았을 떄 호출되는 메서드
//    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
//        DispatchQueue.main.async {
//            // 받아온 데이터 저장
//            self.csvString = userInfo["csv"] as? String ?? ""
//            self.activityType = userInfo["activity"] as? String ?? ""
//            self.handType = userInfo["hand"] as? String ?? ""
//            self.saveToCSV()
//        }
//    }
    //MARK: 다른 기기의 세션으로부터 transferFile(_:metadata:) 메서드로 파일을 받았을 떄 호출되는 메서드
    func session(_ session: WCSession, didReceive file: WCSessionFile) {
        DispatchQueue.main.async {
            print("===========================================================")
            /* 전송된 파일의 메타데이터 확인 */
            self.csvFileName = file.metadata?["fileName"] as? String ?? "Unknown" // 파일명
            let fileName = file.metadata?["fileName"] as? String ?? "Unknown" // 파일명
            self.handType = file.metadata?["hand"] as? String ?? "Unknown"
//            let tempURL = file.fileURL // 전송된 파일의 임시 경로

            /* 파일을 저장할 경로 설정 */
            let fileManager = FileManager.default // FileManager 인스턴스 생성
            let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0] // documents 디렉토리 경로 (계속 바뀌기 때문에 새로 불러와야 함)
            print("documentsURL: \(documentsURL)")
            var directoryName = "DeviceMotionData" // 디렉토리명
            if self.handType == "left_" {
                directoryName += "/Lefthand"
            } else {
                directoryName += "/Righthand"
            }
            /* 디렉토리 만들기 */
            let directoryURL = documentsURL.appendingPathComponent(directoryName)
            if !fileManager.fileExists(atPath: directoryURL.path) {
                do {
                    try fileManager.createDirectory(atPath: directoryURL.path, withIntermediateDirectories: true, attributes: nil)
                    print("\(directoryName) 디렉토리 생성 완료!!! : \(directoryURL)")
                } catch {
                    NSLog("Couldn't create \(directoryName) directory.")
                }
            } else {
                print("\(directoryName) 디렉토리가 이미 존재하기 때문에 생성하지 않았습니다.\nDirectory URL : \(directoryURL)")
            }
            /* 파일 만들기 */
            let csvURL = directoryURL.appendingPathComponent(fileName) // 파일 저장 경로
            print("저장될 파일 경로 : \(csvURL)")
            do {
                // 정상적으로 아이폰으로 파일 이동
                try fileManager.moveItem(at: file.fileURL, to: csvURL)
                print("File saved!!! : \(fileName)")
                print("Received and saved CSV file!!! : \(csvURL)")
                self.isSucceeded = "Success!!!"
                session.transferUserInfo(["isSuccess": true])
            } catch {
                // 파일 이동 실패
                print("Failed to save received CSV file. : \(error.localizedDescription)")
                self.isSucceeded = "Fail..."
                session.transferUserInfo(["isSuccess": false])
            }
            // 저장된 항목들 확인
            var fileList : [String] = []
            do {
                fileList = try fileManager.contentsOfDirectory(atPath: directoryURL.path)
            } catch {
                print("[Error] : \(error.localizedDescription)")
            }
            if self.handType == "left_" {
                self.leftSavedCSV = fileList.sorted()
            } else {
                self.rightSavedCSV = fileList.sorted()
            }
        }
    }
}

