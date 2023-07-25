//
//  SavedCSVFilesView.swift
//  DeviceMotionCollector
//
//  Created by 김영빈 on 2023/07/17.
//

import SwiftUI

struct SavedCSVFilesView: View {
    @Binding var savedCSVFiles: [String] // 저장된 파일들
    @Binding var selectedCSVFiles: [String] // 선택된 파일들
    let swingType: String
    
    var body: some View {
        //MARK: 저장된 CSV 파일 목록
        List {
            Section(header: HStack {
                Text("Saved Files")
                Spacer()
                Text("\(selectedCSVFiles.count) files selected").bold()
            }) {
                ForEach(savedCSVFiles, id: \.self) { savedCSVFile in
                    HStack {
                        if selectedCSVFiles.contains(savedCSVFile) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.blue)
                                .onTapGesture {
                                    selectedCSVFiles.removeAll { $0 == savedCSVFile }
                                }
                        } else {
                            Image(systemName: "circle")
                                .foregroundColor(.gray)
                                .onTapGesture {
                                    selectedCSVFiles.append(savedCSVFile)
                                }
                        }
                        Text(savedCSVFile)
                    }
                }
            }
        }
        .cornerRadius(10)
        
        if selectedCSVFiles.count > 0 {
            HStack {
                Button("Cancel") {
                    selectedCSVFiles = []
                }
                Spacer()
                //MARK: 삭제 버튼
                Button {
                    deleteSelectedCSVFiles(swingType: swingType, selectedCSVFiles: selectedCSVFiles)
                    selectedCSVFiles = []
                    print("파일 선택 배열 초기화 : \(selectedCSVFiles)")
                } label: {
                    Label("Delete", systemImage: "trash")
                        .foregroundColor(.red)
                }
            }
        }
    }
}

extension SavedCSVFilesView {
    //MARK: CSV 파일 삭제 함수
    func deleteSelectedCSVFiles(swingType: String, selectedCSVFiles: [String]) {
        let fileManager = FileManager.default // FileManager 인스턴스 생성
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0] // documents 디렉토리 경로 (계속 바뀌기 때문에 새로 불러와야 함)
        var directoryName = "DeviceMotionData" // 디렉토리명
        if swingType == "forehand" {
            directoryName += "/Forehand"
        } else {
            directoryName += "/Backhand"
        }
        let directoryURL = documentsURL.appendingPathComponent(directoryName)
        
        for csvFile in selectedCSVFiles {
            let fileURL = directoryURL.appendingPathComponent(csvFile)
            do {
                try fileManager.removeItem(at: fileURL)
            } catch {
                print("Failed to delete file: \(csvFile), error: \(error)")
            }
        }
        
        // 삭제 확인
        var fileList : [String] = []
        do {
            fileList = try fileManager.contentsOfDirectory(atPath: directoryURL.path)
        } catch {
            print("[Error] : \(error.localizedDescription)")
        }
        print("\(directoryURL)의 경로에 남은 파일들입니다.")
        print(fileList)
        savedCSVFiles = fileList.sorted()
    }
}

//struct SavedCSVFilesView_Previews: PreviewProvider {
//    static var previews: some View {
//        SavedCSVFilesView()
//    }
//}
