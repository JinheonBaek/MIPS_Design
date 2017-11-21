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

  wire        signext, shiftl16, memtoreg, memread;
  wire [1:0]  branch;
  wire        pcsrc, zero;
  wire        alusrc, regdst, regwrite, jump, jal, jr;
  wire [2:0]  alucontrol;

  // Instantiate Controller
  controller c(
      .clk        (clk),
		.reset      (reset),
      .op         (instr[31:26]), 
		.funct      (instr[5:0]), 
		.zero       (zero),
		.signext    (signext),
		.shiftl16   (shiftl16),
		.memtoreg   (memtoreg),
		.memread    (memread),
		.memwrite   (memwrite),
		.pcsrc      (pcsrc),
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
    .signext    (signext),
    .shiftl16   (shiftl16),
    .memtoreg   (memtoreg),
    .pcsrc      (pcsrc),
    .alusrc     (alusrc),
    .regdst     (regdst),
    .regwrite   (regwrite),
    .jump       (jump),
	 .jal			 (jal),
	 .jr			 (jr),
    .alucontrol (alucontrol),
    .zero       (zero),
    .pc         (pc),
    .instr      (instr),
    .aluout     (memaddr), 
    .writedata  (memwritedata),
    .readdata   (memreaddata));

endmodule

// Decoding stage
module controller(input        clk, reset,
					   input  [5:0] op, funct,
                  input        zero,
                  output       signext,
                  output       shiftl16,
                  output       memtoreg, memwrite, memread,
                  output       pcsrc, alusrc,
                  output       regdst, regwrite,
                  output       jump, jal, jr,
                  output [2:0] alucontrol);

  wire [1:0] aluop;
  wire [1:0] branch;

  maindec md(
    .op       (op),
	 .funct	  (funct),
    .signext  (signext),
    .shiftl16 (shiftl16),
    .memtoreg (memtoreg),
	 .memread  (memread),
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

assign pcsrc = branch[1] ? (branch[0] ? (branch[0] & zero) : (~branch[0] & ~zero)) : (0);

endmodule

// Datapath with flip-flop (mostly control this part for pipeline CPU: add flip-flop, etc...)
module datapath(input         clk, reset,
                input         signext,
                input         shiftl16,
                input         memtoreg, pcsrc,
                input         alusrc, regdst,
                input         regwrite, jump, jal, jr,
                input  [2:0]  alucontrol,
                output        zero,
                output [31:0] pc,
                input  [31:0] instr,
                output [31:0] aluout, writedata,
                input  [31:0] readdata);

  wire [4:0]  writereg, writesubreg;
  wire [31:0] pcnext, pcnextbr, pcnextj, pcplus4, pcbranch;
  wire [31:0] signimm, signimmsh, shiftedimm;
  wire [31:0] srca, srcb;
  wire [31:0] subresult, result;
  wire        shift;

  // next PC logic
  flopr #(32) pcreg(
    .clk   (clk),
    .reset (reset),
    .d     (pcnext),
    .q     (pc));

  adder pcadd1(
    .a (pc),
    .b (32'b100),
    .y (pcplus4));

  sl2 immsh(
    .a (signimm),
    .y (signimmsh));
				 
  adder pcadd2(
    .a (pcplus4),
    .b (signimmsh),
    .y (pcbranch));

  mux2 #(32) pcbrmux(
    .d0  (pcplus4),
    .d1  (pcbranch),
    .s   (pcsrc),
    .y   (pcnextbr));
	 
  mux2 #(32) pcjmux(
    .d0   (pcnextbr),
    .d1   ({pcplus4[31:28], instr[25:0], 2'b00}),
    .s    (jump),
    .y    (pcnextj));

  mux2 #(32) pcmux(  // for jr instruction (pc <- ra, srca is a rs register result)
    .d0   (pcnextj),
    .d1   (srca),
    .s    (jr),
    .y    (pcnext));
	 
  // register file logic
  regfile rf(
    .clk     (clk),
    .we      (regwrite),
    .ra1     (instr[25:21]),
    .ra2     (instr[20:16]),
    .wa      (writereg),
    .wd      (result),
    .rd1     (srca),
    .rd2     (writedata));

  mux2 #(5) wrsubmux(  // select rt or rd for destination
    .d0  (instr[20:16]),
    .d1  (instr[15:11]),
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
    .a       (instr[15:0]),
    .signext (signext),
    .y       (signimm[31:0]));

  shift_left_16 sl16(
    .a         (signimm[31:0]),
    .shiftl16  (shiftl16),
    .y         (shiftedimm[31:0]));

  // ALU logic
  mux2 #(32) srcbmux(
    .d0 (writedata),
    .d1 (shiftedimm[31:0]),
    .s  (alusrc),
    .y  (srcb));

  alu alu(
    .a       (srca),
    .b       (srcb),
    .alucont (alucontrol),
    .result  (aluout),
    .zero    (zero));
    
endmodule