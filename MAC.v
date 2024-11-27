module MAC(
    input iClk12M, iRsn,
    // Add&ACC enable together @ timing diagram
    input iEnMul, iEnAddAcc, // Enable at 1, group add & acc
    input signed [29:0] iDelay, // Delay chain input
    input signed [15:0] iCoeff, // Coeff from SpSram output

    output reg [15:0] oMac
);

reg [15:0] rMul [9:0];
reg [15:0] rAcc [9:0];
reg [3:0] rDelayIndex; // max 1001;
/*
wire signed [15:0] wMulResult;
reg signed [15:0] rAccOut;
reg signed [15:0] rMul;
wire signed [15:0] wAccSum;
wire wSatFlagP, wSatFlagN; //Saturation check flag
wire [15:0] wAccNext; //Next accumulation check

assign wMulResult = iDelay * iCoeff; //Get delay*coeff
// 1 if current (Acc MSB)==0 && (Mul MSB)==0, but (adding result) == 1
assign wAccSum = rAccOut + rMul;
assign wSatFlagP = (!rAccOut[15] && !rMul[15] && wAccSum[15]) ? 1'b1 : 1'b0;
assign wSatFlagN = (rAccOut[15] && rMul[15] && !wAccSum[15]) ? 1'b1 : 1'b0;
assign wAccNext = wSatFlagP ? 16'h7FFF :
                  wSatFlagN ? 16'h8000 :
                  rAccOut + rMul;
*/
always @(posedge iClk12M) begin
    if(!iRsn) begin
        //rAccOut <= 16'h0000;
        rMul[0] <= 16'h0000;
        rMul[1] <= 16'h0000;
        rMul[2] <= 16'h0000;
        rMul[3] <= 16'h0000;
        rMul[4] <= 16'h0000;
        rMul[5] <= 16'h0000;
        rMul[6] <= 16'h0000;
        rMul[7] <= 16'h0000;
        rMul[8] <= 16'h0000;
        rMul[9] <= 16'h0000;
        rAcc[0] <= 16'h0000;
        rAcc[1] <= 16'h0000;
        rAcc[2] <= 16'h0000;
        rAcc[3] <= 16'h0000;
        rAcc[4] <= 16'h0000;
        rAcc[5] <= 16'h0000;
        rAcc[6] <= 16'h0000;
        rAcc[7] <= 16'h0000;
        rAcc[8] <= 16'h0000;
        rAcc[9] <= 16'h0000;
        rDelayIndex <= 4'b000;
    end
    if(iEnMul) begin
        case(rDelayIndex) //타이밍 문제로 곱셈과 누산 연산을 합쳐 테스트
            4'd0: rMul[0] <= iCoeff * iDelay[2:0];
            4'd1: rMul[1] <= rMul[0] + iCoeff * iDelay[5:3];
            4'd2: rMul[2] <= rMul[1] + iCoeff * iDelay[8:6];
            4'd3: rMul[3] <= rMul[2] + iCoeff * iDelay[11:9];
            4'd4: rMul[4] <= rMul[3] + iCoeff * iDelay[14:12];
            4'd5: rMul[5] <= rMul[4] + iCoeff * iDelay[17:15];
            4'd6: rMul[6] <= rMul[5] + iCoeff * iDelay[20:18];
            4'd7: rMul[7] <= rMul[6] + iCoeff * iDelay[23:21];
            4'd8: rMul[8] <= rMul[7] + iCoeff * iDelay[26:24];
            4'd9: rMul[9] <= rMul[8] + iCoeff * iDelay[29:27];
        endcase
        if(rDelayIndex == 4'b1010)
            rDelayIndex <= 4'b0000;
        else
            rDelayIndex <= rDelayIndex + 1;
    end
    /*
    if(iEnMul) begin
        case(rDelayIndex)
            4'd0: rMul[0] <= iCoeff * iDelay[2:0];
            4'd1: rMul[1] <= iCoeff * iDelay[5:3];
            4'd2: rMul[2] <= iCoeff * iDelay[8:6];
            4'd3: rMul[3] <= iCoeff * iDelay[11:9];
            4'd4: rMul[4] <= iCoeff * iDelay[14:12];
            4'd5: rMul[5] <= iCoeff * iDelay[17:15];
            4'd6: rMul[6] <= iCoeff * iDelay[20:18];
            4'd7: rMul[7] <= iCoeff * iDelay[23:21];
            4'd8: rMul[8] <= iCoeff * iDelay[26:24];
            4'd9: rMul[9] <= iCoeff * iDelay[29:27];
        endcase
        if(rDelayIndex == 4'b1010)
            rDelayIndex <= 4'b0000;
        else
            rDelayIndex <= rDelayIndex + 1;
    end
    if(iEnAddAcc) begin
        case(rDelayIndex)
            4'd0: rAcc[0] <= rMul[0] + 16'h0000;
            4'd1: rAcc[1] <= rMul[1] + rAcc[0];
            4'd2: rAcc[2] <= rMul[2] + rAcc[1];
            4'd3: rAcc[3] <= rMul[3] + rAcc[2];
            4'd4: rAcc[4] <= rMul[4] + rAcc[3];
            4'd5: rAcc[5] <= rMul[5] + rAcc[4];
            4'd6: rAcc[6] <= rMul[6] + rAcc[5];
            4'd7: rAcc[7] <= rMul[7] + rAcc[6];
            4'd8: rAcc[8] <= rMul[8] + rAcc[7];
            4'd9: rAcc[9] <= rMul[9] + rAcc[8];
        endcase
    end
    oMac = rAcc[9];*/
end

always @(*) begin
    oMac = rMul[9];
end

endmodule