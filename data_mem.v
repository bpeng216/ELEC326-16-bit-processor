`timescale 1ns / 1ps

/**
 * Module: data_mem
 * 
 * The simplified data memory model for the processor.
 */
module data_mem(
	input 		  clk_pi, // 100 MHz clk
	input 		  clk_en_pi, // Clock enable
	input 		  reset_pi, // synchronous reset
	
	input 		  write_pi, // write enable
	input [15:0] 	  wdata_pi, // write data
	input [15:0] 	  addr_pi, // address
	
	output reg [15:0] rdata_po // read data
);
	

   reg [7:0] 		  DATA_MEM[0 : 255]; // 256 byte memory


   	always @(*) begin
	   rdata_po =  {DATA_MEM[addr_pi[7:0]], DATA_MEM[addr_pi[7:0]+1]};
	end	   
	
   integer i;
   
	always @(posedge clk_pi) begin
		//$display("Mem Address: %d\n", addr_pi);	
		if (reset_pi) begin
	// Initialize all bytes of DATA_MEM to hex value  FA
		   for (i=0; i < 128; i = i+2) begin
		      DATA_MEM[i] = {8'hFA, 8'hFA};
			  
		   end
		end 
		
		else if (write_pi && clk_en_pi) begin
					
		   {DATA_MEM[addr_pi[7:0]], DATA_MEM[addr_pi[7:0]+1]} <= wdata_pi;
		   $display("Time: %3d Store Data: %d Mem Address: %d\n", $time, wdata_pi, addr_pi);
		end
	end
endmodule
