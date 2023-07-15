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
    @Published var leftSavedCSV: [String]?
    @Published var rightSavedCSV: [String]?
    
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
            // 전송된 파일의 메타데이터 확인
            self.csvFileName = file.metadata?["fileName"] as? String ?? "Unknown" // 파일명
            let fileName = file.metadata?["fileName"] as? String ?? "Unknown" // 파일명
            self.handType = file.metadata?["hand"] as? String ?? "Unknown"
//            // 전송된 파일의 임시 경로
//            let tempURL = file.fileURL
//            print("temp URL: \(tempURL)")


            // 파일을 저장할 경로 설정
            let fileManager = FileManager.default // FileManager 인스턴스 생성
            let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0] // documents 디렉토리 경로 (계속 바뀌기 때문에 새로 불러와야 함)
            print("documentsURL: \(documentsURL)")
            let directoryName = "DeviceMotionData" // 디렉토리명

            //MARK: 디렉토리 만들기
            let leftDirectoryURL = documentsURL.appendingPathComponent(directoryName).appendingPathComponent("Lefthand")
            let rightDirectoryURL = documentsURL.appendingPathComponent(directoryName).appendingPathComponent("Righthand")
                //MARK: 왼쪽
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
                //MARK: 오른쪽
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
            
            //MARK: 파일 만들기
            let leftCsvURL = leftDirectoryURL.appendingPathComponent(fileName) // 파일명이 포함된 파일 저장 경로
            let rightCsvURL = rightDirectoryURL.appendingPathComponent(fileName) // 파일명이 포함된 파일 저장 경로
                //MARK: 왼쪽
            if self.handType == "left_" {
                print("저장될 파일 경로 : \(leftCsvURL)")
                // 파일 이동
                do {
                    // 저장 성공
                    try fileManager.moveItem(at: file.fileURL, to: leftCsvURL)
                    print("File saved!!! : \(fileName)")
                    print("Received and saved CSV file!!! : \(leftCsvURL)")
                    self.isSucceeded = "Success!!!"
                    session.transferUserInfo(["isSuccess": true])
                } catch {
                    // 저장 실패
                    print("Failed to save received CSV file. : \(error.localizedDescription)")
                    self.isSucceeded = "Fail..."
                    session.transferUserInfo(["isSuccess": false])
                }
                // 저장된 항목들 확인
                var fileList : [String] = []
                do {
                    fileList = try fileManager.contentsOfDirectory(atPath: leftDirectoryURL.path)
                }
                catch {
                    print("[Error] : \(error.localizedDescription)")
                }
                self.leftSavedCSV = fileList.sorted()
                print("디렉토리 내용 확인: \(self.leftSavedCSV!)")
                print("===========================================================\n\n")
            }
            //MARK: 오른쪽
            else {
                print("저장될 파일 경로 : \(rightCsvURL)")
                // 파일 이동
                do {
                    // 저장 성공
                    try fileManager.moveItem(at: file.fileURL, to: rightCsvURL)
                    print("File saved!!! : \(fileName)")
                    print("Received and saved CSV file!!! : \(rightCsvURL)")
                    self.isSucceeded = "Success!!!"
                    session.transferUserInfo(["isSuccess": true])
                } catch {
                    // 저장 실패
                    print("Failed to save received CSV file. : \(error.localizedDescription)")
                    self.isSucceeded = "Fail..."
                    session.transferUserInfo(["isSuccess": false])
                }
                // 저장된 항목들 확인
                var fileList : [String] = []
                do {
                    fileList = try fileManager.contentsOfDirectory(atPath: rightDirectoryURL.path)
                }
                catch {
                    print("[Error] : \(error.localizedDescription)")
                }
                self.rightSavedCSV = fileList.sorted()
                print("디렉토리 내용 확인: \(self.rightSavedCSV!))")
                print("===========================================================\n\n")
            }


//            if fileManager.fileExists(atPath: directoryURL.path) {
//                print("디렉토리 경로 확인됨: \(directoryURL.path)")
//            } else {
//                print("디렉토리 경로가 없대요;;;: \(directoryURL.path)")
//            }
//            if fileManager.fileExists(atPath: file.fileURL.path) {
//                print("받아온 파일 경로 확인됨: \(file.fileURL.path)")
//            } else {
//                print("받아온 파일이 없대요;;;: \(file.fileURL.path)")
//            }
//            if fileManager.fileExists(atPath: csvURL.path) {
//                print("저장할 경로 : \(csvURL)")
//            } else {
//                print("저장할 경로 확인 안됨;;;")
//            }


        }
    }
}

