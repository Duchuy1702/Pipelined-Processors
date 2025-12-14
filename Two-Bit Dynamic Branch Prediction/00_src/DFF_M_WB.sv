module DFF_M_WB(
  input logic i_clk               ,
  input logic i_rst_n             ,
  input logic  [31:0] pc_four_M   ,
  input logic  [31:0] alu_M       ,
  input logic  [4:0]  M_Rd_addr   ,
  output logic [31:0] pc_four_WB  ,
  output logic [31:0] alu_WB      ,
  output logic [4:0]  WB_Rd_addr  ,
  input logic i_rdwren_M          ,  
  input logic i_insnvld_M         ,
  input logic [1:0] i_wbsel_M     ,
  output logic o_rdwren_WB        ,
  output logic o_insnvld_WB       ,
  output logic [1:0] o_wbsel_WB   ,
  input  logic ctrl_M             ,
  input  logic mispred_M          ,
  output logic ctrl_WB            ,
  output logic mispred_WB         ,
  input logic [31:0] i_pc_debug_M ,
  output logic [31:0]o_pc_debug_WB 

);
  always_ff @(posedge i_clk or negedge i_rst_n) begin
  if(!i_rst_n) begin 
    pc_four_WB <= 32'h0;
    alu_WB     <= 32'h0;
    WB_Rd_addr <= 5'b0;
    o_rdwren_WB  <= 1'b0;
    o_insnvld_WB <= 1'b0;
    o_wbsel_WB   <= 2'b0;
    ctrl_WB    <= 1'b0;
    mispred_WB <= 1'b0;
    o_pc_debug_WB <= 32'h0;

  end
  else begin
    pc_four_WB   <= pc_four_M;
    alu_WB       <= alu_M;
    WB_Rd_addr   <= M_Rd_addr;
    o_rdwren_WB  <= i_rdwren_M;
    o_insnvld_WB <= i_insnvld_M;
    o_wbsel_WB   <= i_wbsel_M;
    ctrl_WB      <= ctrl_M;
    mispred_WB   <= mispred_M;
    o_pc_debug_WB <= i_pc_debug_M;
    
  end
end

endmodule