module MAC(
    input iClk12M, iRsn,
    // Add&ACC enable together @ timing diagram
    input iEnMAC, // Enable at 1, group add & acc
    input signed [29:0] iDelay, // Delay chain input
    input signed [15:0] iCoeff, // Coeff from SpSram output

    output reg signed [15:0] oMac
);

reg signed [15:0] rMul [9:0];
reg [3:0] rDelayIndex; // max 1001;
reg signed [2:0] rDelay [9:0];

always @(*) begin
    // Input to local variable
    rDelay[0] <= iDelay[2:0];
    rDelay[1] <= iDelay[5:3];
    rDelay[2] <= iDelay[8:6];
    rDelay[3] <= iDelay[11:9];
    rDelay[4] <= iDelay[14:12];
    rDelay[5] <= iDelay[17:15];
    rDelay[6] <= iDelay[20:18];
    rDelay[7] <= iDelay[23:21];
    rDelay[8] <= iDelay[26:24];
    rDelay[9] <= iDelay[29:27];
    // Sum result to output
    oMac <= rMul[9];
end

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
        rDelayIndex <= 4'b000;
    end
    if(iEnMAC) begin
        case(rDelayIndex) //Mul and add together bc of timing issue
            4'd0: rMul[0] <= iCoeff * rDelay[0];
            4'd1: rMul[1] <= rMul[0] + iCoeff * rDelay[1];
            4'd2: rMul[2] <= rMul[1] + iCoeff * rDelay[2];
            4'd3: rMul[3] <= rMul[2] + iCoeff * rDelay[3];
            4'd4: rMul[4] <= rMul[3] + iCoeff * rDelay[4];
            4'd5: rMul[5] <= rMul[4] + iCoeff * rDelay[5];
            4'd6: rMul[6] <= rMul[5] + iCoeff * rDelay[6];
            4'd7: rMul[7] <= rMul[6] + iCoeff * rDelay[7];
            4'd8: rMul[8] <= rMul[7] + iCoeff * rDelay[8];
            4'd9: rMul[9] <= rMul[8] + iCoeff * rDelay[9];
        endcase
        if(rDelayIndex == 4'b1001)
            rDelayIndex <= 4'b0000;
        else
            rDelayIndex <= rDelayIndex + 1;
    end
end

endmodule