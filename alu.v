`timescale 1ns/1ns

`define NOP 4'b0000
`define ARITH_2OP 4'b0001
`define ARITH_1OP 4'b0010
`define MOVI 4'b0011
`define ADDI 4'b0100
`define SUBI 4'b0101
`define LOAD 4'b0110
`define STOR 4'b0111
`define BEQ 4'b1000
`define BGE 4'b1001
`define BLE 4'b1010
`define BC 4'b1011
`define J 4'b1100
`define CONTROL 4'b1111

`define ADD 3'b000
`define ADDC 3'b001
`define SUB 3'b010
`define SUBB 3'b011
`define AND 3'b100
`define OR 3'b101
`define XOR 3'b110
`define XNOR 3'b111

`define NOT 3'b000
`define SHIFTL 3'b001
`define SHIFTR 3'b010
`define CP 3'b011

`define STC    12'b000000000001
`define STB    12'b000000000010
`define RESET  12'b101010101010
`define HALT   12'b111111111111




/*
 * Module: alu
 * Description: Arithmetic Logic Unit
 *              This unit contains the math/logical units for the processor, and is used for the following functions:
 *              - 2 Operand Arithmetic
 *                  Add, Add with Carry, Subtract, Subtract with Borrow, bitwise AND/OR/XOR/XNOR
 *              - 1 Operand Arithmetic
 *                  Bitwise NOT, Shift Left, Shift Right, Register Copy
 *              - Add immediate (no carry bit)
 *              - Subtract immediate (no borrow bit)
 *              - Load and Store (Address addition - effectively the same to the ALU as Add immediate)
 *              This module does not contain the adder for the Program Counter, nor does it have the comparator logic for branches
 */
module alu (
	input 	      arith_1op_pi,
	input 	      arith_2op_pi,
	input [2:0]   alu_func_pi,
	input 	      addi_pi,
	input 	      subi_pi,
	input 	      load_or_store_pi,

	input [15:0]  reg1_data_pi, 	// Register operand 1
	input [15:0]  reg2_data_pi, 	// Register operand 2
	input [5:0]   immediate_pi, 	// Immediate operand
	input 	      stc_cmd_pi, 		// STC instruction must set carry_out
	input 	      stb_cmd_pi, 		// STB instruction must set borrow_out
	input 	      carry_in_pi, 		// Use for ADDC
	input 	      borrow_in_pi, 	// Use for SUBB
	
	output [15:0] alu_result_po, 	// The 16-bit result disregarding carry out or borrow
	output 	      carry_out_po, 	// Propagate carry_in unless an arithmetic/STC instruction generates a new carry 
	output 	      borrow_out_po 	// Propagate borrow_in unless an arithmetic/STB instruction generates a new borrow
);

	wire [16:0] added, addedc, subtracted, subtractedc, addsub; 
	
	wire [15:0] andout, orout, xorout, xnorout, andor, xorxnor, opout2, addiout1, subiint1, bitwise;
	wire [15:0] addisubi, notOut, shiftLout, shiftRout, cpout1, notL, cpR1, opout1, opout12, finalres;


	// arith 2 op
	// handle ADD ADDC SUB SUBB
	assign added = reg1_data_pi + reg2_data_pi;
	assign subtracted = reg1_data_pi - reg2_data_pi;
	assign addedc = alu_func_pi[0] ? added + carry_in_pi : added;
	assign subtractedc = alu_func_pi[0] ? subtracted - borrow_in_pi : subtracted;

	assign addsub = alu_func_pi[1] ? subtractedc : addedc;

	// AND OR XOR XNOR
	assign andout = (reg1_data_pi & reg2_data_pi);
	assign orout = (reg1_data_pi | reg2_data_pi);
	assign xorout = (reg1_data_pi ^ reg2_data_pi);
	assign xnorout = (reg1_data_pi ~^ reg2_data_pi);

	assign andor = (alu_func_pi[0]) ? orout : andout;
	assign xorxnor = (alu_func_pi[0]) ? xnorout : xorout;

	assign bitwise = (alu_func_pi[1]) ? xorxnor : andor;

	// ADDI SUBI 
	assign addiout1 = reg1_data_pi + immediate_pi;
	assign subiint1 = reg1_data_pi - immediate_pi;
	assign addisubi = (addi_pi | load_or_store_pi) ? addiout1 : subiint1;

	// NOT SHIFTL SHIFTR CP
	assign notOut = ~reg1_data_pi;
	assign shiftLout = (reg1_data_pi << 1);
	assign shiftRout = (reg1_data_pi >> 1);
	assign cpout1 = reg1_data_pi;

	assign notL = (alu_func_pi[0]) ? shiftLout : notOut;
	assign cpR1 = (alu_func_pi[0]) ? cpout1 : shiftRout;
	assign opout1 = (alu_func_pi[1]) ? cpR1 : notL;

	assign opout12 = (arith_1op_pi) ? opout1 : addisubi;

	// set final 
	assign opout2 = (~alu_func_pi[2]) ? addsub[15:0] : bitwise;

	assign finalres = (arith_2op_pi) ? opout2 : opout12;
	assign alu_result_po = (arith_1op_pi | arith_2op_pi | addi_pi | subi_pi | load_or_store_pi) ? finalres : 16'h0000;

	// assign carries
	wire carryout, co2, borrowout, bo2;
	assign carryout = (arith_2op_pi & ~(alu_func_pi[1]) & ~alu_func_pi[2]) ? addsub[16] : carry_in_pi;
	assign co2 = (stc_cmd_pi) ? 1'b1 : carryout;
	assign carry_out_po = addi_pi ? 1'b0 : co2;

	assign borrowout = (arith_2op_pi & (alu_func_pi[1]) & ~alu_func_pi[2]) ? addsub[16] : borrow_in_pi;
	assign bo2 = (stb_cmd_pi) ? 1'b1 : borrowout;
	assign borrow_out_po = subi_pi ? 1'b0 : bo2;


endmodule // alu
