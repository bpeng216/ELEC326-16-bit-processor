`timescale 1ns/1ns

module branch (
input        branch_eq_pi,
input        branch_ge_pi,
input        branch_le_pi,
input        branch_carry_pi,
input [15:0] reg1_data_pi,
input [15:0] reg2_data_pi,
input        alu_carry_bit_pi,

output  is_branch_taken_po)
;

wire int1, int2, int3;


assign int1 = branch_eq_pi ? (reg1_data_pi == reg2_data_pi) : (reg1_data_pi >= reg2_data_pi);
assign int2 = branch_le_pi ? (reg1_data_pi <= reg2_data_pi) : (alu_carry_bit_pi);
assign int3 = (branch_eq_pi | branch_ge_pi) ? int1 : int2;
assign is_branch_taken_po = (branch_eq_pi | branch_ge_pi | branch_le_pi | branch_carry_pi) ? int3 : 1'b0;

endmodule // branch_comparator
