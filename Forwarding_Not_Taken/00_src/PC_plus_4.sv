module PC_plus_4(
input logic [31:0] i_pc,
output logic [31:0] o_pc_next
);

logic [31:0] nxt;
logic c1;
adder_32bit dut  (i_pc,32'h4,nxt ,c1);

assign o_pc_next = nxt;

endmodule 
