`timescale 1ns/1ps

/*
 * Module: processor
 * Description: The top module of this lab 
 */
module processor (
	input CLK_pi,
	input CPU_RESET_pi
); 
 
   wire       cpu_clk_en; // Used to slow down the system clock CLK_pi

   // Define additional wires to connect up all input and output ports of the modules

// from register
wire [15:0] instruction;   
wire [2:0] alu_func;
wire [2:0] destination_reg;
wire [2:0] source_reg1;
wire [2:0] source_reg2;
wire [11:0] immediate;

// from ALU
wire arith_1op, arith_2op, addi, subi, load, store;
wire stc_cmd, stb_cmd, carry_in, borrow_in;
wire carry_out, borrow_out;
wire [15:0] reg1_data, reg2_data, alu_result, regD_data;

//from decoder
wire movi_higher, movi_lower;
wire branch_eq, branch_ge, branch_le, branch_carry, branch_taken;
wire jump;
wire halt_cmd;
wire rst_cmd;
// for memory 
wire [15:0] wdata, rdata;
//program counter
wire [15:0] pc;

// Instantiate the modules for different components:
// e Program Counter 
// e Instruction Memory 
// e Instruction Decoder 
// e Register File
// e ALU 
// e Branch Module
// e Data Memory
assign data_mem_data = 16'hFFFF;

decoder decoder1(
	.instruction_pi(instruction),
	.alu_func_po(alu_func),
	.destination_reg_po(destination_reg),
	.source_reg1_po(source_reg1),
	.source_reg2_po(source_reg2), 
	.immediate_po(immediate),
	.arith_2op_po(arith_2op),
	.arith_1op_po(arith_1op),
	.movi_lower_po(movi_lower), 
	.movi_higher_po(movi_higher), 
	.addi_po(addi),
	.subi_po(subi), 
	.load_po(load), 
	.store_po(store),  
	.branch_eq_po(branch_eq),
	.branch_ge_po(branch_ge),
	.branch_le_po(branch_le),
	.branch_carry_po(branch_carry),
	.jump_po(jump),
	.stc_cmd_po(stc_cmd),
	.stb_cmd_po(stb_cmd),
	.halt_cmd_po(halt_cmd),
	.rst_cmd_po(rst_cmd)
); 

regfile reg1(
	.clk_pi(CLK_pi),
	.clk_en_pi(cpu_clk_en & ~halt_cmd),
	.reset_pi(CPU_RESET_pi),
	// Source Register data for 1 and 2 register operations
	.source_reg1_pi(source_reg1),
	.source_reg2_pi(source_reg2),
	// Destination register and write back command/data for operations that write to a register
	.destination_reg_pi(destination_reg),
	.wr_destination_reg_pi(arith_2op | arith_1op | movi_lower | movi_higher | addi | subi | load),
	.dest_result_data_pi(load ? rdata : alu_result),
	// Move immediate commands and data.
	.movi_lower_pi(movi_lower),
	.movi_higher_pi(movi_higher),	
	.immediate_pi(immediate[7:0]),
	.new_carry_pi(carry_out),
	.new_borrow_pi(borrow_out),

	// OUT
	.reg1_data_po(reg1_data),
	.reg2_data_po(reg2_data),
	// Source register data for STORE operations. Indexed on destination_reg input
	.regD_data_po(regD_data),
	.current_carry_po(carry_in),
	.current_borrow_po(borrow_in)
);

program_counter pc1(
	.clk_pi(CLK_pi),
	.clk_en_pi(cpu_clk_en & ~halt_cmd),
	.reset_pi(CPU_RESET_pi),

	.branch_taken_pi(branch_taken),
	.branch_immediate_pi(immediate[5:0]), // Needs to be sign extended		
	.jump_taken_pi(jump),
	.jump_immediate_pi(immediate), // Needs to be sign extended
	// out
	.pc_po(pc)
);

branch branch1(
.branch_eq_pi(branch_eq),
.branch_ge_pi(branch_ge),
.branch_le_pi(branch_le),
.branch_carry_pi(branch_carry),
.reg1_data_pi(reg1_data),
.reg2_data_pi(reg2_data),
.alu_carry_bit_pi(carry_in),
//out
.is_branch_taken_po(branch_taken)
);

data_mem data_mem1(
	//in
	.clk_pi(CLK_pi),
	.clk_en_pi(cpu_clk_en & ~halt_cmd),
	.reset_pi(CPU_RESET_pi),

	.write_pi(store), // write enable
	.wdata_pi(regD_data), // write data
	.addr_pi(reg1_data), // address
	// out
	.rdata_po(rdata) // read data
);
instruction_mem imem(
	// in
	.pc_pi(pc),
	//out
	.instruction_po(instruction)
);

alu alu1(
	.arith_1op_pi(arith_1op),
	.arith_2op_pi(arith_2op),
	.alu_func_pi(alu_func),
	.addi_pi(addi),
	.subi_pi(subi),
	.load_or_store_pi(load | store), 
	.reg1_data_pi(reg1_data),
	.reg2_data_pi(reg2_data),
	.immediate_pi(immediate[5:0]),
	.stc_cmd_pi(stc_cmd),
	.stb_cmd_pi(stb_cmd), 
	.carry_in_pi(carry_in), 
	.borrow_in_pi(borrow_in),  
	// out
	.alu_result_po(alu_result),  
	.carry_out_po(carry_out), 
	.borrow_out_po(borrow_out)
);

   
clkdiv clock_divide(
.clk_pi(CLK_pi),
.clk_en_po(cpu_clk_en)
);


   
endmodule 



/*
 * Module: seconds_clkdiv
 * Description: Generates a clk_en signal.
 * This trivially runs at the same frequency as clk
 * See the module below for a clock that reduces the frequency of a 100 MHz clock to 1 Hz
*/

module clkdiv ( 
	input clk_pi,
	output clk_en_po
);
	
   assign clk_en_po = 1'b1;
endmodule //clkdiv




/* ***************************************************************************************
 * Module: seconds_clkdiv
 * Description: Generates a clk_en signal that triggers once per second from a 100MHz clk input


module seconds_clkdiv (
	input clk_pi,
	output clk_en_po
);
	reg [31:0] counter;

	initial begin
		counter <= 32'h0;
	end
	
	always @(posedge clk_pi) begin
	if(counter == 32'h5F5E100)  
			counter <= 32'h0;
		else
			counter <= counter + 1;
	end
	
	assign clk_en_po = (counter == 32'h0); 
	
endmodule // seconds_clock
 ****************************************************************************************/


