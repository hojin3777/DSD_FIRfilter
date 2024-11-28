Code description
--- 
---
### ReConf_FirFilter.v
- PDF의 모듈 구조를 그대로 따르며, Controller(FSM)은 FSM과 ModuleSelector로 나뉘어져 있음
- iNumOfCoeff[5:0]은 사용되지 않음
- SpSram 모듈과 MAC 모듈은 동일한 모듈을 4개씩 instantiation 하여 사용
- 대부분의 입력은 FSM을 통해 입력되며, 출력은 MACSum 모듈에서 나온 출력으로 전달

### SpSram10x16.v
- iCsnRam == 0 && iWrnRam == 0 인 경우 write 모드로 동작.
iAddrRam의 값에 따라 input으로 들어온 iWtDtRam값을 rRam[i]에 순차적으로 저장
- iCsnRam == 0 && iWrnRam == 0 인 경우 read 모드로 동작.
iAddrRam의 값에 따라 rRam[i]의 값을 rRdbuffer에 담아 output port에 assign

### MAC.v
- iEnMul==1일때 Ram과 DelayChain에서 들어온 신호를 곱해 DFF에 따라 한 클럭 딜레이 후 누산기에 보냄
- iEnAddACC==1일때 매 클럭마다 곱셈 연산 결과를 누적합에 더함
- iEnMul 신호와 iEnAddAcc 신호 모두 enable 신호가 들어온 후 다음 클럭부터 결과가 나옴

### MACSum.v
- iEnDelay == 1 인 경우 네개의 MAC output으로부터 받은 신호를 모두 더해 rFinalSumDelay에 저장.
- iEnSample600k 신호에 맞춰 rFinalSum 출력

### DelayChain.v
- input 신호 iFirIn이 들어오면 매 iEnSample600k 신호마다 필터 탭 이동

+탭의 위치에 따라서 올바른 MAC 모듈에 신호를 보내야 하는데 어떻게 보내야할까요
+iEnDelay신호의 용도는????? 이제보니까 필요없어보임 iEnDelay가 1일때만 값이 옮겨지는 그런건가

### FSM.v
- input 신호에 따라 state를 정의하고 state에 따라 출력 신호 생성
- State 전이 diagram
```c
parameter   p_Idle = 2'b00,
            p_Update = 2'b01,
            p_MemRd = 2'b10,
            p_Out = 2'b11;
/* State Params = {iCoeffUpdateFlag: U, wLastRd: L
                    wMemRdFlag: M}

                Next cycle
else <=> p_Idle<----------------p_Out
            | ^ \                 ^
        U=1 | |  -------------\   | L=1
            Y |U=0       M=1   Y  |
else <=> p_Update------------>p_MemRd <=> else
                         M=1
*/
```
- [5:0] iAddrRam 신호는 분할하여 [1:0] oModuleSel, [3:0] oAddrRam으로 출력
- State 별 동작:
    - Update state: oCsnRam = 1'b0, oWrnRam = 1'b0 출력
    - MemRd state: *read state가 lastRd 기준으로 빨리끝나버리면 다른 로직이 고장나는 느낌
        oCsnRam = 1'b0, oWrnRam = 1'b0
        oEnMul = 1'b1
        oEnAddAcc = 1'b1
        oEnDelay = 1'b1 출력
    - Out state: oEnAddAcc = 1'b1 출력
        

### ModuleSelector.v
- [1:0] iModuleSel 신호에 따라서 FSM의 출력 신호를 전달할 모듈 선택
- 각 입출력 포트명은 FSM과 SpSram/MAC 모듈 사이 wire명과 동일
- 해당하지 않는 포트는 기본값 전달

---

### 11.24 수정사항
- SpSram10x16
    - 각 메모리의 개수 10으로 수정

- FSM
    - wMemRdFlag 추가: !iCsnRam && iWrnRam 일때1, 해당 신호가 1일때 p_Idle과 p_Updte에서 p_MemRd로 이동.
    - p_Update에서 iCoeffUpdateFlag==0 인 경우 p_MemRd로 이동에서 p_Idle로 변경
    - oAddrRam의 주소를 FSM에서 처리하지 않고 인풋으로 들어온 iAddrRam[3:0]으로 출력하도록 변경. TB에서 적절한 주소 접근
    - WLastRd신호는 iAddrRam[3:0]의 값을 보고 결정. 이게 1일때 무조건 p_Out으로 이동하는게 맞는지는 더 고민해봐야함
 
- DelayChain
    - 대칭 구조를 버리고 0부터 39번째 tap까지 순환하도록 변경
    - output을 [3:0] oDelaySum에서 [29:0] oDelay1~4 로 변경, 3비트의 값 10개를 concat해서 각 MAC 모듈로 전송
    - iEnDelay와 관계없이 Sample 신호만 따르도록 임시조치
 
- ReConf_FirFilter
    - [2:0] wDelay를 [29:0] wDelay1\~4으로 변경. 각 MAC 모듈엔 wDelay1~4 전달(inst_DelayChain output 및 각 MAC 모듈 input 수정)
 
- MAC
    - [2:0] iDelay 에서 [29:0] iDelay로 변경
    - 인덱스별 곱셈 결와와 누적합을 저장하는 reg [15:0] rMul, rAcc [9:0] 추가
    - 곱셈과 누적 연산 인덱스를 지정하는 rDelayIndex[3:0] 추가
    - Saturation check 임시 비활성화

- ReConf_FirFilter_tb
    - iCsnRam, iWrnRam 타이밍 일부 조절

### 11.26 수정사항
- FSM
    - oModuleSel, oAddrRam, oWtDtRam이 clock과 관계없이 wire 처럼 동작하도록 수정

- SpSram10x16
    - Rdbuffer 없이 바로 출력하도록 변경. 그래도 top 파일에서는 2클럭 이후 값을 집어넣어도 첫번째 값이 write가 안된듯 싶다.....

- ReConf_FirFilter_tb
    - 바뀐 모듈에 따라 타이밍 조절

- SpSram10x16_tb 추가, 테스트 시 Sram 정상 동작

### 11.27 수정사항
- FSM
    - iEnMul, iEnAddAcc 신호 추가. memrd state에서만 해당 input을 output으로 전달하도록 변경 => 두 신호를 state에 어느정도 따르면서 직접 제어할 수 있음
    - 그 외에 신호도 직접 input에서 제어할 수 있도록 변경, 다만 state에 따라 제어할 수 있는 신호가 다름
    - idle 에서도 신호를 외부에서 제어할 수 있도록 임시조치

- ReConf_FirFilter
    - input 신호 iEnMul, iEnAddAcc 추가.

- MAC
    - output 신호 output reg 로 변경
    - 타이밍 문제로 Mul 연산과 Acc 연산을 동시에 수행하도록 변경
    - rDelayIndex 0으로 복귀 조건 수정

- SpSram10x16
    - 읽기/쓰기 신호가 없는 경우 16'h0000 출력하도록 변경

- MACSum
    - iEnDelay 신호와 관계없이 매 클럭 네 MAC 모듈의 값을 더하도록 변경

- 모듈별 테스트벤치 추가(김진호)
    - ModuleSelector_tb 추가, 테스트 시 정상 동작

- 11.27 22:30까지 테스트 결과
    - input 001에 대한 결과 정상적으로 출력(일부 알고리즘 과도한 단순화로 개선 필요)
    - input 111의 경우 *7의 결과가 나옴(예상 출력 0xF600 = 0b1111_0110_0000_0000)
    - 해당 지점까지 백업 후 signed number 처리 과정 수정

### 11.27 22:30 이후 수정사항
- MAC
    - reg signed rDelay를 추가하여 DelayChain에서 받은 30비트 수열을 각 3비트의 signed value로 변환
    - 누적 연산시 iDelay[n+2:n] 에서 미리 계산한 rDelay로 변경

- 테스트 결과
    - 100, 111 모두 계수 0x0A00~0x0A09 에 대한 정상적인 출력 확인

- TODO
    - 결과 출력을 보기 위해 임의로 수정했던 알고리즘들 정리 필요
    - 수정하며 추가된 신호들, 사용하지 않는 신호 정리 필요

### 11.28 확인된 문제
- SRAM 2개 사용시 이전 MAC에서 누적합 결과가 다음 SRAM에서의 연산 결과에 영향을 줌 (0x0a09 + 0x0b00 = 0x1509)
    - MACSum에도 [1:0] iModuleSel을 추가하여 사용중인 모듈 구분, top 모듈의 FSM에서 신호를 빼와 MACSum에 전송
    - Input 001, 111에 대해 Sram1: 0x0a00~0x0a09, Sram2: 0x0b00~0x0b09 정상 출력 확인