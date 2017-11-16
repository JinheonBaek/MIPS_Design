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
module controller(input  [5:0] op, funct,
                  input        zero,
                  output       signext,
                  output       shiftl16,
                  output       memtoreg, memwrite,
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
