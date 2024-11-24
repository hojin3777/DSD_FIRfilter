`timescale 1ns/10ps

module ReConf_FirFilter_tb;
//For module
reg Clk12M, Rsn, EnSample600k;
reg CoeffUpdateFlag;
reg CsnRam, WrnRam;
reg [5:0] AddrRam;
reg [15:0] WtDtRam;
reg [2:0] FirIn;
wire [15:0] FirOut;
//vars
reg [4:0] count_20; //b'1_0100 = d'20 clock for clk div
reg [15:0] coeff_mem [10:0];
integer i;

ReConf_FirFilter DUT(
    .iClk12M            (Clk12M),
    .iRsn               (Rsn),
    .iEnSample600k      (EnSample600k),
    .iCoeffUpdateFlag   (CoeffUpdateFlag),
    .iCsnRam            (CsnRam),
    .iWrnRam            (WrnRam),
    .iAddrRam           (AddrRam),
    .iWtDtRam           (WtDtRam),
    .iFirIn             (FirIn),
    .oFirOut            (FirOut)
);

always #41.66666 Clk12M = ~Clk12M;
always @(posedge Clk12M) begin //클럭 분할
    if(count_20 == 5'd19) begin //600kHz 클럭 생성
        EnSample600k <= 1'b1;
        count_20 <= 0;
        $display("%t output oFirOut[15:0] = %b", $time, FirOut[15:0]);
    end else begin
        EnSample600k <= 1'b0;
        count_20 <= count_20 + 1;
    end
end

initial begin
    //coefficients
    coeff_mem[0] = 9'b0_0000_1100; 
    coeff_mem[1] = 9'b0_0000_0000; 
    coeff_mem[2] = 9'b0_0001_0011; 
    coeff_mem[3] = 9'b0_0001_0111; 
    coeff_mem[4] = 9'b0_0000_0000; 
    coeff_mem[5] = 9'b0_0010_0100; 
    coeff_mem[6] = 9'b0_0011_0000; 
    coeff_mem[7] = 9'b0_0000_0000; 
    coeff_mem[8] = 9'b0_0110_0101; 
    coeff_mem[9] = 9'b0_1100_1101; 
    coeff_mem[10] = 9'b1_1111_0011;
    //Initial signals
    Clk12M <= 1'b0;
    EnSample600k <= 1'b0;
    Rsn <= 1'b1;
    count_20 <= 5'd0;
    CoeffUpdateFlag <= 1'b0;
    CsnRam <= 1'b1;
    WrnRam <= 1'b1;
    AddrRam <= 6'b00_0000;
    WtDtRam <= 16'h0000;
    FirIn <= 3'b000;
    i = 0;
    //Time format setting
    $timeformat(-9, 2, " ns", 20);

    //Reset sequence
    repeat(2) @(posedge Clk12M);
    Rsn <= 1'b0;
    repeat(1) @(posedge Clk12M);
    $display("----------reset released----------");
    Rsn <= 1'b1;
    repeat(1) @(posedge EnSample600k);

    //Coefficient Update Phase
    repeat(3) @(posedge Clk12M);
    $display("----------Raise Coeff flag and ram wrt----------");
    CoeffUpdateFlag <= 1'b1;
    repeat(1) @(posedge Clk12M);
    CsnRam <= 1'b0;
    WrnRam <= 1'b0;
    for(i=0; i<11; i=i+1) begin
        repeat(1) begin
            AddrRam <= i;
            WtDtRam <= coeff_mem[i];
            @(posedge Clk12M);
        end
    end
    AddrRam <= 6'b00_0000;
    CsnRam <= 1'b1;
    WrnRam <= 1'b1;
    WtDtRam <= 16'h0000;
    repeat(2) @(posedge Clk12M);
    CoeffUpdateFlag <= 1'b0;
    $display("----------Ram update ended----------");
    repeat(3) @(posedge Clk12M);
    
    //Firfilter operation phase
    FirIn <= 3'b001;
    $display("----------input 001 and ram rd----------");
    repeat(1) @(posedge Clk12M); //wait for EnSample600k
    FirIn <= 3'b000;
    CsnRam <= 1'b0;
    WrnRam <= 1'b1;
    for(i=0; i<11; i=i+1) begin
        repeat(1) begin
            AddrRam <= i;
            @(posedge Clk12M);
        end
    end
    AddrRam <= 6'b00_0000;
    CsnRam <= 1'b1;
    WrnRam <= 1'b1;
    $display("----------input and ram rd ended----------");
    repeat(4) @(posedge EnSample600k);

    $finish;
end

endmodule