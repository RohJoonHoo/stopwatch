# Stopwatch for Basys-3 FPGA  

## 📌 프로젝트 개요  
본 프로젝트는 Basys-3 FPGA 보드를 이용하여 스톱워치를 구현한 것입니다. 스위치를 통해 표시 모드를 변경할 수 있으며, 버튼을 이용해 스톱워치의 동작을 제어할 수 있습니다.  

## ⚙️ 기능 설명  

1. **표시 모드 전환 (Mode Switch)**  
   - **Switch 입력**을 통해 두 가지 모드 전환 가능  
     - 초 및 밀리초(sec.msec) 표시  
     - 시 및 분(hr.min) 표시  

2. **스톱워치 제어 버튼**  
   - **Run/Stop 버튼**: 스톱워치 시작 및 정지  
   - **Clear 버튼**: 스톱워치 초기화  

3. **동작 표시 (Dot Indicator)**  
   - 스톱워치가 동작 중일 때(dot indicator ON), **0.5초 간격**으로 점멸  

## 📁 파일 구성  

| 파일명 | 설명 |
|--------|------|
| `Data_Path.v` | 데이터 경로 설계 |
| `Top_stopwatch.v` | 최상위 모듈 |
| `btn_debounce.v` | 버튼 디바운스 처리 |
| `fnd_controller.v` | 7-세그먼트 디스플레이(FND) 컨트롤 |
| `stopwatch_cu.v` | 제어 유닛(Control Unit) |
| `Basys-3.xdc` | 핀맵 설정 파일 |

## 🛠 사용 방법  
1. 프로젝트를 Vivado에서 열어 **Basys-3 보드에 다운로드**합니다.  
2. 스위치를 조작하여 원하는 **표시 모드(sec.msec / hr.min)**를 선택합니다.  
3. **Run/Stop 버튼**으로 스톱워치를 시작 또는 정지할 수 있습니다.  
4. **Clear 버튼**을 누르면 시간이 초기화됩니다.  
5. 스톱워치가 실행 중일 때, Dot Indicator가 **0.5초 간격으로 깜빡입니다.**  

## ✅ 참고 사항  
- 버튼 입력에는 디바운싱 처리(`btn_debounce.v`)가 적용되었습니다.  
