module MACSum(
    input iRsn, iClk12M, iEnSample600k,
    input [1:0] iModuleSel,
    input signed [15:0] iMac1, iMac2, iMac3, iMac4,

    output [15:0] oFirOut
);

reg signed [15:0] rFinalSumDelay, rFinalSum;

always @(posedge iClk12M) begin
    if(!iRsn) begin
        rFinalSum <= 16'h0000;
        rFinalSumDelay <= 16'h0000;
    end
    else begin
        case(iModuleSel)
            2'b00: rFinalSumDelay <= iMac1;
            2'b01: rFinalSumDelay <= iMac2;
            2'b10: rFinalSumDelay <= iMac3;
            2'b11: rFinalSumDelay <= iMac4;
        endcase
        // rFinalSumDelay <= iMac1 + iMac2 + iMac3 + iMac4; //누적합 이슈로 변경
    end
    if(iEnSample600k) begin
        rFinalSum <= rFinalSumDelay;
    end
end

assign oFirOut = rFinalSum;

endmodule