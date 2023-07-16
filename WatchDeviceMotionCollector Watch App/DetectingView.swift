//
//  DetectingView.swift
//  WatchDeviceMotionCollector Watch App
//
//  Created by 김영빈 on 2023/07/16.
//

//import SwiftUI
//
//struct DetectingView: View {
//    @ObservedObject var watchViewModel: WatchViewModel
//    @Binding var selectedTab: Int
//    
//    let handType: String?
//    let handTypeLabel: String?
//    @State var activityLabel = "포핸드"
//    @State var isUpdating = false // 기록 시작/종료 버튼 표시용
//    @State var isHandShowingGuide = true // 처음에 착용 손목 가이드 화면 나오도록
//    @State var activityType = "forehand_" // 저장 파일명에 들어갈 자세명
//    @State var num = 1 // 저장 파일명에 들어갈 번호
//    @State var isDetecting = true
//    @State var isShowingModal = false // 저장하기 전 한 번 더 확인하기 위한 메세지
//    
//    var body: some View {
//        if isHandShowingGuide {
//            Text("애플워치를 \(handTypeLabel!)에 착용해주세요.").font(.largeTitle).bold()
//                .onTapGesture {
//                    isHandShowingGuide = false
//                    if handTypeLabel == "왼손" {
//                        selectedTab = 1
//                    } else {
//                        selectedTab = 2
//                    }
//                }
//        } else {
//            VStack {
//                //MARK: 저장될 파일명 / 모션 데이터 frequency / 경과 시간 확인
//                Text("\(handType!)\(activityType)\(num).csv").bold()
//                HStack {
//                    Text("\(watchViewModel.hzValue)Hz - ").bold().foregroundColor(.indigo)
//                    Text("\(watchViewModel.timestamp)") // 타임스탬프
//                }
//                HStack {
//                    //MARK: 저장 파일명 번호 설정
//                    Button("-") {
//                        if num > 1 {
//                            num -= 1
//                        }
//                    }.frame(width: 50)
//                    Text("\(num)")
//                    Button("+") {
//                        num += 1
//                    }.frame(width: 50)
//                }
//                HStack {
//                    //MARK: 자세 선택 버튼
//                    Button(activityLabel) {
//                        if activityType == "forehand_" {
//                            activityType = "backhand_"
//                            activityLabel = "백핸드"
//                        } else {
//                            activityType = "forehand_"
//                            activityLabel = "포핸드"
//                        }
//                        num = 1
//                    }
//                    .foregroundColor(activityType=="forehand_" ? .orange : .purple)
//                    
//                    if isUpdating {
//                        //MARK: 기록 종료 버튼
//                        Button("Stop") {
//                            watchViewModel.stopRecording()
//                            isUpdating = false
//                            isDetecting = false
//                            isShowingModal = true
//                        }.foregroundColor(.red)
//                    } else {
//                        //MARK: 기록 시작 버튼
//                        Button("Start") {
//                            watchViewModel.startRecording()
//                            isUpdating = true
//                            isDetecting = true
//                            watchViewModel.isSentCSV = false
//                        }.foregroundColor(.green)
//                    }
//                }
//                
//                HStack {
//                    Text("\(handTypeLabel!)잡이")
//                        .foregroundColor(handType=="left_" ? .yellow : .purple)
//                        .font(.headline)
//                        .bold() //TODO: 글자색 손에 따라 다르게 바꾸기
//                    //MARK: 전송 완료 시 전송완료 메시지
//                    if watchViewModel.isSentCSV {
//                        HStack {
//                            if isDetecting == false {
//                                Text("전송!").bold().foregroundColor(.blue)
//                                if watchViewModel.isSuccess {
//                                    Text("성공").bold().foregroundColor(.green)
//                                } else {
//                                    Text("실패").bold().foregroundColor(.red)
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//            .padding()
//            .fullScreenCover(isPresented: $isShowingModal) {
//                VStack {
//                    Text("정말로 저장하시겠습니까?")
//                    Button {
//                        isShowingModal = false
//                        // .csv 파일로 만들고 전송
//                        watchViewModel.saveAndSendToCSV(
//                            handType: handType!,
//                            activityType: activityType,
//                            num: num
//                        )
//                    } label: {
//                        Text("네")
//                    }
//                    Button {
//                        isShowingModal = false
//                    } label: {
//                        Text("아니오").foregroundColor(.red)
//                    }
//                }
//            }
//        }
//    }
//}
