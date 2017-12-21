`timescale 1ns/1ps
`define mydelay 1

//--------------------------------------------------------------
// mips.v
// Jinheon.Baek@outlook.kr (Korea University)
// Pipelined MIPS processor
//--------------------------------------------------------------

// Pipelined MIPS processor
// ()_name => () indicates each domain in 5-stages
module mips(input         clk, reset,
            input  [31:0] instr,
            input  [31:0] memreaddata,
            output [31:0] pc,
            output        memwrite,
            output [31:0] memaddr,
            output [31:0] memwritedata);
      
  // Instantiate Datapath at Datapath all CPU logic runs.
  datapath dp(
    .clk            (clk),
    .reset          (reset),
    .IF_pc          (pc),
    .IF_Instr_stall (instr),
    .MEM_addr       (memaddr), 
    .MEM_MuxALU_2   (memwritedata),
    .readdata       (memreaddata),
    .MEM_memwrite   (memwrite));

endmodule

module datapath(input         clk, reset,
                input  [31:0] readdata,
                input  [31:0] IF_Instr_stall,
                output [31:0] IF_pc,
                output        MEM_memwrite,
                output [31:0] MEM_addr,
                output [31:0] MEM_MuxALU_2);
                
   // Instruction Fetch
   wire [31:0] IF_Instr, IF_Instr_FlushResult;
   wire [31:0] ID_srca;
   wire [31:0] IF_pcnext, IF_pcnext_jr, IF_pcplus4, IF_pcnextbr, IF_pcselect;

   // Instruction Decoding
   wire [31:0] ID_Instr, ID_pcplus4, writedata;
   wire [31:0] ID_signimm, ID_shiftedimm;
   wire [31:0] srca_Forward, writedata_Forward, result;
   wire        WBID_forwarding_control_1, WBID_forwarding_control_2;
   wire        stall_control, IFID_stall, stall_PC;

   // Execution Stage
   wire [31:0] EX_pcplus4, EX_pcbranch, EX_srca, srcb, writereg, EX_Instr, EX_jump;
   wire [31:0] EX_signimm, EX_shiftedimm, EX_signimmsh, EX_aluout, ReadData_2;
   wire [31:0] MuxALU_1, MuxALU_2;
   wire [4:0]  IDEX_RegRs, IDEX_RegRt, IDEX_RegRt2, IDEX_RegRd;
   wire [2:0]  EX_alucontrol;
   wire [1:0]  forwarding_control_1, forwarding_control_2;
   wire [1:0]  EX_aluop;
   wire        EX_zero;
   wire        EX_regdst, EX_alusrc;
   wire        EX_branch, EX_branchNE, EX_memwrite, EX_memread;
   wire        EX_regwrite, EX_memtoreg;
   wire        EX_jr, EX_jal;

   // Memory Access Stage
   wire [31:0] MEM_pcplus4, MEM_aluout;
   wire [4:0]  EXMEM_RegRd;
   wire        MEM_zero;
   wire        MEM_branch, MEM_branchNE;
   wire        MEM_regwrite, MEM_memtoreg;
   wire        MEM_jr, MEM_jal;
   
   // Write Back Stage
   wire [31:0] WB_pcplus4, WB_readdata, WB_aluout;
   wire [4:0]  MEMWB_RegRd;
   wire        WB_regwrite, WB_memtoreg;
   wire        WB_jr, WB_jal;

   // Global Signals that communicate with Control Unit & Logic in datapath
   wire         signext, shiftl16, memtoreg, memwrite, memread, branch, branchNE, alusrc, regdst, regwrite, jump, jal;
   wire [1:0]   aluop;
   wire         EX_pcsrc, zero;
   wire         EX_flush;
   wire [31:0]  pcmuxresult, srcbmuxresult;
   wire [4:0]   writeregaddr;    
   wire [31:0]  writeregdata;    
  
  // Instantiate Control Unit Module that returns control signals
    maindec md(
    .op       (ID_Instr[31:26]),
    .signext  (signext),
    .shiftl16 (shiftl16),
    .memtoreg (memtoreg),
    .memwrite (memwrite),
    .memread  (memread),
    .branch   (branch),
    .branchNE (branchNE),
    .alusrc   (alusrc),
    .regdst   (regdst),
    .regwrite (regwrite),
    .jump     (jump),
    .jal      (jal),
    .aluop    (aluop));

   aludec ad( 
    .funct      (EX_shiftedimm[5:0]),
    .aluop      (EX_aluop), 
    .jr         (EX_jr),
    .alucontrol (EX_alucontrol));
    
  // *** Instruction Fetech Stage Logic *** //

  // If Hazard detection occurs, stall Instruction Fetch stage to Instruction Decoding stage FlipFlop
  // (Hazard occurs : IFID_stall = 1, stall Instruction FlipFlop)
  mux2 # (32) IF_StallMUX(
   .d0 (IF_Instr_stall),
   .d1 (ID_Instr),
   .s  (IFID_stall),
   .y  (IF_Instr)
  ); 
       
  // If Hazard detection occurs, stall Instruction Fetch stage to Instruction Decoding stage FlipFlop
  // (Hazard occurs : stall_PC = 1, stall pcreg FlipFlop)
  mux2 # (32) PC_StallMUX(
   .d0 (IF_pcnext_jr),
   .d1 (IF_pc),
   .s  (stall_PC),
   .y  (IF_pcselect)
  );

  // If Hazard detection occurs, Flush Instruction Fetch stage to Instruction Decoding stage FlipFlop
  // (Hazard occurs : EX_flush = 1, flush Instruction FlipFlop)
  mux2 # (32) IF_FlushMUX(
   .d0 (IF_Instr),
   .d1 (32'b0),
   .s  (EX_flush),
   .y  (IF_Instr_FlushResult)
  );

  // Next PC logic
  flopr # (32) pcreg(
    .clk   (clk),
    .reset (reset),
    .d     (IF_pcselect),
    .q     (IF_pc));
    
  adder pcadd1(
    .a (IF_pc),
    .b (32'b100),
    .y (IF_pcplus4));
   
  mux2 #(32) pcbrmux(
    .d0  (IF_pcplus4),
    .d1  (EX_pcbranch),
    .s   (EX_pcsrc),
    .y   (IF_pcnextbr));

  mux2 #(32) pcmux(
    .d0   (IF_pcnextbr),
    .d1   ({IF_pcplus4[31:28], EX_Instr[25:0], 2'b00}),
    .s    (EX_jump),
    .y    (IF_pcnext));   

    mux2 #(32) jrmux(
    .d0   (IF_pcnext),
    .d1   (EX_aluout),
    .s    (EX_jr),
    .y    (IF_pcnext_jr));
        
  // *** Instruction Fetch to Instruction Decoding FlipFlop *** //
    
  // Flopr (IF/ID) 
  flopr # (32) First_IFID (
   .clk   (clk),
   .reset (reset),
   .d  (IF_Instr_FlushResult),
   .q  (ID_Instr));   
   
  // Flopr (IF/ID pc+4)
  flopenr #(32) Fisrt_IFID_pc4(
   .clk   (clk),
   .reset (reset),
   .en (IFID_stall),
   .d  (IF_pcplus4),
   .q  (ID_pcplus4)); 
  
  // *** Instruction Decoding Stage Logic *** //

  // WriteBack Stage to Instruction Decoding Stage Forwarding
  ForwardingWBID ForwardingWBID_Control(
    .Rs_ID   (ID_Instr[25:21]),
    .Rt_ID   (ID_Instr[20:16]),
    .WB_writereg    (MEMWB_RegRd),
    .WB_regwrite    (WB_regwrite),
    .s1   (WBID_forwarding_control_1),
    .s2   (WBID_forwarding_control_2));

   // If Write Back Stage to Instruction Decoding Stage Forwarding occurs, Select MEM/WB Register Rd to Srca
  mux2 # (32) ForwardMUX1(
   .d0 (ID_srca),
   .d1 (writeregdata),
   .s  (WBID_forwarding_control_1),
   .y  (srca_Forward));
  
   // If Write Back Stage to Instruction Decoding Stage Forwarding occurs, Select MEM/WB Register Rd to writedata
   mux2 # (32) ForwardMUX2(
   .d0 (writedata),
   .d1 (writeregdata),
   .s  (WBID_forwarding_control_2),
   .y  (writedata_Forward)
  );
  
  // Instantiate Hazard Detection Control Unit
  // If s1, s2 and s2 are 1, 1) stall IF/ID 2) Next PC and Control Unit to 0
  HazardDetection ControlUnit_Hazard(
   .Rs_ID (ID_Instr[25:21]),
   .Rt_ID (ID_Instr[20:16]),
   .Rt_EX (IDEX_RegRt2),
   .EX_memread (EX_memread),
   .pcsrc (EX_pcsrc),
   .jump (EX_jump),
   .jal (EX_jal),
   .jr (EX_jr),
   .s1 (stall_control),
   .s2 (IFID_stall),
   .s3 (stall_PC),
   .s4 (EX_flush));
   
  sl2 immsh(
    .a (EX_signimm),
    .y (EX_signimmsh));
            
  sign_zero_ext sze(
    .a       (ID_Instr[15:0]),
    .signext (signext),
    .y       (ID_signimm[31:0]));

  shift_left_16 sl16(
    .a         (ID_signimm[31:0]),
    .shiftl16  (shiftl16),
    .y         (ID_shiftedimm[31:0]));
    
  // Register file logic
  regfile rf(
    .clk     (clk),
    .we      (WB_regwrite),
    .ra1     (ID_Instr[25:21]),
    .ra2     (ID_Instr[20:16]),
    .wa      (MEMWB_RegRd),
    .wd      (writeregdata),
    .rd1     (ID_srca),
    .rd2     (writedata));
    
  
  // *** Instruction Decoding to Executon Stage FlipFlop *** //
 
  flopenr #(32) IDEX_INSTR(
   .clk   (clk),
   .reset (reset),
   .en (IFID_stall),
   .d  (ID_Instr),
   .q  (EX_Instr)); 
   
  flopenr #(32) Second_IDEX_pc4(
   .clk   (clk),
   .reset (reset),
   .en (IFID_stall),
   .d  (ID_pcplus4),
   .q  (EX_pcplus4)); 
   
  // Flopr (ID/EX ReadData)
  flopenr #(32) Second_IDEX_ReadData1(
   .clk   (clk),
   .reset (reset),
   .en (IFID_stall),
   .d  (srca_Forward),
   .q  (EX_srca)); 
   
  // Flopr (ID/EX ReadData)
  flopenr #(32) Second_IDEX_ReadData2(
   .clk   (clk),
   .reset (reset),
   .en (IFID_stall),
   .d  (writedata_Forward),
   .q  (ReadData_2)); 
   
  // Flopr (ID/EX RegisterRs)
  flopenr #(5) Second_IDEX_RegRs (
   .clk   (clk),
   .reset (reset),
   .en (IFID_stall),
   .d  (ID_Instr[25:21]),
   .q  (IDEX_RegRs));   

  // Flopr (ID/EX RegisterRt)
  flopenr #(5) Second_IDEX_RegRt (
   .clk   (clk),
   .reset (reset),
   .en (IFID_stall),
   .d  (ID_Instr[20:16]),
   .q  (IDEX_RegRt));   

  // Flopr (ID/EX RegisterRt2) 
  flopenr #(5) Second_IDEX_RegRt2 (
   .clk   (clk),
   .reset (reset),
   .en (IFID_stall),
   .d  (ID_Instr[20:16]),
   .q  (IDEX_RegRt2));   

  // Flopr (ID/EX.RegisterRd) 
  flopenr #(5) Second_IDEX_RegRd (
   .clk   (clk),
   .reset (reset),
   .en (IFID_stall),
   .d  (ID_Instr[15:11]),
   .q  (IDEX_RegRd));   
   
  // Flopr (ID/EX Signinm) 
  flopenr #(32) Second_IDEX_Signinm (
   .clk   (clk),
   .reset (reset),
   .en (IFID_stall),
   .d  (ID_shiftedimm),
   .q  (EX_signimm));   
   
  // Flopr (ID/EX Shiftedimm) 
  flopenr #(32) Second_IDEX_shiftedimm (
   .clk   (clk),
   .reset (reset),
   .en (IFID_stall),
   .d  (ID_shiftedimm),
   .q  (EX_shiftedimm)); 
   
  // ID/EX Control Unit, regdst / EX
  flopenr # (1) Controlflopr_EX_regdst(
    .clk   (clk),
    .reset (reset),
    .en (stall_control || EX_flush),
    .d  (regdst),
    .q  (EX_regdst));

  // ID/EX Control Unit, aluop / EX
  flopenr # (2) Controlflopr_EX_aluopX(
    .clk   (clk),
    .reset (reset),
    .en (stall_control || EX_flush),
    .d  (aluop),
    .q  (EX_aluop));
   
  // ID/EX Control Unit, alusrc / EX
  flopenr # (1) Controlflopr_EX_alusrc(
    .clk   (clk),
    .reset (reset),
    .en (stall_control || EX_flush),
    .d  (alusrc),
    .q  (EX_alusrc));

  // ID/EX Control Unit, Branch / MEM
  flopenr # (1) Controlflopr_EX_branch(
    .clk   (clk),
    .reset (reset),
    .en (stall_control || EX_flush),
    .d  (branch),
    .q  (EX_branch));

  // ID/EX Control Unit, Branch(BNE) / MEM
  flopenr # (1) Controlflopr_EX_branchNE(
    .clk   (clk),
    .reset (reset),
    .en (stall_control || EX_flush),
    .d  (branchNE),
    .q  (EX_branchNE));
   
  // ID/EX Control Unit, memread / MEM
   flopenr # (1) Controlflopr_EX_memread(
    .clk   (clk),
    .reset (reset),
    .en (stall_control || EX_flush),
    .d  (memread),
    .q  (EX_memread)
   );

  // ID/EX Control Unit, memwrite / MEM
  flopenr # (1) Controlflopr_EX_memwrite(
    .clk   (clk),
    .reset (reset),
    .en (stall_control || EX_flush),
    .d  (memwrite),
    .q  (EX_memwrite));
   
  // ID/EX Control Unit, memtoreg / WB
  flopenr # (1) Controlflopr_EX_memtoreg(
    .clk   (clk),
    .reset (reset),
    .en (stall_control || EX_flush),
    .d  (memtoreg),
    .q  (EX_memtoreg));

  // ID/EX Control Unit, regwrite / WB
  flopenr # (1) Controlflopr_EX_regwrite(
    .clk   (clk),
    .reset (reset),
    .en (stall_control || EX_flush),
    .d  (regwrite),
    .q  (EX_regwrite));   
   
  // ID/EX Control Unit, jal / WB
  flopenr # (1) Controlflopr_EX_jal(
    .clk   (clk),
    .reset (reset),
    .en (stall_control || EX_flush),
    .d  (jal),
    .q  (EX_jal));   
   
  // ID/EX Control Unit, jump / WB
  flopenr # (1) Controlflopr_jump(
    .clk   (clk),
    .reset (reset),
    .en (stall_control || EX_flush),
    .d  (jump),
    .q  (EX_jump));   

  // *** Execution Stage Logic *** //

  // Mux for Forwarding Unit to ALU
  mux3 #(32) MuxALU1(
    .d0  (EX_srca),
    .d1  (writeregdata),
    .d2  (MEM_aluout),
    .s   (forwarding_control_1), 
    .y   (MuxALU_1));

  // Mux for Forwarding Unit to ALU
  mux3 #(32) MuxALU2(
     .d0 (ReadData_2),
    .d1  (writeregdata),
    .d2  (MEM_aluout),
    .s   (forwarding_control_2), 
    .y   (MuxALU_2));

  // Instantiate Forwarding Unit Control Module
  ForwardingUnit Control_Forwarding(
    .Rs_EX   (IDEX_RegRs),
    .Rt_EX   (IDEX_RegRt),
    .Rd_MEM   (EXMEM_RegRd),
    .Rd_WB   (MEMWB_RegRd),
    .MEM_regwrite   (MEM_regwrite),
    .WB_regwrite    (WB_regwrite),
    .ForwardA   (forwarding_control_1),
    .ForwardB   (forwarding_control_2));
   
  adder pcadd2(
    .a (EX_pcplus4),
    .b (EX_signimmsh),
    .y (EX_pcbranch));

  mux2 #(5) wrmux(
    .d0  (IDEX_RegRt2),
    .d1  (IDEX_RegRd),
    .s   (EX_regdst), 
    .y   (writereg));
  
   mux2 #(5) wrjalmux(
    .d0  (writereg),
    .d1  (5'b11111),
    .s   (EX_jal),
    .y   (writeregaddr));
     
  mux2 #(32) srcbmux(
    .d0 (MuxALU_2),
    .d1 (EX_shiftedimm[31:0]),
    .s  (EX_alusrc),
    .y  (srcb));
 
  mux2 #(32) srcbjrmux(
    .d0 (srcb),
    .d1 (32'b0),
    .s  (EX_jr),
    .y  (srcbmuxresult));
 
  alu alu(
    .a       (MuxALU_1),
    .b       (srcbmuxresult),
    .alucont (EX_alucontrol),
    .result  (EX_aluout),
    .zero    (EX_zero));

  // *** Execution Stage to MEM Access Stage FlipFlop *** //
  
  // Flopr (EX/MEM pc+4)
  flopr #(32) Third_EXMEM_pc4(
   .clk   (clk),
   .reset (reset),
   .d  (EX_pcplus4),
   .q  (MEM_pcplus4)); 

  // Flopr (EX/MEM AddressResult) 
  flopr #(32) Third_EXMEM_AddressResult (
   .clk   (clk),
   .reset (reset),
   .d  (EX_aluout),
   .q  (MEM_addr));  
   
  // Flopr (EX/MEM WriteDataResult) 
  flopr #(32) Third_EXMEM_WriteData (
   .clk   (clk),
   .reset (reset),
   .d  (MuxALU_2),
   .q  (MEM_MuxALU_2));  
   
  // Flopr (EX/MEM zero signal) 
  flopr #(32) Third_EXMEM_Zero (
   .clk   (clk),
   .reset (reset), 
   .d  (EX_zero),
   .q  (MEM_zero));   
   
  // Flopr (EX/MEM ALU-Result) 
  flopr #(32) Third_EXMEM_ALUResult (
   .clk   (clk),
   .reset (reset), 
   .d  (EX_aluout),
   .q  (MEM_aluout));   

  // Flopr (EX/MEM / Mux of Rt or Rd Result) 
  flopr #(5) Third_EXMEM_MuxResult (
   .clk   (clk),
   .reset (reset),
   .d  (writeregaddr),   
   .q  (EXMEM_RegRd)); 

  // Control Unit Flopr (Execution Stage to MEM Access Stage)
  flopr #(7) ControlFlopr_MEM(clk, reset, 
                            {EX_branch, EX_branchNE, EX_memwrite, EX_memtoreg, EX_regwrite, EX_jr, EX_jal},
                            {MEM_branch, MEM_branchNE, MEM_memwrite, MEM_memtoreg, MEM_regwrite, MEM_jr, MEM_jal});

  // *** MEM Access Stage Logic *** //
  
  // PCsrc assign Logic
  Pcsrc_Assign pcsrc_calculation(
   .a      (EX_branch),
   .b      (EX_branchNE),
   .c      (EX_zero),
   .d      (EX_pcsrc));
   
  // *** MEM Access Stage to Write Back Stage FlipFlop *** //
 
  // Flopr (MEM/WB PC+4)
  flopr #(32) Fourth_MEMWB_pc4(
   .clk   (clk),
   .reset (reset),
   .d  (MEM_pcplus4),
   .q  (WB_pcplus4)); 

  // Flopr (MEM/WB ReadData)
  flopr #(32) Fourth_MEMWB_ReadData(
   .clk   (clk),
   .reset (reset),
   .d  (readdata),
   .q  (WB_readdata)); 

  // Flopr (MEM/WB ALU-Result) 
  flopr #(32) Fourth_MEMWB_ALUResult(
   .clk   (clk),
   .reset (reset),
   .d  (MEM_aluout),
   .q  (WB_aluout)); 

  // Flopr (MEM/WB MUX of Rt or Rd result) 
  flopr #(5) Fourth_MEMWB_RegRd (
   .clk   (clk),
   .reset (reset),
   .d  (EXMEM_RegRd),
   .q  (MEMWB_RegRd)); 
  
  // Control Unit Flopr (MEM Access Stage to Write Back Stage)
  flopr #(4) ControlFlopr_WB (clk, reset,
                              {MEM_memtoreg, MEM_regwrite, MEM_jr, MEM_jal},
                              {WB_memtoreg, WB_regwrite, WB_jr, WB_jal});


  // *** WriteBack Stage Logic *** //
  
  mux2 #(32) resmux(
    .d0 (WB_aluout),
    .d1 (WB_readdata),    
    .s  (WB_memtoreg),
    .y  (result));
    
  mux2 #(32) resjalmux(
    .d0 (result),
    .d1 (WB_pcplus4),
    .s  (WB_jal),
    .y  (writeregdata));
 
endmodule