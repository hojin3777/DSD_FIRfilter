module MACSum(
    input iRsn, iClk12M, iEnSample600k,
    input iEnDelay,
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
        rFinalSumDelay <= iMac1 + iMac2 + iMac3 + iMac4;
    end
    if(iEnSample600k) begin
        rFinalSum <= rFinalSumDelay;
    end

    /*
    else begin
        if(iEnDelay)begin
            rFinalSumDelay <= iMac1 + iMac2 + iMac3 + iMac4;
        end
        if(iEnSample600k)begin
            rFinalSum <= rFinalSumDelay;
        end
    end
    */
end

assign oFirOut = rFinalSum;

endmodule