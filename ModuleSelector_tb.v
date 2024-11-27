`timescale 1ns/10ps

module ModuleSelector_tb;

// Inputs
reg [1:0] iModuleSel;
reg iCsnRam, iWrnRam;
reg [3:0] iAddrRam;
reg [15:0] iWtDtRam;
reg iEnMul, iEnAddAcc;

// Outputs
wire oCsnRam1, oCsnRam2, oCsnRam3, oCsnRam4;
wire oWrnRam1, oWrnRam2, oWrnRam3, oWrnRam4;
wire [3:0] oAddrRam1, oAddrRam2, oAddrRam3, oAddrRam4;
wire [15:0] oWtDtRam1, oWtDtRam2, oWtDtRam3, oWtDtRam4;
wire oEnMul1, oEnMul2, oEnMul3, oEnMul4;
wire oEnAddAcc1, oEnAddAcc2, oEnAddAcc3, oEnAddAcc4;

// DUT Instantiation
ModuleSelector DUT (
    .iModuleSel(iModuleSel),
    .iCsnRam(iCsnRam),
    .iWrnRam(iWrnRam),
    .iAddrRam(iAddrRam),
    .iWtDtRam(iWtDtRam),
    .iEnMul(iEnMul),
    .iEnAddAcc(iEnAddAcc),
    .oCsnRam1(oCsnRam1), .oCsnRam2(oCsnRam2), .oCsnRam3(oCsnRam3), .oCsnRam4(oCsnRam4),
    .oWrnRam1(oWrnRam1), .oWrnRam2(oWrnRam2), .oWrnRam3(oWrnRam3), .oWrnRam4(oWrnRam4),
    .oAddrRam1(oAddrRam1), .oAddrRam2(oAddrRam2), .oAddrRam3(oAddrRam3), .oAddrRam4(oAddrRam4),
    .oWtDtRam1(oWtDtRam1), .oWtDtRam2(oWtDtRam2), .oWtDtRam3(oWtDtRam3), .oWtDtRam4(oWtDtRam4),
    .oEnMul1(oEnMul1), .oEnMul2(oEnMul2), .oEnMul3(oEnMul3), .oEnMul4(oEnMul4),
    .oEnAddAcc1(oEnAddAcc1), .oEnAddAcc2(oEnAddAcc2), .oEnAddAcc3(oEnAddAcc3), .oEnAddAcc4(oEnAddAcc4)
);

// Test variables
integer i;

// Test Sequence
initial begin
    // Initialize Inputs
    iModuleSel = 2'b00;
    iCsnRam = 1;
    iWrnRam = 1;
    iAddrRam = 4'h0;
    iWtDtRam = 16'h0000;
    iEnMul = 0;
    iEnAddAcc = 0;
    
    // Display Start
    $display("\nStarting ModuleSelector Testbench");

    // Test for each module selection
    for (i = 0; i < 4; i = i + 1) begin
        iModuleSel = i[1:0];
        #10;  // Wait for signals to propagate
        
        // Activate signals for the selected module
        iCsnRam = 0;  // Enable chip select
        iWrnRam = (i % 2 == 0) ? 0 : 1;  // Alternate write and read enable
        iAddrRam = 4'hA + i;  // Example address
        iWtDtRam = 16'hFACE + i;  // Example data
        iEnMul = 1;
        iEnAddAcc = 1;
        
        #10;  // Wait for propagation
        // Check outputs
        $display("ModuleSel=%b, Addr=%h, Data=%h", iModuleSel, iAddrRam, iWtDtRam);
        $display("Outputs: oCsnRam%d=%b, oWrnRam%d=%b, oAddrRam%d=%h, oWtDtRam%d=%h",
                 i + 1, (iModuleSel == i) ? 0 : 1, 
                 i + 1, (iModuleSel == i) ? iWrnRam : 1, 
                 i + 1, (iModuleSel == i) ? iAddrRam : 4'h0, 
                 i + 1, (iModuleSel == i) ? iWtDtRam : 16'h0000);
                 
        // Deactivate signals
        iCsnRam = 1;
        iWrnRam = 1;
        iEnMul = 0;
        iEnAddAcc = 0;
        #10;
    end
    
    // Finish simulation
    $display("\nTestbench Complete");
    $finish;
end

// Monitor key signal changes
initial begin
    $monitor("Time=%t iModuleSel=%b iCsnRam=%b iWrnRam=%b iAddrRam=%h iWtDtRam=%h",
             $time, iModuleSel, iCsnRam, iWrnRam, iAddrRam, iWtDtRam);
end

endmodule
