module ReConf_FirFilter(
    input iClk12M, iRsn,
    input iEnSample600k,
    input iCoeffUpdateFlag, iMemRdFlag,
    input iCsnRam, iWrnRam,
    input iEnMAC,
    input [5:0] iAddrRam,
    input [15:0] iWtDtRam,
    input [2:0] iFirIn,

    output [15:0] oFirOut
);

// FSM -> ModuleSelector
wire wCsnRam, wWrnRam;
wire [3:0] wAddrRam;
wire [1:0] wModuleSel;
wire [15:0] wWtDtRam;
wire wEnMAC;

//ModSel -> RAM/MAC
wire wCsnRam1, wCsnRam2, wCsnRam3, wCsnRam4;
wire wWrnRam1, wWrnRam2, wWrnRam3, wWrnRam4;
wire [3:0] wAddrRam1, wAddrRam2, wAddrRam3, wAddrRam4;
wire [15:0] wWtDtRam1, wWtDtRam2, wWtDtRam3, wWtDtRam4;
wire wEnMAC1, wEnMAC2, wEnMAC3, wEnMAC4;

//Ram to MAC
wire [15:0] wRdDtRam1, wRdDtRam2, wRdDtRam3, wRdDtRam4;
//DelayChain to MAC
wire [29:0] wDelay1, wDelay2, wDelay3, wDelay4;

//MAC to MACSum
wire [15:0] wMac1, wMac2, wMac3, wMac4;

FSM inst_FSM(
    .iClk12M            (iClk12M),
    .iRsn               (iRsn),
    .iEnSample600k      (iEnSample600k),
    .iCoeffUpdateFlag   (iCoeffUpdateFlag),
    .iMemRdFlag         (iMemRdFlag),
    .iCsnRam            (iCsnRam),
    .iWrnRam            (iWrnRam),
    .iEnMAC             (iEnMAC),
    .iAddrRam           (iAddrRam),
    .iWtDtRam           (iWtDtRam),
    .oCsnRam            (wCsnRam),
    .oWrnRam            (wWrnRam),
    .oAddrRam           (wAddrRam),
    .oModuleSel         (wModuleSel),
    .oWtDtRam           (wWtDtRam),
    .oEnMAC             (wEnMAC)
);

// ModuleSelector instance
ModuleSelector inst_ModuleSelector(
    .iModuleSel      (wModuleSel),
    .iCsnRam         (wCsnRam),
    .iWrnRam         (wWrnRam),
    .iAddrRam        (wAddrRam),
    .iWtDtRam        (wWtDtRam),
    .iEnMAC          (wEnMAC),
    .oCsnRam1        (wCsnRam1),
    .oCsnRam2        (wCsnRam2),
    .oCsnRam3        (wCsnRam3),
    .oCsnRam4        (wCsnRam4),
    .oWrnRam1        (wWrnRam1),
    .oWrnRam2        (wWrnRam2),
    .oWrnRam3        (wWrnRam3),
    .oWrnRam4        (wWrnRam4),
    .oAddrRam1       (wAddrRam1),
    .oAddrRam2       (wAddrRam2),
    .oAddrRam3       (wAddrRam3),
    .oAddrRam4       (wAddrRam4),
    .oWtDtRam1       (wWtDtRam1),
    .oWtDtRam2       (wWtDtRam2),
    .oWtDtRam3       (wWtDtRam3),
    .oWtDtRam4       (wWtDtRam4),
    .oEnMAC1         (wEnMAC1),
    .oEnMAC2         (wEnMAC2),
    .oEnMAC3         (wEnMAC3),
    .oEnMAC4         (wEnMAC4)
);

// DelayChain instance
DelayChain inst_DelayChain(
    .iClk12M         (iClk12M),
    .iRsn            (iRsn),
    .iEnSample600k   (iEnSample600k),
    .iFirIn          (iFirIn),
    .oDelay1         (wDelay1),
    .oDelay2         (wDelay2),
    .oDelay3         (wDelay3),
    .oDelay4         (wDelay4)
);

// SpSram instances
SpSram10x16 inst_SpSram1(
    .iClk12M         (iClk12M),
    .iRsn            (iRsn),
    .iCsnRam         (wCsnRam1),
    .iWrnRam         (wWrnRam1),
    .iAddrRam        (wAddrRam1),
    .iWtDtRam        (wWtDtRam1),
    .oRdDtRam        (wRdDtRam1)
);
SpSram10x16 inst_SpSram2(
    .iClk12M         (iClk12M),
    .iRsn            (iRsn),
    .iCsnRam         (wCsnRam2),
    .iWrnRam         (wWrnRam2),
    .iAddrRam        (wAddrRam2),
    .iWtDtRam        (wWtDtRam2),
    .oRdDtRam        (wRdDtRam2)
);
SpSram10x16 inst_SpSram3(
    .iClk12M         (iClk12M),
    .iRsn            (iRsn),
    .iCsnRam         (wCsnRam3),
    .iWrnRam         (wWrnRam3),
    .iAddrRam        (wAddrRam3),
    .iWtDtRam        (wWtDtRam3),
    .oRdDtRam        (wRdDtRam3)
);
SpSram10x16 inst_SpSram4(
    .iClk12M         (iClk12M),
    .iRsn            (iRsn),
    .iCsnRam         (wCsnRam4),
    .iWrnRam         (wWrnRam4),
    .iAddrRam        (wAddrRam4),
    .iWtDtRam        (wWtDtRam4),
    .oRdDtRam        (wRdDtRam4)
);

// MAC instances
MAC inst_MAC1(
    .iClk12M         (iClk12M),
    .iRsn            (iRsn),
    .iEnMAC          (wEnMAC1),
    .iDelay          (wDelay1),
    .iCoeff          (wRdDtRam1),
    .oMac            (wMac1)
);
MAC inst_MAC2(
    .iClk12M         (iClk12M),
    .iRsn            (iRsn),
    .iEnMAC          (wEnMAC2),
    .iDelay          (wDelay2),
    .iCoeff          (wRdDtRam2),
    .oMac            (wMac2)
);
MAC inst_MAC3(
    .iClk12M         (iClk12M),
    .iRsn            (iRsn),
    .iEnMAC          (wEnMAC3),
    .iDelay          (wDelay3),
    .iCoeff          (wRdDtRam3),
    .oMac            (wMac3)
);
MAC inst_MAC4(
    .iClk12M         (iClk12M),
    .iRsn            (iRsn),
    .iEnMAC          (wEnMAC4),
    .iDelay          (wDelay4),
    .iCoeff          (wRdDtRam4),
    .oMac            (wMac4)
);

// MACSum instance
MACSum inst_MACSum(
    .iRsn            (iRsn),
    .iClk12M         (iClk12M),
    .iModuleSel      (wModuleSel),
    .iEnSample600k   (iEnSample600k),
    .iMac1           (wMac1),
    .iMac2           (wMac2),
    .iMac3           (wMac3),
    .iMac4           (wMac4),
    .oFirOut         (oFirOut)
);


endmodule