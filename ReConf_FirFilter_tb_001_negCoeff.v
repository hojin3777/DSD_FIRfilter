`timescale 1ns/10ps

module ReConf_FirFilter_tb;
//For module
reg Clk12M, Rsn, EnSample600k;
reg CoeffUpdateFlag, MemRdFlag;
reg [1:0] ModuleSel;
reg [15:0] WtDtRam;
reg [2:0] FirIn;
wire [15:0] FirOut;
//vars
reg [4:0] count_20; //b'1_0100 = d'20 clock for clk div
reg [15:0] coeff_mem [39:0];
integer i, j;

ReConf_FirFilter DUT(
    .iClk12M            (Clk12M),
    .iRsn               (Rsn),
    .iEnSample600k      (EnSample600k),
    .iCoeffUpdateFlag   (CoeffUpdateFlag),
    .iMemRdFlag         (MemRdFlag),
    .iModuleSel         (ModuleSel),
    .iWtDtRam           (WtDtRam),
    .iFirIn             (FirIn),
    .oFirOut            (FirOut)
);

// Clock define
always #41.66666 Clk12M = ~Clk12M;
// Make EnSample600k
always @(posedge Clk12M) begin
    if(count_20 == 5'd19) begin
        EnSample600k <= 1'b1;
        count_20 <= 0;
        $display("%t output oFirOut[15:0] = %b", $time, FirOut[15:0]);
    end else begin
        EnSample600k <= 1'b0;
        count_20 <= count_20 + 1;
    end
end

// Tasks
// Coefficient Update
task coeff_update(input [1:0] selection, input [6:0] coeffStartAddr); begin
    repeat(4) @(posedge Clk12M);
    $display("----------Raise Coeff flag and ram wrt----------");
    CoeffUpdateFlag <= 1'b1;
    repeat(1) @(posedge Clk12M);
    for(i=0; i<10; i=i+1) begin
        repeat(1) begin
            ModuleSel <= selection[1:0];
            WtDtRam <= coeff_mem[i + coeffStartAddr[6:0]];
            @(posedge Clk12M);
        end
    end
    WtDtRam <= 16'h0000;
    CoeffUpdateFlag <= 1'b0;
    repeat(5) @(posedge Clk12M);
    $display("----------Ram update ended----------");
end
endtask

task input_n_read(input [2:0] pulseIn, input [1:0] selection); begin
    FirIn <= pulseIn[2:0];
    $display("----------input %b and ram rd----------", FirIn[2:0]);
    MemRdFlag <= 1'b1;
    repeat(1) @(posedge Clk12M);
    FirIn <= 3'b000;
    for(i=0; i<10; i=i+1) begin
        repeat(1) begin
            ModuleSel <= selection[1:0];
            @(posedge Clk12M);
        end
    end
    MemRdFlag <= 1'b0;
    repeat(9) @(posedge Clk12M);
    $display("----------input and ram rd ended----------");
end
endtask

task read_n_MAC(input [1:0] selection); begin
    $display("----------ram rd----------");
    MemRdFlag <= 1'b1;
    repeat(1) @(posedge Clk12M);
    for(i=0; i<10; i=i+1) begin
        repeat(1) begin
            ModuleSel <= selection[1:0];
            @(posedge Clk12M);
        end
    end
    MemRdFlag <= 1'b0;
    repeat(9) @(posedge Clk12M);
    $display("----------ram rd ended----------");
end
endtask

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
    coeff_mem[10] = 16'heb00; 
    coeff_mem[11] = 16'heb01; 
    coeff_mem[12] = 16'heb02; 
    coeff_mem[13] = 16'heb03; 
    coeff_mem[14] = 16'heb04; 
    coeff_mem[15] = 16'heb05; 
    coeff_mem[16] = 16'heb06; 
    coeff_mem[17] = 16'heb07; 
    coeff_mem[18] = 16'heb08; 
    coeff_mem[19] = 16'heb09;
    coeff_mem[20] = 12'hc00; 
    coeff_mem[21] = 12'hc01; 
    coeff_mem[22] = 12'hc02; 
    coeff_mem[23] = 12'hc03; 
    coeff_mem[24] = 12'hc04; 
    coeff_mem[25] = 12'hc05; 
    coeff_mem[26] = 12'hc06; 
    coeff_mem[27] = 12'hc07; 
    coeff_mem[28] = 12'hc08; 
    coeff_mem[29] = 12'hc09;
    coeff_mem[30] = 12'hd00; 
    coeff_mem[31] = 12'hd01; 
    coeff_mem[32] = 12'hd02; 
    coeff_mem[33] = 12'hd03; 
    coeff_mem[34] = 12'hd04; 
    coeff_mem[35] = 12'hd05; 
    coeff_mem[36] = 12'hd06; 
    coeff_mem[37] = 12'hd07; 
    coeff_mem[38] = 12'hd08; 
    coeff_mem[39] = 12'hd09;
    //Initial signals
    Clk12M <= 1'b0;
    EnSample600k <= 1'b0;
    MemRdFlag <= 1'b0;
    Rsn <= 1'b1;
    count_20 <= 5'd0;
    CoeffUpdateFlag <= 1'b0;
    ModuleSel <= 2'b00;
    WtDtRam <= 16'h0000;
    FirIn <= 3'b000;
    i = 0;
    j = 0;
    //Time format setting
    $timeformat(-9, 2, " ns", 20);

    //Reset sequence
    repeat(2) @(posedge Clk12M);
    Rsn <= 1'b0;
    repeat(1) @(posedge Clk12M);
    $display("----------reset released----------");
    Rsn <= 1'b1;
    repeat(1) @(posedge EnSample600k);

    // SpSram write
    for (j=0; j<4; j=j+1) begin
        coeff_update(2'b00+j, 6'b0+j*10);
    end
    // begin input
    input_n_read(3'b001, 2'b00);
    // read and MAC calculate
    repeat(9) begin
        read_n_MAC(2'b00);
    end
    repeat(10)begin
        read_n_MAC(2'b01);
    end
    repeat(10)begin
        read_n_MAC(2'b10);
    end
    repeat(10)begin
        read_n_MAC(2'b11);
    end
    repeat(4) @(posedge EnSample600k);

    $finish;
end

endmodule