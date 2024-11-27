`timescale 1ns/10ps

module MACSum_tb;

// Inputs
reg iRsn;
reg iClk12M;
reg iEnSample600k;
reg iEnDelay;
reg signed [15:0] iMac1, iMac2, iMac3, iMac4;

// Output
wire [15:0] oFirOut;

// DUT Instantiation
MACSum DUT (
    .iRsn(iRsn),
    .iClk12M(iClk12M),
    .iEnSample600k(iEnSample600k),
    .iEnDelay(iEnDelay),
    .iMac1(iMac1),
    .iMac2(iMac2),
    .iMac3(iMac3),
    .iMac4(iMac4),
    .oFirOut(oFirOut)
);

// Clock generation
always #41.66666 iClk12M = ~iClk12M; // 12 MHz clock (41.67 ns period)

// Test sequence
initial begin
    // 1. Initialize signals
    $display("Initializing signals...");
    iRsn = 0;
    iClk12M = 0;
    iEnSample600k = 0;
    iEnDelay = 0;
    iMac1 = 16'sh0000;
    iMac2 = 16'sh0000;
    iMac3 = 16'sh0000;
    iMac4 = 16'sh0000;

    #100; // Wait 100 ns

    // 2. Reset sequence
    $display("Applying reset...");
    iRsn = 1;
    #50;  // Deassert reset
    iRsn = 0;
    #50;
    iRsn = 1;

    // 3. Apply inputs with delay enable
    $display("Testing delay-enabled accumulation...");
    iEnDelay = 1; // Enable delay
    iEnSample600k = 0;

    iMac1 = 16'sh0010;
    iMac2 = 16'sh0020;
    iMac3 = 16'sh0030;
    iMac4 = 16'sh0040;

    repeat(5) begin
        @(posedge iClk12M);
        $display("MAC Inputs: iMac1=%d, iMac2=%d, iMac3=%d, iMac4=%d | Delay Sum=%d",
                 iMac1, iMac2, iMac3, iMac4, DUT.rFinalSumDelay);
        iMac1 = iMac1 + 16'sh0010; // Increment inputs
        iMac2 = iMac2 + 16'sh0010;
        iMac3 = iMac3 + 16'sh0010;
        iMac4 = iMac4 + 16'sh0010;
    end

    // 4. Enable sampling and check final sum
    $display("Testing sampling accumulation...");
    iEnSample600k = 1; // Enable sampling
    repeat(5) @(posedge iClk12M);

    // 5. Disable delay and sample, and check output stability
    $display("Disabling delay and sampling...");
    iEnDelay = 0;
    iEnSample600k = 0;
    repeat(5) @(posedge iClk12M);

    // Final output state
    $display("Final oFirOut=%d", oFirOut);

    // End simulation
    $finish;
end

// Monitor key signal changes
initial begin
    $monitor("Time=%t | iRsn=%b | iEnSample=%b | iEnDelay=%b | oFirOut=%d",
             $time, iRsn, iEnSample600k, iEnDelay, oFirOut);
end

endmodule
