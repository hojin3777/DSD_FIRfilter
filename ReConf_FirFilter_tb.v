`timescale 1ns/10ps

module ReConf_FirFilter_tb;
//For module
reg Clk12M, Rsn, EnSample600k;
reg CoeffUpdateFlag;
reg CsnRam, WrnRam;
reg EnMul, EnAddAcc;
reg [5:0] AddrRam;
reg [15:0] WtDtRam;
reg [2:0] FirIn;
wire [15:0] FirOut;
//vars
reg [4:0] count_20; //b'1_0100 = d'20 clock for clk div
reg [15:0] coeff_mem [19:0];
integer i;

ReConf_FirFilter DUT(
    .iClk12M            (Clk12M),
    .iRsn               (Rsn),
    .iEnSample600k      (EnSample600k),
    .iCoeffUpdateFlag   (CoeffUpdateFlag),
    .iCsnRam            (CsnRam),
    .iWrnRam            (WrnRam),
    .iEnMul             (EnMul),
    .iEnAddAcc          (EnAddAcc),
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
    coeff_mem[0] = 12'ha00; 
    coeff_mem[1] = 12'ha01; 
    coeff_mem[2] = 12'ha02; 
    coeff_mem[3] = 12'ha03; 
    coeff_mem[4] = 12'ha04; 
    coeff_mem[5] = 12'ha05; 
    coeff_mem[6] = 12'ha06; 
    coeff_mem[7] = 12'ha07; 
    coeff_mem[8] = 12'ha08; 
    coeff_mem[9] = 12'ha09;
    coeff_mem[10] = 12'hb00; 
    coeff_mem[11] = 12'hb01; 
    coeff_mem[12] = 12'hb02; 
    coeff_mem[13] = 12'hb03; 
    coeff_mem[14] = 12'hb04; 
    coeff_mem[15] = 12'hb05; 
    coeff_mem[16] = 12'hb06; 
    coeff_mem[17] = 12'hb07; 
    coeff_mem[18] = 12'hb08; 
    coeff_mem[19] = 12'hb09;
    //Initial signals
    Clk12M <= 1'b0;
    EnSample600k <= 1'b0;
    Rsn <= 1'b1;
    count_20 <= 5'd0;
    CoeffUpdateFlag <= 1'b0;
    CsnRam <= 1'b1;
    WrnRam <= 1'b1;
    EnMul <= 1'b0;
    EnAddAcc <= 1'b0;
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

    //Coefficient Update Phase1
    repeat(4) @(posedge Clk12M);
    $display("----------Raise Coeff flag and ram wrt----------");
    CoeffUpdateFlag <= 1'b1;
    repeat(1) @(posedge Clk12M);
    CsnRam <= 1'b0;
    WrnRam <= 1'b0;
    for(i=0; i<10; i=i+1) begin
        repeat(1) begin
            AddrRam <= i[3:0];
            WtDtRam <= coeff_mem[i];
            @(posedge Clk12M);
        end
    end
    CsnRam <= 1'b1;
    WrnRam <= 1'b1;
    AddrRam <= 6'b00_0000;
    WtDtRam <= 16'h0000;
    repeat(2) @(posedge Clk12M);
    CoeffUpdateFlag <= 1'b0;
    repeat(3) @(posedge Clk12M);
    $display("----------Ram update ended----------");
    
    //Coefficient Update Phase2
    repeat(4) @(posedge Clk12M);
    $display("----------Raise Coeff flag and ram wrt----------");
    CoeffUpdateFlag <= 1'b1;
    repeat(1) @(posedge Clk12M);
    CsnRam <= 1'b0;
    WrnRam <= 1'b0;
    for(i=0; i<10; i=i+1) begin
        repeat(1) begin
            AddrRam <= {2'b01,i[3:0]};
            WtDtRam <= coeff_mem[i+10];
            @(posedge Clk12M);
        end
    end
    CsnRam <= 1'b1;
    WrnRam <= 1'b1;
    AddrRam <= 6'b00_0000;
    WtDtRam <= 16'h0000;
    repeat(2) @(posedge Clk12M);
    CoeffUpdateFlag <= 1'b0;
    repeat(3) @(posedge Clk12M);
    $display("----------Ram update ended----------");


    //Firfilter operation phase1
    $display("----------input 001 and ram rd----------");
    FirIn <= 3'b111;
    repeat(1) @(posedge Clk12M);
    CsnRam <= 1'b0;
    WrnRam <= 1'b1;
    FirIn <= 3'b000;
    for(i=0; i<10; i=i+1) begin
        repeat(1) begin
            AddrRam <= i[3:0];
            @(posedge Clk12M);
        end
        if(i==0)
            EnMul <= 1'b1;
        if(i==1)
            EnAddAcc <= 1'b1;
    end
    AddrRam <= 6'b00_0000;
    CsnRam <= 1'b1;
    WrnRam <= 1'b1;
    repeat(1) @(posedge Clk12M);
    EnMul <= 1'b0;
    repeat(1) @(posedge Clk12M);
    EnAddAcc <= 1'b0;
    repeat(7) @(posedge Clk12M);
    $display("----------input and ram rd ended----------");

    //Firfilter operation phase2
    $display("----------input 001 and ram rd----------");
    FirIn <= 3'b111;
    repeat(1) @(posedge Clk12M);
    CsnRam <= 1'b0;
    WrnRam <= 1'b1;
    FirIn <= 3'b000;
    for(i=0; i<10; i=i+1) begin
        repeat(1) begin
            AddrRam <= {2'b01,i[3:0]};
            @(posedge Clk12M);
        end
        if(i==0)
            EnMul <= 1'b1;
        if(i==1)
            EnAddAcc <= 1'b1;
    end
    AddrRam <= 6'b00_0000;
    CsnRam <= 1'b1;
    WrnRam <= 1'b1;
    repeat(1) @(posedge Clk12M);
    EnMul <= 1'b0;
    repeat(1) @(posedge Clk12M);
    EnAddAcc <= 1'b0;
    repeat(7) @(posedge Clk12M);
    $display("----------input and ram rd ended----------");


    repeat(9) begin
    //Firfilter operation phase w/o FirIn
    $display("----------ram rd----------");
    repeat(1) @(posedge Clk12M);
    CsnRam <= 1'b0;
    WrnRam <= 1'b1;
    for(i=0; i<10; i=i+1) begin
        repeat(1) begin
            AddrRam <= i[3:0];
            @(posedge Clk12M);
        end
        if(i==0)
            EnMul <= 1'b1;
        if(i==1)
            EnAddAcc <= 1'b1;
    end
    AddrRam <= 6'b00_0000;
    CsnRam <= 1'b1;
    WrnRam <= 1'b1;
    repeat(1) @(posedge Clk12M);
    EnMul <= 1'b0;
    repeat(1) @(posedge Clk12M);
    EnAddAcc <= 1'b0;
    repeat(7) @(posedge Clk12M);
    $display("----------ram rd ended----------");
    end

    repeat(10) begin
    //Firfilter operation phase w/o FirIn
    $display("----------ram rd----------");
    repeat(1) @(posedge Clk12M);
    CsnRam <= 1'b0;
    WrnRam <= 1'b1;
    for(i=0; i<10; i=i+1) begin
        repeat(1) begin
            AddrRam <= {2'b01,i[3:0]};
            @(posedge Clk12M);
        end
        if(i==0)
            EnMul <= 1'b1;
        if(i==1)
            EnAddAcc <= 1'b1;
    end
    AddrRam <= 6'b01_0000;
    CsnRam <= 1'b1;
    WrnRam <= 1'b1;
    repeat(1) @(posedge Clk12M);
    EnMul <= 1'b0;
    repeat(1) @(posedge Clk12M);
    EnAddAcc <= 1'b0;
    repeat(7) @(posedge Clk12M);
    $display("----------ram rd ended----------");
    end


    repeat(4) @(posedge EnSample600k);

    $finish;
end

endmodule
