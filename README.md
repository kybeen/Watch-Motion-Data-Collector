# Watch-Motion-Data-Collector
애플워치에서 Core Motion 프레임워크로 수집된 센서 데이터를 연결된 아이폰에서 CSV 파일로 저장할 수 있게 해주는 앱입니다.
----

### ⌚️ watchOS
- ✅ 애플워치에서 데이터 수집 시작 버튼을 누르면 Core Motion 프레임워크를 활용해 애플워치의 Device Motion 센서값을 트래킹하며 저장합니다.

  <img width="250" alt="image" src="https://github.com/kybeen/Watch-Motion-Data-Collector/assets/89764127/0601aee9-8e36-4c57-b34e-966b87e2735a">


- ✅ 수집 종료 버튼을 누르면 Device Motion 센서 데이터를 CSV 파일로 저장한 뒤, 페어링된 아이폰으로 전송합니다.
  <img width="250" alt="image" src="https://github.com/kybeen/Watch-Motion-Data-Collector/assets/89764127/b66507a6-9422-452c-ba4d-2f51fef669ec">


### 📱 iOS
- ✅ 아이폰에서는 연결 상태 확인, 데이터 수집한 사람 이름 설정, Frequency 설정이 가능합니다.
- ✅ 애플워치로부터 성공적으로 CSV 파일을 받으면 확인 가능하고, 잘못 저장된 파일은 삭제가 가능합니다.
  <img width="250" alt="image" src="https://github.com/kybeen/Watch-Motion-Data-Collector/assets/89764127/bfe7922c-d4df-4389-a45f-6b444c37661e">
