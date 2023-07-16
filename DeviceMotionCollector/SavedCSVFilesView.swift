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
                    print(selectedCSVFiles)
                } label: {
                    Label("Delete", systemImage: "trash")
                        .foregroundColor(.red)
                }
            }
        }
    }
}

//struct SavedCSVFilesView_Previews: PreviewProvider {
//    static var previews: some View {
//        SavedCSVFilesView()
//    }
//}
