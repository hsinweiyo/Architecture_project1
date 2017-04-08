`timescale 1ns / 1ps
//Subject:     Architecture Project1 - Simulator
//--------------------------------------------------------------------------------
//Version:     1
//--------------------------------------------------------------------------------
//Writer:      
//----------------------------------------------
//Date:        
//----------------------------------------------
//Description: 
//--------------------------------------------------------------------------------
module Simulator(
        clk_i,
		rst_i
		);

//Parameter
`define INSTR_NUM 256
`define ADD  6'h20
`define SUB  6'h22
`define AND  6'h24
`define OR   6'h25
`define SLT	 6'h2a
`define ADDI 6'h08
`define LW   6'h23
`define SW   6'h2b
`define SLTI 6'h0a
`define BEQ  6'h04

//I/O ports
input clk_i;
input rst_i;  

//DO NOT CHANGE SIZE, NAME
reg 	   [32-1:0] Instr_Mem [0:`INSTR_NUM-1];
reg 	   [32-1:0] Data_Mem [0:`INSTR_NUM-1];
reg signed [32-1:0] Reg_File  [0:32-1];

//Register
wire [32-1:0] instr;
reg [32-1:0] pc_addr;
wire [6-1:0]  op;
wire [5-1:0]  rs;
wire [5-1:0]  rt;
wire [5-1:0]  rd;
wire [5-1:0]  shamt;
wire [6-1:0]  func;
integer i;
wire [16-1:0] imm;

assign op 	 = instr[31:26];
assign rs    = instr[25:21];
assign rt    = instr[20:16];
assign rd    = instr[15:11];
assign shamt = instr[10:6];
assign func  = instr[5:0];
assign imm[15:0] = {rd, shamt, func};
assign instr = Instr_Mem[pc_addr/4];

//Main function
always @(posedge clk_i or negedge rst_i) begin
	if(rst_i == 0) begin
		for(i=0; i<32; i=i+1)
			Reg_File[i] <= 32'd0;	
		pc_addr = 32'd0;
	end
	else begin
		if(op == 6'd0)begin //R-type
			case(func)
				`ADD: begin
					Reg_File[rd] <= Reg_File[rs] + Reg_File[rt];
				end
				`SUB: begin
					Reg_File[rd] <= Reg_File[rs] - Reg_File[rt];
				end
				`AND: begin
					Reg_File[rd] <= Reg_File[rs] & Reg_File[rt];
				end
				`OR: begin
					Reg_File[rd] <= Reg_File[rs] | Reg_File[rt];
				end
				`SLT: begin
					Reg_File[rd] <= (Reg_File[rs] < Reg_File[rt]) ? 32'd1 : 32'd0;
				end
			endcase
		end
		else begin //I-type
			case(op)
				`ADDI: begin
					if(rt != 6'd0) begin
						Reg_File[rt] <= Reg_File[rs] + $signed(imm);
					end
				end
				`LW: begin
					if(rt != 6'd0 && ((Reg_File[rs]+imm)/4) < `INSTR_NUM && ((Reg_File[rs]+imm) % 4) == 0) begin
						Reg_File[rt] <= Data_Mem[(Reg_File[rs] + imm)/4];
					end
				end
				`SW: begin
					if(((Reg_File[rs]+imm)/4) < `INSTR_NUM && ((Reg_File[rs]+imm) % 4) == 0) begin
						Data_Mem[(Reg_File[rs] + imm)/4] <= Reg_File[rt];
					end
				end
				`SLTI: begin
					if(rt != 6'd0) begin
						Reg_File[rt] <= (Reg_File[rs] < $signed(imm)) ? 32'd1 : 32'd0;
					end
				end
				`BEQ: begin
					if(($signed(pc_addr) + $signed(imm)) >= 0 && ($signed(pc_addr) + $signed(imm)) < `INSTR_NUM &&
						(Reg_File[rs] == Reg_File[rt])) begin 
						pc_addr = ($signed(pc_addr) + ($signed(imm)*4));
					end
				end
			endcase
		end
		pc_addr = pc_addr + 32'd4;
	end
end
endmodule
