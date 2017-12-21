`timescale 1ns/1ps
`define mydelay 1

//------------------------------------------------
// mipsparts.v
// Jinheon.Baek@outlook.kr (Korea University)
// Components used in MIPS processor
//------------------------------------------------

`define REGFILE_FF
`ifdef REGFILE_FF

// regfile
module regfile(input             clk, 
               input             we, 
               input      [4:0]  ra1, ra2, wa, 
               input      [31:0] wd, 
               output reg [31:0] rd1, rd2);

   reg [31:0] R1;
   reg [31:0] R2;
   reg [31:0] R3;
   reg [31:0] R4;
   reg [31:0] R5;
   reg [31:0] R6;
   reg [31:0] R7;
   reg [31:0] R8;
   reg [31:0] R9;
   reg [31:0] R10;
   reg [31:0] R11;
   reg [31:0] R12;
   reg [31:0] R13;
   reg [31:0] R14;
   reg [31:0] R15;
   reg [31:0] R16;
   reg [31:0] R17;
   reg [31:0] R18;
   reg [31:0] R19;
   reg [31:0] R20;
   reg [31:0] R21;
   reg [31:0] R22;
   reg [31:0] R23;
   reg [31:0] R24;
   reg [31:0] R25;
   reg [31:0] R26;
   reg [31:0] R27;
   reg [31:0] R28;
   reg [31:0] R29;
   reg [31:0] R30;
   reg [31:0] R31;

   always @(posedge clk)
   begin
      if (we) 
    begin
         case (wa[4:0])
         5'd0:   ;
         5'd1:   R1  <= wd;
         5'd2:   R2  <= wd;
         5'd3:   R3  <= wd;
         5'd4:   R4  <= wd;
         5'd5:   R5  <= wd;
         5'd6:   R6  <= wd;
         5'd7:   R7  <= wd;
         5'd8:   R8  <= wd;
         5'd9:   R9  <= wd;
         5'd10:  R10 <= wd;
         5'd11:  R11 <= wd;
         5'd12:  R12 <= wd;
         5'd13:  R13 <= wd;
         5'd14:  R14 <= wd;
         5'd15:  R15 <= wd;
         5'd16:  R16 <= wd;
         5'd17:  R17 <= wd;
         5'd18:  R18 <= wd;
         5'd19:  R19 <= wd;
         5'd20:  R20 <= wd;
         5'd21:  R21 <= wd;
         5'd22:  R22 <= wd;
         5'd23:  R23 <= wd;
         5'd24:  R24 <= wd;
         5'd25:  R25 <= wd;
         5'd26:  R26 <= wd;
         5'd27:  R27 <= wd;
         5'd28:  R28 <= wd;
         5'd29:  R29 <= wd;
         5'd30:  R30 <= wd;
         5'd31:  R31 <= wd;
         endcase
     end
   end

   always @(*)
   begin
      case (ra2[4:0])
      5'd0:   rd2 = 32'b0;
      5'd1:   rd2 = R1;
      5'd2:   rd2 = R2;
      5'd3:   rd2 = R3;
      5'd4:   rd2 = R4;
      5'd5:   rd2 = R5;
      5'd6:   rd2 = R6;
      5'd7:   rd2 = R7;
      5'd8:   rd2 = R8;
      5'd9:   rd2 = R9;
      5'd10:  rd2 = R10;
      5'd11:  rd2 = R11;
      5'd12:  rd2 = R12;
      5'd13:  rd2 = R13;
      5'd14:  rd2 = R14;
      5'd15:  rd2 = R15;
      5'd16:  rd2 = R16;
      5'd17:  rd2 = R17;
      5'd18:  rd2 = R18;
      5'd19:  rd2 = R19;
      5'd20:  rd2 = R20;
      5'd21:  rd2 = R21;
      5'd22:  rd2 = R22;
      5'd23:  rd2 = R23;
      5'd24:  rd2 = R24;
      5'd25:  rd2 = R25;
      5'd26:  rd2 = R26;
      5'd27:  rd2 = R27;
      5'd28:  rd2 = R28;
      5'd29:  rd2 = R29;
      5'd30:  rd2 = R30;
      5'd31:  rd2 = R31;
      endcase
   end

   always @(*)
   begin
      case (ra1[4:0])
      5'd0:   rd1 = 32'b0;
      5'd1:   rd1 = R1;
      5'd2:   rd1 = R2;
      5'd3:   rd1 = R3;
      5'd4:   rd1 = R4;
      5'd5:   rd1 = R5;
      5'd6:   rd1 = R6;
      5'd7:   rd1 = R7;
      5'd8:   rd1 = R8;
      5'd9:   rd1 = R9;
      5'd10:  rd1 = R10;
      5'd11:  rd1 = R11;
      5'd12:  rd1 = R12;
      5'd13:  rd1 = R13;
      5'd14:  rd1 = R14;
      5'd15:  rd1 = R15;
      5'd16:  rd1 = R16;
      5'd17:  rd1 = R17;
      5'd18:  rd1 = R18;
      5'd19:  rd1 = R19;
      5'd20:  rd1 = R20;
      5'd21:  rd1 = R21;
      5'd22:  rd1 = R22;
      5'd23:  rd1 = R23;
      5'd24:  rd1 = R24;
      5'd25:  rd1 = R25;
      5'd26:  rd1 = R26;
      5'd27:  rd1 = R27;
      5'd28:  rd1 = R28;
      5'd29:  rd1 = R29;
      5'd30:  rd1 = R30;
      5'd31:  rd1 = R31;
      endcase
   end

endmodule

`else

module regfile(input         clk, 
               input         we, 
               input  [4:0]  ra1, ra2, wa, 
               input  [31:0] wd, 
               output [31:0] rd1, rd2);

  reg [31:0] rf[31:0];

  // three ported register file
  // read two ports combinationally
  // write third port on rising edge of clock
  // register 0 hardwired to 0

  always @(posedge clk)
    if (we) rf[wa] <= #`mydelay wd;   

  assign #`mydelay rd1 = (ra1 != 0) ? rf[ra1] : 0;
  assign #`mydelay rd2 = (ra2 != 0) ? rf[ra2] : 0;
endmodule

`endif

// ALU Logic
module alu(input      [31:0] a, b, 
           input      [2:0]  alucont, 
           output reg [31:0] result,
           output            zero);

  wire [31:0] b2;
  wire [31:0] sum;
  wire sltu;

  assign b2 = alucont[2] ? ~b:b; 
  assign sum = a + b2 + alucont[2];
  assign sltu = sum[31];

  always@(*)
  begin
    case(alucont[1:0])
      2'b00: result <= #`mydelay a & b2;
      2'b01: result <= #`mydelay a | b2;
      2'b10: result <= #`mydelay sum[31:0];
      2'b11: result <= #`mydelay sltu;
    endcase
   end
  assign #`mydelay zero = (result == 32'b0);

endmodule

// Adder Logic
module adder(input [31:0] a, b,
             output [31:0] y);

  assign #`mydelay y = a + b;
endmodule

// Shift Left Logic (Shift Left by 2)
module sl2(input  [31:0] a,
           output [31:0] y);

  // shift left by 2
  assign #`mydelay y = {a[29:0], 2'b00};
endmodule

// Sign Zero Extension Logic
module sign_zero_ext(input      [15:0] a,
                     input             signext,
                     output reg [31:0] y);
              
   always @(*)
   begin
      if (signext)  y <= {{16{a[15]}}, a};
      else          y <= {{16{1'b0}}, a};
   end

endmodule

// Shift Left 16 Logic
module shift_left_16(input      [31:0] a,
                     input         shiftl16,
                     output reg [31:0] y);

   always @(*)
   begin
      if (shiftl16) y = {a[15:0],16'b0};
      else          y = a[31:0];
   end
              
endmodule

// Start: Jinheon Baek

// Basic form Synchronus D FlipFlop
module flopr #(parameter WIDTH = 8)
              (input                  clk, reset,
               input      [WIDTH-1:0] d, 
               output reg [WIDTH-1:0] q);

  always @(posedge clk, posedge reset)
    if (reset) q <= #`mydelay 0;
    else       q <= #`mydelay d;

endmodule

// Synchronus D FlipFlop (Add Enable signal)
module flopenr #(parameter WIDTH = 8)
                (input                  clk, reset,
                 input                  en,
                 input      [WIDTH-1:0] d, 
                 output reg [WIDTH-1:0] q);
 
  always @(posedge clk, posedge reset)
    if      (reset) q <= #`mydelay 0;
    else if (en)    q <= #`mydelay 0;
    else            q <= #`mydelay d;

endmodule

// Mux (Input is 2)
module mux2 #(parameter WIDTH = 8)
             (input  [WIDTH-1:0] d0, d1, 
              input              s, 
              output [WIDTH-1:0] y);

  assign #`mydelay y = s ? d1 : d0; 

endmodule

// Mux (Input is 3)
module mux3 #(parameter WIDTH = 8)
             (input  [WIDTH-1:0] d0, d1, d2 ,
              input  [1:0]           s,
              output reg[WIDTH-1:0] y);
       
always @(s or d0 or d1 or d2)
   begin
   if (s==2'b10) 
      begin 
      y=d2;
      end
   else if (s==2'b01) 
      begin 
      y=d1;
      end
   else
      begin 
      y=d0;
      end
   end
endmodule

// Hazard Detection Unit Control Module that returns hazard detection signals
module HazardDetection (input [4:0] Rs_ID,   //RS
                        input [4:0] Rt_ID,   //RT
                        input [4:0] Rt_EX,   //IF/ID.Register.RT
                        input MemRead_EX,    //ID/EX.MemRead
                        input pcsrc,
                        input jump,
                        input jal,
                        input jr,
                        output reg  s1,
                        output reg  s2,
                        output reg  s3,
                        output reg  s4);

always @(Rs_ID or Rt_ID or Rt_EX or MemRead_EX or pcsrc or jump or jal or jr or s1 or s2 or s3 or s4)
  
  begin

    if (MemRead_EX==1 && Rt_EX!=0 &&(Rt_EX==Rs_ID || Rt_EX== Rt_ID))
      begin
      s1<=1'b1;
      s2<=1'b1;
      s3<=1'b1;
      end
    else
      begin
      s1<=1'b0;
      s2<=1'b0;
      s3<=1'b0;
      end

    // If pcsrc value is 1, flush_EX value is 1 too.
    if(pcsrc || jump || jal || jr)
      begin
      s4<=1'b1;
      end
    else
      begin
      s4<=1'b0;
      end

  end

endmodule

// Forwarding Unit Control Module that returns forward signal
module ForwardingUnit (input [4:0] Rs_EX,  //Regiser Rs EX
                       input [4:0] Rt_EX,  //Regiser Rt EX
                       input [4:0] Rd_MEM, //Regiser Rd MEM
                       input [4:0] Rd_WB,  //Regiser Rd WB
                       input RegWrite_MEM, RegWrite_WB,
                       output reg [1:0] ForwardA,
                       output reg [1:0] ForwardB);

always @(Rs_EX or Rt_EX or Rd_MEM or Rd_WB or RegWrite_MEM or RegWrite_WB)

  begin
    begin
      if(RegWrite_MEM==1 && Rd_MEM!=0 && Rd_MEM==Rs_EX)
          ForwardA=2'b10;
      else if(RegWrite_WB==1 && Rd_WB==Rs_EX && Rd_WB!=0 && Rd_MEM!=Rs_EX )   
          ForwardA=2'b01;
      else ForwardA=2'b00;
    end

    begin
      if(RegWrite_MEM==1 && Rd_MEM!=0 && Rd_MEM==Rt_EX)
          ForwardB=2'b10;
      else if(RegWrite_WB==1 && Rd_WB==Rt_EX && Rd_WB!=0 && Rd_MEM!=Rt_EX)
          ForwardB=2'b01;
      else ForwardB=2'b00;
    end
  end

endmodule

// Forwarding Detection2 Unit Control (Write Back to Instruction Decoding Stage)
module ForwardingWBID (input [4:0] Rs_ID,        //RS
                       input [4:0] Rt_ID,        //RT
                       input [4:0] WriteReg_WB,  // Register Rd_WB
                       input RegWrite_WB,        //WB RegWrite                       
                       output reg  s1,
                       output reg  s2);

always @(Rs_ID or Rt_ID or WriteReg_WB or RegWrite_WB)
   begin
   if (RegWrite_WB==1 && WriteReg_WB!=0 &&(WriteReg_WB==Rs_ID))
   s1<= #`mydelay 1'b1;
   else
   s1<= #`mydelay 1'b0;

   if(RegWrite_WB==1 && WriteReg_WB!=0 &&(WriteReg_WB==Rt_ID))
   s2<= #`mydelay 1'b1;
   else
   s2<= #`mydelay 1'b0;
   end

endmodule

module Pcsrc_Assign (input a,
                     input b,
                     input c,
                     output d);

  assign d = (b && ~c)||(a && c);

endmodule

// End : Jinheon Baek

module maindec(input  [5:0] op,
               output       signext,
               output       shiftl16,
               output       memtoreg, memwrite, memread,
               output       alusrc,
               output       regdst, regwrite,
               output       jump, jal,
               output        branch,branchNE,
               output [1:0] aluop);

  reg [13:0] controls;

  assign {signext, shiftl16, regwrite, regdst, alusrc, branch, branchNE, memwrite, memread,
          memtoreg, jump, jal,aluop} = controls;

   always @(*)
    case(op)
      6'b000000: controls <= #`mydelay 14'b00110000000011; // Rtype
      6'b100011: controls <= #`mydelay 14'b10101000110000; // LW
      6'b101011: controls <= #`mydelay 14'b10001001000000; // SW
      6'b000100: controls <= #`mydelay 14'b10000100000001; // BEQ
      6'b001000, 
      6'b001001: controls <= #`mydelay 14'b10101000000000; // ADDI, ADDIU: only difference is exception
      6'b001101: controls <= #`mydelay 14'b00101000000010; // ORI
      6'b001111: controls <= #`mydelay 14'b01101000000000; // LUI
      6'b000010: controls <= #`mydelay 14'b00000000001000; // J
      6'b001010,
      6'b001011: controls <= #`mydelay 14'b10101000000011; // SLTI ,SLTIU   
      6'b000011: controls <= #`mydelay 14'b00100000001100; // JAL
      6'b000101: controls <= #`mydelay 14'b10000010000001; // BNE
      default:   controls <= #`mydelay 14'bxxxxxxxxxxxxxx; // ???
    endcase

endmodule

module aludec(input  [5:0] funct,
              input  [1:0] aluop,
              output       jr,
              output [2:0] alucontrol);

  reg [3:0] control2;
  assign {jr,alucontrol} = control2;
          
  always @(*) 
    case(aluop)
      2'b00: control2 <= #`mydelay 4'b0010;  // add
      2'b01: control2 <= #`mydelay 4'b0110;  // sub
      2'b10: control2 <= #`mydelay 4'b0001;  // or
      default: case(funct)          		   // RTYPE
          6'b100000,
          6'b100001: control2 <= #`mydelay 4'b0010; // ADD, ADDU: only difference is exception
          6'b100010,
          6'b100011: control2 <= #`mydelay 4'b0110; // SUB, SUBU: only difference is exception
          6'b100100: control2 <= #`mydelay 4'b0000; // AND
          6'b100101: control2 <= #`mydelay 4'b0001; // OR
          6'b101011,
          6'b101010: control2 <= #`mydelay 4'b0111; // SLT, SLTU
          6'b001000: control2 <= #`mydelay 4'b1001; // JR
          default:   control2 <= #`mydelay 4'b0xxx; // ???
        endcase
    endcase
   
endmodule
