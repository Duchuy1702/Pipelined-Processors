module pc_IF(
  input logic  i_clk           ,
  input logic  i_rst_n         , 
  input logic  pc_enable       ,
  input logic  [31:0] i_pc_next,
  output logic [31:0] o_pc
);
    logic [31:0] present_pc ;

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if      (!i_rst_n ) present_pc <= 32'b0 ;
    else if (!pc_enable) present_pc <=  present_pc   ;
    else    present_pc <= i_pc_next ;
  end
  
  assign o_pc = present_pc ;
  
endmodule 
