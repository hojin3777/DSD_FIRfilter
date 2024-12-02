module SpSram10x16(
    input iClk12M, iRsn,
    input iCsnRam, //Chip select(read, enable at 0)
    input iWrnRam, //Write enable
    input [3:0] iAddrRam, //Write Addr.
    input [15:0] iWtDtRam, //Write Data
    
    output reg [15:0] oRdDtRam //Read Data
);

reg [15:0] rRam [9:0];

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
        oRdDtRam <= 16'h0000;
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
            default: ;//Error?
        endcase
    end 
    else if (!iCsnRam && iWrnRam) begin
        // Data out referr to SRAM interface & timing
        case (iAddrRam)
            4'h0: oRdDtRam <= rRam[0];
            4'h1: oRdDtRam <= rRam[1];
            4'h2: oRdDtRam <= rRam[2];
            4'h3: oRdDtRam <= rRam[3];
            4'h4: oRdDtRam <= rRam[4];
            4'h5: oRdDtRam <= rRam[5];
            4'h6: oRdDtRam <= rRam[6];
            4'h7: oRdDtRam <= rRam[7];
            4'h8: oRdDtRam <= rRam[8];
            4'h9: oRdDtRam <= rRam[9];
            default: oRdDtRam <= 16'h0000;//Error?
        endcase
    end
    else
        oRdDtRam <= 16'h0000;
end

endmodule