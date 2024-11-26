`timescale 1ns/10ps

module SpSram_tb;

reg Clk12M, Rsn;
reg CsnRam, WrnRam;
reg [3:0] AddrRam;
reg [15:0] WtDtRam;
wire [15:0] RdDtRam;

// Test data array (coefficients from the PDF)
reg [15:0] test_data [0:9];
reg [15:0] read_data [0:9];
integer i, errors;

// DUT Instantiation
SpSram10x16 DUT (
    .iClk12M(Clk12M),
    .iRsn(Rsn),
    .iCsnRam(CsnRam),
    .iWrnRam(WrnRam),
    .iAddrRam(AddrRam),
    .iWtDtRam(WtDtRam),
    .oRdDtRam(RdDtRam)
);

// Clock Generation
always #41.66666 Clk12M = ~Clk12M;

// Test Sequence
initial begin
    // Initialize test data (coefficients from PDF)
    test_data[0] = 12'ha01;
    test_data[1] = 12'ha02;
    test_data[2] = 12'ha03;
    test_data[3] = 12'ha04;
    test_data[4] = 12'ha05;
    test_data[5] = 12'ha06;
    test_data[6] = 12'ha07;
    test_data[7] = 12'ha08;
    test_data[8] = 12'ha09;
    test_data[9] = 12'ha0a;

    // Initialize
    Clk12M = 0;
    Rsn = 1;
    CsnRam = 1;
    WrnRam = 1;
    AddrRam = 4'h0;
    WtDtRam = 16'h0000;
    errors = 0;
    
    // Reset
    #100;
    Rsn = 0;
    #100;
    Rsn = 1;
    #100;
    
    // Write Test Sequence
    $display("\nStarting Write Test Sequence");
    repeat(1) @(posedge Clk12M);
    
    // Write all test data
    CsnRam = 0;
    WrnRam = 0;
    for(i = 0; i < 10; i = i + 1) begin
        @(posedge Clk12M);
        AddrRam = i[3:0];
        WtDtRam = test_data[i];
        $display("Writing to addr %0d: %h", i, test_data[i]);
    end
    
    // Disable write and reset address to 0
    repeat(2) @(posedge Clk12M);
    CsnRam = 1;
    WrnRam = 1;
    AddrRam = 4'h0;  // Reset address to 0
    
    #100;
    
    // Read Test Sequence
    $display("\nStarting Read Test Sequence");
    
    // Read all data with single clock timing
    CsnRam = 0;
    WrnRam = 1;
    
    for(i = 0; i < 10; i = i + 1) begin
        AddrRam = i[3:0];
        read_data[i] = RdDtRam;
        @(posedge Clk12M);
    end
    
    // Disable read
    @(posedge Clk12M);
    CsnRam = 1;
    WrnRam = 1;
    AddrRam = 4'h0;  // Reset address to 0
    
    #100;
    $finish;
end

// Monitor key signal changes
initial begin
    $monitor("Time=%t Rsn=%b CsnRam=%b WrnRam=%b AddrRam=%h WtDtRam=%h RdDtRam=%h",
             $time, Rsn, CsnRam, WrnRam, AddrRam, WtDtRam, RdDtRam);
end

endmodule