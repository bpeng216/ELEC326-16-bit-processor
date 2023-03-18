`timescale 1ns/1ns

module regfile (
		 input 	       clk_pi,
		 input 	       clk_en_pi,
		 input 	       reset_pi,
		 
		 // Source Register data for 1 and 2 register operations
		 input [2:0]   source_reg1_pi,
		 input [2:0]   source_reg2_pi,
		 
		 // Destination register and write back command/data for operations that write to a register
		 input [2:0]   destination_reg_pi,
		 input 	   wr_destination_reg_pi,
		 input [15:0]  dest_result_data_pi,
		 		 
		 // Move immediate commands and data.
		 input 	       movi_lower_pi,
		 input 	       movi_higher_pi,
		 input [7:0]       immediate_pi,

		 input 	       new_carry_pi,
		 input 	       new_borrow_pi, 

		 output [15:0] reg1_data_po,
		 output [15:0] reg2_data_po,

		 // Source register data for STORE operations. Indexed on destination_reg input
		 output [15:0]  regD_data_po, 
		 output        current_carry_po,
		 output        current_borrow_po
	 );

parameter NUM_REG = 8;

//  Define the register file "REG_FILE" of "NUM_REG" registers. Each register is 16-bits wide  and type "reg".
//  Define a 1 bit "reg" variable CARRY_FLAG and a 1-bit "reg" variable BORROW_FLAG.
//  (Since these are variables that are internal to your module you could give them any names you like.)
   
//   The REG_FILE will implement the 8 registers $0 through $7 of your processor.
//   The CARRY_FLAG and BORROW_FLAG are used to save the carry_out and borrow_out signals output from the ALU, and provide
//   the current carry_in and borrow_in values to the ALU.
   
	reg CARRY_FLAG; 
	reg BORROW_FLAG;
	reg [15:0] REG_FILE[NUM_REG-1:0];

   	integer i;  // Used in "for" loop (see below)
    

   	// Use "assign" statements to set the output port variables of this  (i.e."regfile") module.
   	// For convenience, all output port variables have the suffix "_po" and input port variables the suffix "_pi".
      	   // You will appreciae this when you integrate modules in Project 3. Develop it as a discipline while coding.
	
	assign reg1_data_po = REG_FILE[source_reg1_pi];
	assign reg2_data_po = REG_FILE[source_reg2_pi];
	assign regD_data_po = REG_FILE[destination_reg_pi];
	assign current_carry_po = CARRY_FLAG;
	assign current_borrow_po = BORROW_FLAG;

   
   // Code up the logic for updating the components of  regfile using an "always" block triggered by the positive edge 
   // of the clock signal "clock_pi"
   
   /* Reset Code */
   
   // The "reset_pi" signal should act as a synchronous reset to initialize the carry and borrow flags to 0, and to
   // initialize the registers of the register file as described below.

   // You must initialize register $i to the value "i". 
   // That is, register $0 is initialized to 0, register $1 to value 1, and so on.
   // In an actual processor, the hardware reset signal would usually initialize all registers to the value 0. 
   // By setting it to some other known number, we can run tests with non-zero initial values for the registers.
   
   // Since this module is parameterized use a "for" loop with the loop index variable "i". There is no need for any
   // "generate" or "end generate" statements.


   
   /* Main Code */ 

   // All updates to the storage elements will occur only at the positive edge of the clk signal.
   
   // The carry and borrow flags must be updated when the reset signal is de-asserted  and the 
   // "clk_en_pi" input is TRUE.
   
   // If "clk_en_pi" is TRUE and the write enable signal ("wr_destination_reg_pi") is asserted,
   // the specified register in the register file must be updated with the input data.
   	always @(posedge clk_pi) begin
		if (reset_pi) begin 
			for (i = 0; i < NUM_REG; i = i+1) begin
				REG_FILE[i] <= 0;
			end
			CARRY_FLAG <= 1'b0;
			BORROW_FLAG <= 1'b0;
		end else begin
			if (clk_en_pi) begin
			CARRY_FLAG <= new_carry_pi;
			BORROW_FLAG <= new_borrow_pi;
			
			if (wr_destination_reg_pi) begin
				REG_FILE[destination_reg_pi] <= dest_result_data_pi;
				if (movi_higher_pi) REG_FILE[destination_reg_pi][15:8] <= immediate_pi;
				if (movi_lower_pi) REG_FILE[destination_reg_pi][7:0] <= immediate_pi;
			end
	
			end
		end
	end



always @(posedge clk_pi) begin
   #1;
   $display("REG_FILE::\tTime: %3d+\tCARRY Flag: %1b\tBORROW Flag: %1b", $time-1, CARRY_FLAG, BORROW_FLAG);

	//$display("REG_FILE[regD]: %x", regD_data_po);
   for (i=0; i < NUM_REG; i = i+1)
     $display("REG_FILE[%1d]: %x", i, REG_FILE[i]);
end

  	


endmodule


  
