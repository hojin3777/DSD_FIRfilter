`timescale 1ns/10ps

module DelayChain_tb;

// Inputs
reg iClk12M;
reg iRsn;
reg iEnSample600k;
reg iEnDelay;
reg [2:0] iFirIn;

// Outputs
wire [29:0] oDelay1, oDelay2, oDelay3, oDelay4;

// DUT Instantiation
DelayChain DUT (
    .iClk12M(iClk12M),
    .iRsn(iRsn),
    .iEnSample600k(iEnSample600k),
    .iEnDelay(iEnDelay),
    .iFirIn(iFirIn),
    .oDelay1(oDelay1),
    .oDelay2(oDelay2),
    .oDelay3(oDelay3),
    .oDelay4(oDelay4)
);

// Clock generation
always #41.66666 iClk12M = ~iClk12M; // 12 MHz clock (41.67 ns period)

// Test sequence
initial begin
    // 1. Initialize signals
    $display("Initializing signals...");
    iClk12M = 0;
    iRsn = 0;
    iEnSample600k = 0;
    iEnDelay = 0;
    iFirIn = 3'b000;

    #100; // Wait 100 ns

    // 2. Reset sequence
    $display("Applying reset...");
    iRsn = 1;
    #50;  // Deassert reset
    iRsn = 0;
    #50;
    iRsn = 1;
    
    // 3. Enable sampling and start input
    $display("Starting delay chain test...");
    iEnSample600k = 1; // Enable sampling
    iFirIn = 3'b101;   // Example input (signed -3)

    repeat(10) begin
        @(posedge iClk12M);
        $display("Input=%b | Delay1=%h | Delay2=%h | Delay3=%h | Delay4=%h",
                 iFirIn, oDelay1, oDelay2, oDelay3, oDelay4);
        iFirIn = iFirIn + 3'b001; // Increment input
    end

    // 4. Disable sampling and hold
    $display("Disabling sampling...");
    iEnSample600k = 0;
    repeat(5) @(posedge iClk12M);

    // 5. Check final state
    $display("Final delay chain states:");
    $display("Delay1=%h", oDelay1);
    $display("Delay2=%h", oDelay2);
    $display("Delay3=%h", oDelay3);
    $display("Delay4=%h", oDelay4);

    // End test
    $finish;
end

// Monitor key signal changes
initial begin
    $monitor("Time=%t | Rsn=%b | EnSample=%b | FirIn=%b | Delay1=%h | Delay2=%h | Delay3=%h | Delay4=%h",
             $time, iRsn, iEnSample600k, iFirIn, oDelay1, oDelay2, oDelay3, oDelay4);
end

endmodule
