`timescale 1ns/1ps
`define mydelay 1

//--------------------------------------------------------------
// mips.v
// David_Harris@hmc.edu and Sarah_Harris@hmc.edu 23 October 2005
// Single-cycle MIPS processor
//--------------------------------------------------------------

// single-cycle MIPS processor
module mips(input         clk, reset,
            output [31:0] pc,
            input  [31:0] instr,
            output        memwrite,
            output [31:0] memaddr,
            output [31:0] memwritedata,
            input  [31:0] memreaddata);

  wire        signext, shiftl16, memtoreg;
  wire [1:0]  branch;
  wire        pcsrc, zero;
  wire        alusrc, regdst, regwrite, jump, jal, jr;
  wire [2:0]  alucontrol;

  // Instantiate Controller
  controller c(
    .op         (instr[31:26]), 
		.funct      (instr[5:0]), 
		.zero       (zero),
		.signext    (signext),
		.shiftl16   (shiftl16),
		.memtoreg   (memtoreg),
		.memwrite   (ID_memwrite),
		.alusrc     (alusrc),
		.regdst     (regdst),
		.regwrite   (regwrite),
		.jump       (jump),
		.jal 			(jal),
		.jr			(jr),
		.alucontrol (alucontrol));

  // Instantiate Datapath
  datapath dp(
    .clk        (clk),
    .reset      (reset),
    .ID_signext (signext),
    .ID_shiftl16(shiftl16),
    .ID_memtoreg(memtoreg),
    .pcsrc      (pcsrc),
    .ID_alusrc  (alusrc),
    .ID_regdst  (regdst),
    .ID_regwrite(regwrite),
    .ID_jump    (jump),
	 .ID_jal     (jal),
	 .ID_jr	    (jr),
    .ID_aluop   (alucontrol),
	 .ID_branch  (branch),
    .zero       (zero),
    .pc         (pc),
    .IF_instr   (instr),
    .aluout     (memaddr),
	 .ID_memwrite(ID_memwrite),
	 .MEM_memwrite(memwrite),
    .writedata  (memwritedata),
    .MEM_readdata(memreaddata));

endmodule

// Decoding stage
module controller(input  [5:0] op, funct,
                  input        zero,
                  output       signext,
                  output       shiftl16,
                  output       memtoreg, memwrite,
                  output       alusrc,
                  output       regdst, regwrite,
                  output       jump, jal, jr,
						output [1:0] branch,
                  output [2:0] alucontrol);

  wire [1:0] aluop;

  maindec md(
    .op       (op),
	 .funct	  (funct),
    .signext  (signext),
    .shiftl16 (shiftl16),
    .memtoreg (memtoreg),
    .memwrite (memwrite),
    .branch   (branch),
    .alusrc   (alusrc),
    .regdst   (regdst),
    .regwrite (regwrite),
    .jump     (jump),
	 .jal		  (jal),
	 .jr		  (jr),
    .aluop    (aluop));

  aludec ad( 
    .funct      (funct),
    .aluop      (aluop), 
    .alucontrol (alucontrol));

endmodule


module maindec(input  [5:0] op,
					input  [5:0] funct,
               output       signext,
               output       shiftl16,
               output       memtoreg, memwrite,
               output [1:0] branch,
					output		 alusrc,
               output       regdst, regwrite,
               output       jump, jal, jr,
               output [1:0] aluop);

  reg [13:0] controls;

  assign {signext, shiftl16, regwrite, regdst, alusrc, branch, memwrite,
          memtoreg, jump, aluop, jal, jr} = controls;

  always @(*)
    case(op)
      6'b000000: case(funct)	// Rtype
						6'b001000: controls <= #`mydelay 14'b00000000000001; // JR
						default:   controls <= #`mydelay 14'b00110000001100; // Rtype default
					  endcase
		6'b100011: controls <= #`mydelay 14'b10101000100000; // LW
      6'b101011: controls <= #`mydelay 14'b10001001000000; // SW
      6'b000100: controls <= #`mydelay 14'b10000110000100; // BEQ
		6'b000101: controls <= #`mydelay 14'b10000100000100; // BNE
      6'b001000, 
      6'b001001: controls <= #`mydelay 14'b10101000000000; // ADDI, ADDIU: only difference is exception
      6'b001101: controls <= #`mydelay 14'b00101000001000; // ORI
      6'b001111: controls <= #`mydelay 14'b01101000000000; // LUI
      6'b000010: controls <= #`mydelay 14'b00000000010000; // J
		6'b000011: controls <= #`mydelay 14'b00100000010010; // JAL
      default:   controls <= #`mydelay 14'bxxxxxxxxxxxxxx; // ???
    endcase

endmodule

module aludec(input      [5:0] funct,
              input      [1:0] aluop,
              output reg [2:0] alucontrol
				  );
	
  always @(*)
    case(aluop)
      2'b00: alucontrol <= #`mydelay 3'b010;  // add
      2'b01: alucontrol <= #`mydelay 3'b110;  // sub
      2'b10: alucontrol <= #`mydelay 3'b001;  // or
      default: case(funct)          // RTYPE
          6'b100000,
          6'b100001: alucontrol <= #`mydelay 3'b010; // ADD, ADDU: only difference is exception
          6'b100010,
          6'b100011: alucontrol <= #`mydelay 3'b110; // SUB, SUBU: only difference is exception
          6'b100100: alucontrol <= #`mydelay 3'b000; // AND
          6'b100101: alucontrol <= #`mydelay 3'b001; // OR
			 6'b100010,
          6'b101011: alucontrol <= #`mydelay 3'b111; // SLT, SLTU: only difference is exception
          default:   alucontrol <= #`mydelay 3'bxxx; // ???
        endcase
    endcase
    
endmodule

// Datapath with flip-flop (mostly control this part for pipeline CPU: add flip-flop, etc...)
module datapath(input         clk, reset,
                input         ID_signext,
                input         ID_shiftl16,
                input         ID_memtoreg, pcsrc,
                input         ID_alusrc, ID_regdst,
                input         ID_regwrite, ID_jump, ID_jal, ID_jr,
                input  [2:0]  ID_aluop,
					 input         ID_memwrite,
					 input  [1:0]  ID_branch,
					 output  reg   MEM_memwrite,
                output        zero,
                output [31:0] pc,
                input  [31:0] IF_instr,
                output [31:0] aluout, writedata,
                input  [31:0] MEM_readdata);

  wire [4:0]  writereg, writesubreg;
  wire [31:0] pcnextbr, pcnextj;
  wire [31:0] srca, srcb;
  wire [31:0] subresult, result;
  wire        shift;
  
  // Instruction Fetch Variables
  wire [31:0] IF_pcplus4;
  wire [31:0] IF_pcnext;
  
  // Instruction Decoding Variables
  reg  [31:0] ID_instr;
  reg  [31:0] ID_pcplus4;
  wire [31:0] ID_srca, ID_writedata;				// Read-data 1, 2
  wire [31:0] ID_signimm, ID_shiftedimm;
  reg  [4:0]  ID_instr_20_16, ID_instr_15_11;	// rd or rt
  
  // Execution Variables
  reg  [4:0]  EX_instr_20_16, EX_instr_15_11;
  reg  [31:0] EX_srca, EX_writedata;
  reg  [31:0] EX_pcplus4;
  reg  [31:0] EX_signimm;
  reg  [31:0] EX_shiftedimm;
  wire [31:0] EX_signimmsh;
  wire [31:0] EX_pcbranch;
  
  // Execution Control Signals
  reg  		  EX_regdst, EX_aluop, EX_alusrc;
  reg			  EX_memwrite;
  reg  [1:0]  EX_branch;
  reg			  EX_regwrite, EX_memtoreg;
  
  // Memory Access Variables
  reg  [31:0] MEM_pcbranch;
  reg  [31:0] MEM_pcplus4;
  wire        MEM_pcsrc;
  
  // Memory Access Control Signals
  reg  [1:0]  MEM_branch;
  reg			  MEM_regwrite, MEM_memtoreg;
  
  // Write Back Variables
  
  // Write Back Control Signals
  reg			  WB_regwrite, WB_memtoreg;
  
  assign EX_pcsrc = EX_branch[1] ? (EX_branch[0] ? (EX_branch[0] & zero) : (~EX_branch[0] & ~zero)) : (0);
  
  // Flip Flop between Instruction Fetch and Instruction Decoding
  always @(posedge clk) begin
		ID_instr <= IF_instr;
		ID_pcplus4 <= IF_pcplus4;
  end
  
  // Flip Flop between Instruction Decoding and Execution
  always @(posedge clk) begin
		EX_instr_20_16 <= ID_instr_20_16;
		EX_instr_15_11 <= ID_instr_15_11;
		EX_srca <= ID_srca;
		EX_writedata <= ID_writedata;
		EX_pcplus4 <= ID_pcplus4;
		EX_signimm <= ID_signimm;
		EX_shiftedimm <= ID_shiftedimm;
		
		// Control Signals
		EX_regdst <= ID_regdst;
		EX_aluop <= ID_aluop;
		EX_alusrc <= ID_alusrc;
		EX_memwrite <= ID_memwrite;
		EX_branch <= ID_branch;
		EX_regwrite <= ID_memwrite;
		EX_memtoreg <= ID_memtoreg;
  end
  
  // Flip Flop between Execution and Memeory Access
  always @(posedge clk) begin
		MEM_pcbranch <= EX_pcbranch;
		MEM_pcplus4 <= EX_pcplus4;
		
		// Control Signals
		MEM_memwrite <= EX_memwrite;
		MEM_branch <= EX_branch;
		MEM_regwrite <= EX_regwrite;
		MEM_memtoreg <= EX_memtoreg;
  end
  
  // Flip Flop between Memory Access and Write Back
  always @(posedge clk) begin
  
		// Control Signals
		WB_regwrite <= MEM_regwrite;
		WB_memtoreg <= MEM_memtoreg;
  end
  
  // next pc logic
  flopr #(32) pcreg(
		 .clk   (clk),
		 .reset (reset),
		 .d     (IF_pcnext),
		 .q     (IF_pc));
		 
	 adder pcadd1(
		 .a (IF_pc),
		 .b (32'b100),
		 .y (IF_pcplus4));
		 
	 sl2 immsh(
		 .a (EX_signimm),
		 .y (EX_signimmsh));
						 
	 adder pcadd2(
		 .a (EX_pcplus4),
		 .b (EX_signimmsh),
		 .y (EX_pcbranch));

	 mux2 #(32) pcbrmux(
		 .d0  (IF_pcplus4),
		 .d1  (MEM_pcbranch),
		 .s   (pcsrc),
		 .y   (pcnextbr));
		 
	 mux2 #(32) pcjmux(
		 .d0   (pcnextbr),
		 .d1   ({MEM_pcplus4[31:28], IF_instr[25:0], 2'b00}),
		 .s    (jump),
		 .y    (pcnextj));

	 mux2 #(32) pcmux(  // for jr instruction (pc <- ra, srca is a rs register result)
		 .d0   (pcnextj),
		 .d1   (srca),
		 .s    (jr),
		 .y    (IF_pcnext));
	 
  // register file logic
  regfile rf(
    .clk     (clk),
    .we      (regwrite),
    .ra1     (ID_instr[25:21]),
    .ra2     (ID_instr[20:16]),
    .wa      (writereg),
    .wd      (result),
    .rd1     (ID_srca),
    .rd2     (ID_writedata));

  mux2 #(5) wrsubmux(  // select rt or rd for destination
    .d0  (IF_instr[20:16]),
    .d1  (IF_instr[15:11]),
    .s   (regdst),
    .y   (writesubreg));
	 
  mux2 #(5) wrmux(  // select writesubreg or ra($r31) reg (for jal instruction: ra <- pc + 4)
    .d0  (writesubreg),
    .d1  (5'b11111),
    .s   (jal),
    .y   (writereg));
	 
  mux2 #(32) resmux( // aluout or memory_data
    .d0 (aluout),
    .d1 (readdata),
    .s  (memtoreg),
    .y  (subresult));

  mux2 #(32) jalresmux( // subresult or pcplus4(for jal instruction: ra <- pc + 4)
    .d0 (subresult),
    .d1 (pcplus4),
    .s  (jal),
    .y  (result));	 

  sign_zero_ext sze(
    .a       (ID_instr[15:0]),
    .signext (ID_signext),
    .y       (ID_signimm[31:0]));

  shift_left_16 sl16(
    .a         (ID_signimm[31:0]),
    .shiftl16  (ID_shiftl16),
    .y         (ID_shiftedimm[31:0]));

  // ALU logic
  mux2 #(32) srcbmux(
    .d0 (EX_writedata),
    .d1 (EX_shiftedimm[31:0]),
    .s  (EX_alusrc),
    .y  (srcb));

  alu alu(
    .a       (srca),
    .b       (srcb),
    .alucont (alucontrol),
    .result  (aluout),
    .zero    (zero));
    
endmodule
