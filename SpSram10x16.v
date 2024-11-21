module SpSram10x16(
    input iClk12M, iRsn,
    input iCsnRam, //Chip select(read, enable at 0)
    input iWrnRam, //Write enable
    input [3:0] iAddrRam, //Write Addr.
    input [15:0] iWtDtRam, //Write Data
    
    output [15:0] oRdDtRam //Read Data
);

reg [15:0] rRam [10:0];
reg [15:0] rRdbuffer;

always @(posedge iClk12M) begin
    if(!iRsn) begin
        rRam[0] <= 16'h0000;
        rRam[1] <= 16'h0000;
        rRam[2] <= 16'h0000;
        rRam[3] <= 16'h0000;
        rRam[4] <= 16'h0000;
        rRam[5] <= 16'h0000;
        rRam[6] <= 16'h0000;
        rRam[7] <= 16'h0000;
        rRam[8] <= 16'h0000;
        rRam[9] <= 16'h0000;
        rRam[10] <= 16'h0000;
        rRdbuffer <= 16'h0000;
    end
    if(!iCsnRam && !iWrnRam) begin
        // Data In referr to SRAM interface & timing
        case (iAddrRam)
            4'h0: rRam[0] <= iWtDtRam;
            4'h1: rRam[1] <= iWtDtRam;
            4'h2: rRam[2] <= iWtDtRam;
            4'h3: rRam[3] <= iWtDtRam;
            4'h4: rRam[4] <= iWtDtRam;
            4'h5: rRam[5] <= iWtDtRam;
            4'h6: rRam[6] <= iWtDtRam;
            4'h7: rRam[7] <= iWtDtRam;
            4'h8: rRam[8] <= iWtDtRam;
            4'h9: rRam[9] <= iWtDtRam;
            4'hA: rRam[10] <= iWtDtRam;
            default: ;//Error?
        endcase
    end
    else if (!iCsnRam && iWrnRam) begin
        // Data out referr to SRAM interface & timing
        case (iAddrRam)
            4'h0: rRdbuffer <= rRam[0];
            4'h1: rRdbuffer <= rRam[1];
            4'h2: rRdbuffer <= rRam[2];
            4'h3: rRdbuffer <= rRam[3];
            4'h4: rRdbuffer <= rRam[4];
            4'h5: rRdbuffer <= rRam[5];
            4'h6: rRdbuffer <= rRam[6];
            4'h7: rRdbuffer <= rRam[7];
            4'h8: rRdbuffer <= rRam[8];
            4'h9: rRdbuffer <= rRam[9];
            4'hA: rRdbuffer <= rRam[10];
            default: rRdbuffer <= 16'h0000;//Error?
        endcase
    end
end

assign oRdDtRam = rRdbuffer;

endmodule