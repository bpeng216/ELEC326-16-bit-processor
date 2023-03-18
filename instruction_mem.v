`timescale 1ns / 1ps

 /**
 * Module: instruction_mem
 * 
 * The instruction memory model for the processor.
 * 
 */

module instruction_mem(
	input [15:0] pc_pi,
	output[15:0] instruction_po
      );

   reg [15:0] 		  instruction;

   assign instruction_po = instruction;

   
   always @(pc_pi) begin  
   case(pc_pi)	     


// Comment out this code for Fibonacci      			


// TEST 1 PROGRAM (Array Sum) FOR STEP 3 (arraysum.asm)

      0: instruction = 16'b0011000000000100;        //           MOVIL $0, 4
      2: instruction = 16'b0011001000000000;       //            MOVIL   $1, 0
      4: instruction = 16'b0011010001000000;       //            MOVIL   $2, 0x40
      6: instruction = 16'b0100001001000001;       // LOOP1:     ADDI $1, $1, 1
      8: instruction = 16'b0111001010000000;       //            ST   $1, 0($2)
     10: instruction = 16'b0100010010000010;      //            ADDI $2, $2, 2
     12: instruction = 16'b1010001000111000;      //            BLE  $1, $0, LOOP1
     14: instruction = 16'b0011001000000000;      //            MOVIL   $1, 0
     16: instruction = 16'b0011100000000000;      //            MOVIL   $4, 0
     18: instruction = 16'b0011010001000000;       //            MOVIL   $2, 0x40
     20: instruction = 16'b0110011010000000;      // LOOP2:     LD $3, 0($2)
     22: instruction = 16'b0001100100011000;      //            ADD  $4, $4, $3
     24: instruction = 16'b0100010010000010;      //            ADDI $2, $2, 2
     26: instruction = 16'b0100001001000001;      //            ADDI $1, $1, 1
     28: instruction = 16'b1010001000110110;      //            BLE  $1, $0, LOOP2
     30: instruction = 16'b1111111111111111;      //            HALT

 
// Uncomment this code for Fibonacci

			
// TEST 2 PROGRAM (Fib) for Step 3 (fib.asm)
/*
     0: instruction = 16'b0011100000000000;    //          MOVIL   $4, 0 
     2: instruction = 16'b0011011000000001;    //          MOVIL   $3, 1
     4: instruction = 16'b0001010011100000;    //  FIB:    ADD $2 $3 $4
     6: instruction = 16'b1011000000000110;    //	   BC END
     8: instruction = 16'b0010100011000011;    //          CP $4 $3
     10: instruction = 16'b0010011010000011;   //          CP $3 $2
     12: instruction = 16'b1000000000110110;   //          BEQ $0, $0, FIB
     14: instruction = 16'b1111111111111111;   //  END:    HALT
*/
 
    default: instruction = 16'h0;
   endcase
      
   end

always @(pc_pi)  begin
 


  #5;      $display("\nINS_MEM:\tTime:%3d\tPC: %2d\tInstruction: %x", $time, pc_pi, instruction_po);


end
   
endmodule
