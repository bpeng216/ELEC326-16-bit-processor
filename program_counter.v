/*
 * Module: program_counter
 * Description: Program counter.
 *              Synchronously reset program counter to 0 when reset and clk_en are asserted at a positivr clock edge.
 *              By default: increments program counter by instruction size (2 bytes) every cycle unless halted.
 *              If a taken branch or jump is asserted change program counter to the target address instead 
 *                                                    Target Address is PC + 2 + Sign-extended immediate value 
 *              Return the updated PC value in the output port signal pc_po.
 * 
 */

module program_counter (
		input 	      clk_pi,
		input 	      clk_en_pi,
		input 	      reset_pi,
		
		input 	      branch_taken_pi,
		input [5:0]   branch_immediate_pi, // Needs to be sign extended		
		input 	      jump_taken_pi,
		input [11:0]  jump_immediate_pi, // Needs to be sign extended
			
		output [15:0] pc_po
		);

   reg [15:0] 		      PC;  // Program Counter   
   
       initial
	PC <= 16'hFFFF;  // Do not remove. Assumed by the Testbench and results files.

	always @(posedge clk_pi) begin
		if (~reset_pi) begin
			if (clk_en_pi) begin
				PC = PC + 2'b10;
			
				if (branch_taken_pi)
					PC = PC + {{10{branch_immediate_pi[5]}}, branch_immediate_pi};
				if (jump_taken_pi)
					PC = PC + {{4{jump_immediate_pi[11]}}, jump_immediate_pi};

			end
		end else begin
			PC <= 16'h0000;
		end
	end
	assign pc_po = PC;
   

endmodule



