module FSM(
    input iClk12M, iRsn, iEnSample600k,
    input iCoeffUpdateFlag,
    input iMemRdFlag,
    input iCsnRam, iWrnRam, iEnMAC,
    input [1:0] iModuleSel,
    input [15:0] iWtDtRam,

    // To SpSram
    output reg oCsnRam, oWrnRam,
    output [3:0] oAddrRam,
    output [1:0] oModuleSel,
    output [15:0] oWtDtRam,
    // To MAC
    output reg oEnMAC
);

parameter   p_Idle = 2'b00,
            p_Update = 2'b01,
            p_MemRd = 2'b10,
            p_MAC = 2'b11;
/* State Params = {iCoeffUpdateFlag: U, iMemRdFlag: R}

                        R=0
else <=> p_Idle<----------------p_MAC <=> else
            | ^ \                 ^
        U=1 | |  -------------\   | Next cycle
            Y |U=0      R=1    Y  |
else <=> p_Update             p_MemRd <=> else
                         
*/

reg [1:0] rCurState, rNxtState;
reg [3:0] rAddrRam; // Sequential address counter, Max = 10
reg rLastRead; // Last address check

// 1. State register
always @(posedge iClk12M) begin
    if(!iRsn)
        rCurState <= p_Idle;
    else
        rCurState <= rNxtState;
end

// 2. Next state logic
always @(*) begin
    case(rCurState)
        p_Idle: begin
            if(iCoeffUpdateFlag)
                rNxtState <= p_Update;
            else if(iMemRdFlag)
                rNxtState <= p_MemRd;
            else
                rNxtState <= p_Idle;
        end
        p_Update: begin
            if(!iCoeffUpdateFlag)
                rNxtState <= p_Idle;
            else
                rNxtState <= p_Update;
        end
        p_MemRd: begin
            rNxtState <= p_MAC;
        end
        p_MAC: begin
            if(!iMemRdFlag)
                rNxtState <= p_Idle;
            else
                rNxtState <= p_MAC;
        end
        default: rNxtState <= p_Idle;
    endcase
end

// 3. Control signals
always @(*) begin
    case(rCurState)
        p_Idle: begin
            oCsnRam <= 1'b1;
            oWrnRam <= 1'b1;
            oEnMAC <= 1'b0;
        end
        p_Update: begin
            oCsnRam <= 1'b0;
            oWrnRam <= 1'b0;
            oEnMAC <= 1'b0;
        end
        p_MemRd: begin
            oCsnRam <= 1'b0;
            oWrnRam <= 1'b1;
            oEnMAC <= 1'b0;
        end
        p_MAC: begin
            oCsnRam <= 1'b0;
            oWrnRam <= 1'b1;
            oEnMAC <= 1'b1;
        end
        default: begin
            oCsnRam <= 1'b1;
            oWrnRam <= 1'b1;
            oEnMAC <= 1'b0;
        end
    endcase
end

// Address controler
always @(posedge iClk12M) begin
    if(!iRsn) begin
        rAddrRam <= 4'b0000;
        rLastRead <= 1'b0;
    end
    // reset on idle
    if(rCurState == p_Idle) begin
        rAddrRam <= 4'b0000;
        rLastRead <= 1'b0;
    end
    // Update & Memory read condition
    else if(rCurState == p_Update || rCurState == p_MemRd || rCurState == p_MAC) begin
        if(!rLastRead)
            rAddrRam <= rAddrRam + 1'b1;
        if(rAddrRam == 4'b1010)
            rLastRead <= 1'b1;
    end
end

// Module selection and data input
assign oModuleSel = iModuleSel;
assign oAddrRam = rAddrRam[3:0];
assign oWtDtRam = iWtDtRam;

endmodule