module ModuleSelector(
    input [1:0] iModuleSel,
    // Sig to SpSram
    input iCsnRam, iWrnRam,
    input [3:0] iAddrRam,
    input [15:0] iWtDtRam,
    // Sig to MAC
    input iEnMAC,

    // Sig to SpSram
    output oCsnRam1, oCsnRam2, oCsnRam3, oCsnRam4,
    output oWrnRam1, oWrnRam2, oWrnRam3, oWrnRam4, 
    output [3:0] oAddrRam1, oAddrRam2, oAddrRam3, oAddrRam4,
    output [15:0] oWtDtRam1, oWtDtRam2, oWtDtRam3, oWtDtRam4,
    // Sig to MAC
    output oEnMAC1, oEnMAC2, oEnMAC3, oEnMAC4
);

assign oCsnRam1 = (iModuleSel == 2'b00) ? iCsnRam : 1'b1;
assign oCsnRam2 = (iModuleSel == 2'b01) ? iCsnRam : 1'b1;
assign oCsnRam3 = (iModuleSel == 2'b10) ? iCsnRam : 1'b1;
assign oCsnRam4 = (iModuleSel == 2'b11) ? iCsnRam : 1'b1;

assign oWrnRam1 = (iModuleSel == 2'b00) ? iWrnRam : 1'b1;
assign oWrnRam2 = (iModuleSel == 2'b01) ? iWrnRam : 1'b1;
assign oWrnRam3 = (iModuleSel == 2'b10) ? iWrnRam : 1'b1;
assign oWrnRam4 = (iModuleSel == 2'b11) ? iWrnRam : 1'b1;

assign oAddrRam1 = (iModuleSel == 2'b00) ? iAddrRam : 4'b0000;
assign oAddrRam2 = (iModuleSel == 2'b01) ? iAddrRam : 4'b0000;
assign oAddrRam3 = (iModuleSel == 2'b10) ? iAddrRam : 4'b0000;
assign oAddrRam4 = (iModuleSel == 2'b11) ? iAddrRam : 4'b0000;

assign oWtDtRam1 = (iModuleSel == 2'b00) ? iWtDtRam : 16'h0000;
assign oWtDtRam2 = (iModuleSel == 2'b01) ? iWtDtRam : 16'h0000;
assign oWtDtRam3 = (iModuleSel == 2'b10) ? iWtDtRam : 16'h0000;
assign oWtDtRam4 = (iModuleSel == 2'b11) ? iWtDtRam : 16'h0000;

assign oEnMAC1 = (iModuleSel == 2'b00) ? iEnMAC : 1'b0;
assign oEnMAC2 = (iModuleSel == 2'b01) ? iEnMAC : 1'b0;
assign oEnMAC3 = (iModuleSel == 2'b10) ? iEnMAC : 1'b0;
assign oEnMAC4 = (iModuleSel == 2'b11) ? iEnMAC : 1'b0;

endmodule