module FSM(
    input iClk12M, iRsn, iEnSample600k,
    input iCoeffUpdateFlag,
    input iCsnRam, iWrnRam,
    input [5:0] iAddrRam,
    input [15:0] iWtDtRam,
    //input [5:0] iNumOfCoeff, //Not used in this project

    // To SpSram
    output reg oCsnRam, oWrnRam,
    output [3:0] oAddrRam,
    output [1:0] oModuleSel, //[5:4] iAddr
    output [15:0] oWtDtRam,
    // To MAC
    output reg oEnMul,
    output reg oEnAddAcc,
    //EnDelay
    output reg oEnDelay
);

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

reg [1:0] rCurState, rNxtState;
reg [3:0] rAddrRam; // Sequential address counter, Max = 10
wire wMemRdFlag = (!iCsnRam && iWrnRam);

// Last address check with explicit condition
wire wLastRd;
assign wLastRd = (iAddrRam[3:0] == 4'd9) ? 1'b1 : 1'b0;

// State register
always @(posedge iClk12M) begin
    if(!iRsn)
        rCurState <= p_Idle;
    else
        rCurState <= rNxtState;
end

// Next state logic
always @(*) begin
    case(rCurState)
        p_Idle: begin
            if(iCoeffUpdateFlag)
                rNxtState = p_Update;
            else if(wMemRdFlag)
                rNxtState = p_MemRd;
            else
                rNxtState = p_Idle;
        end
        p_Update: begin
            if(!iCoeffUpdateFlag)
                rNxtState = p_Idle;
            else if(wMemRdFlag)
                rNxtState = p_MemRd;
            else
                rNxtState = p_Update;
        end
        p_MemRd: begin
            if(wLastRd)
                rNxtState = p_Out;
            else
                rNxtState = p_MemRd;
        end
        p_Out: begin
            rNxtState = p_Idle;
        end
        default: rNxtState = p_Idle;
    endcase
end
/* // iAddrRam의 값은 tb에서 처리.
// Address controler
always @(posedge iClk12M) begin
    if(!iRsn) begin
        rAddrRam <= 4'b0000; // Max addr = 9
    end
    else begin
        // Initial condition
        if(rCurState == p_Out || rCurState == p_Idle) begin
            rAddrRam <= 4'd0;
        end
        // Update & Memory read condition
        else if(rCurState == p_Update || rCurState == p_MemRd) begin
            if(!wLastRd)
                rAddrRam <= rAddrRam + 4'd1;
        end
    end
end
*/
// Control signals
always @(*) begin
    // Default
    oCsnRam = 1'b1;
    oWrnRam = 1'b1;
    oEnMul = 1'b0;
    oEnAddAcc = 1'b0;
    oEnDelay = 1'b0;
    case(rCurState)
        p_Update: begin
            oCsnRam = 1'b0;
            oWrnRam = 1'b0;
        end
        p_MemRd: begin
            oCsnRam = 1'b0;
            oWrnRam = 1'b1;
            oEnMul = 1'b1;
            oEnAddAcc = 1'b1;
            oEnDelay = 1'b1;
        end
        p_Out: begin
            oEnAddAcc = 1'b1;
        end
    endcase
end

// Module selection and data input
assign oModuleSel = iAddrRam[5:4];
assign oAddrRam = iAddrRam[3:0];
assign oWtDtRam = iWtDtRam;

endmodule