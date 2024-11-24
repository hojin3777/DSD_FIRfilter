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