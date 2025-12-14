module DFF_EX_M(
  input logic i_clk            ,
  input logic i_rst_n          ,
  input logic [31:0] alu_EX    ,
  input logic [31:0] rs2_EX    ,
  input logic [4:0] EX_Rd_addr ,
  output logic [31:0] alu_M    ,
  output logic [31:0] rs2_M    ,
  output logic [4:0] M_Rd_addr ,
  input logic i_rdwren_EX      ,
  input logic i_insnvld_EX     ,
  input logic i_memwren_EX     ,
  input logic [1:0] i_wbsel_EX ,
  output logic o_rdwren_M      ,
  output logic o_insnvld_M     ,
  output logic o_memwren_M     ,
  output logic [1:0] o_wbsel_M ,
  input logic [31:0] i_instr_EX    ,
  output logic [31:0] o_instr_M    ,
  input logic [31:0] i_pcfour_EX   ,
  output logic [31:0] o_pcfour_M   ,
  input  logic i_ctrl_EX           ,
  input  logic i_mispred_EX        ,
  output logic o_ctrl_M            ,
  output logic o_mispred_M         ,
  input logic [31:0] i_pc_debug_EX ,
  output logic [31:0] o_pc_debug_M

);
  always_ff @(posedge i_clk or negedge i_rst_n) begin
  if(!i_rst_n) begin
  alu_M <= 32'h0;
  rs2_M <= 32'h0;
  M_Rd_addr <= 5'b0;
  o_rdwren_M <= 1'b0;
  o_insnvld_M <= 1'b0;
  o_memwren_M <= 1'b0;
  o_wbsel_M <= 2'b0 ;
  o_instr_M <= 32'b0;
  o_pcfour_M <= 32'b0;
  o_ctrl_M <= 1'b0;
  o_mispred_M <= 1'b0;
  o_pc_debug_M <= 32'h0;
end
  else begin
  alu_M <= alu_EX;
  rs2_M <= rs2_EX;
  M_Rd_addr <= EX_Rd_addr;
  o_rdwren_M <= i_rdwren_EX;
  o_insnvld_M <= i_insnvld_EX;
  o_memwren_M <= i_memwren_EX;
  o_wbsel_M <= i_wbsel_EX ;
  o_instr_M <= i_instr_EX;
  o_pcfour_M <= i_pcfour_EX;
  o_ctrl_M <= i_ctrl_EX;
  o_mispred_M <= i_mispred_EX ;
  o_pc_debug_M <= i_pc_debug_EX;
  end     
end

endmodule
