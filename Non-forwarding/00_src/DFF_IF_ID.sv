module DFF_IF_ID(
  input logic i_clk,
  input logic i_rst_n,
  input logic flush,
  input logic enable,
  input logic  [31:0] instr_IF,
  output logic [31:0] instr_ID,
  input logic  [31:0] i_pcfour_IF,
  output logic [31:0] o_pcfour_ID,
  input logic  [31:0] i_pc_debug_IF,
  output logic [31:0] o_pc_debug_ID
   
);
  always_ff @(posedge i_clk or negedge i_rst_n) begin
  if(!i_rst_n) begin
   instr_ID <= 32'b0 ;
   o_pc_debug_ID <= 32'b0 ;
   o_pcfour_ID <= 32'b0; 
  end
  else if (flush) begin
     instr_ID <= 32'b0 ;
     o_pc_debug_ID <= 32'b0 ;
     o_pcfour_ID <= 32'b0 ;
  end
  else if (enable) begin
     instr_ID <= instr_ID ;
     o_pc_debug_ID <= o_pc_debug_ID ;
     o_pcfour_ID <= o_pcfour_ID ;
  end

  else begin
    instr_ID <= instr_IF;
    o_pc_debug_ID <= i_pc_debug_IF ;
    o_pcfour_ID <= i_pcfour_IF ;
  end  
end

endmodule