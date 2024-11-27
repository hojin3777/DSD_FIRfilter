module DelayChain(
    input iClk12M, iRsn, iEnSample600k, 
    input iEnDelay,
    input signed [2:0] iFirIn,

    output [29:0] oDelay1, oDelay2, oDelay3, oDelay4
);

reg signed [2:0] rDelay [39:0];
integer i;

always @(posedge iClk12M) begin
    if(!iRsn) begin
        for(i=0; i<40; i = i+1)begin
            rDelay[i] <= 3'b000;
        end
    end
    // if(iEnDelay) begin
    //     rDelay[0] <= iFirIn;
    // end
    if(iEnSample600k) begin
        rDelay[0] <= iFirIn; //iEnDelay와 관계없이 Sample 신호만 따르도록 임시조치
        rDelay[1]  <= rDelay[0];
        rDelay[2]  <= rDelay[1];
        rDelay[3]  <= rDelay[2];
        rDelay[4]  <= rDelay[3];
        rDelay[5]  <= rDelay[4];
        rDelay[6]  <= rDelay[5];
        rDelay[7]  <= rDelay[6];
        rDelay[8]  <= rDelay[7];
        rDelay[9]  <= rDelay[8];
        rDelay[10] <= rDelay[9];
        rDelay[11] <= rDelay[10];
        rDelay[12] <= rDelay[11];
        rDelay[13] <= rDelay[12];
        rDelay[14] <= rDelay[13];
        rDelay[15] <= rDelay[14];
        rDelay[16] <= rDelay[15];
        rDelay[17] <= rDelay[16];
        rDelay[18] <= rDelay[17];
        rDelay[19] <= rDelay[18];
        rDelay[20] <= rDelay[19];
        rDelay[21] <= rDelay[20];
        rDelay[22] <= rDelay[21];
        rDelay[23] <= rDelay[22];
        rDelay[24] <= rDelay[23];
        rDelay[25] <= rDelay[24];
        rDelay[26] <= rDelay[25];
        rDelay[27] <= rDelay[26];
        rDelay[28] <= rDelay[27];
        rDelay[29] <= rDelay[28];
        rDelay[30] <= rDelay[29];
        rDelay[31] <= rDelay[30];
        rDelay[32] <= rDelay[31];
        rDelay[33] <= rDelay[32];
        rDelay[34] <= rDelay[33];
        rDelay[35] <= rDelay[34];
        rDelay[36] <= rDelay[35];
        rDelay[37] <= rDelay[36];
        rDelay[38] <= rDelay[37];
        rDelay[39] <= rDelay[38];
    end
end

assign oDelay1 = {rDelay[9], rDelay[8], rDelay[7], rDelay[6], rDelay[5], rDelay[4], rDelay[3], rDelay[2], rDelay[1], rDelay[0]};
assign oDelay2 = {rDelay[19], rDelay[18], rDelay[17], rDelay[16], rDelay[15], rDelay[14], rDelay[13], rDelay[12], rDelay[11], rDelay[10]};
assign oDelay3 = {rDelay[29], rDelay[28], rDelay[27], rDelay[26], rDelay[25], rDelay[24], rDelay[23], rDelay[22], rDelay[21], rDelay[20]};
assign oDelay4 = {rDelay[39], rDelay[38], rDelay[37], rDelay[36], rDelay[35], rDelay[34], rDelay[33], rDelay[32], rDelay[31], rDelay[30]};


endmodule