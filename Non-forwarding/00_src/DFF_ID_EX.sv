module DFF_ID_EX(
  input logic i_clk   ,
  input logic i_rst_n ,
  input logic flush   ,
  input logic flush_fwd ,
  input logic  [31:0] rs1_ID    ,
  input logic  [31:0] rs2_ID    ,
  input logic  [31:0] immgen_ID ,
  input logic  [4:0] ID_Rs1_addr,
  input logic  [4:0] ID_Rs2_addr,
  input logic  [4:0] ID_Rd_addr ,
  output logic [31:0] rs1_EX    ,
  output logic [31:0] rs2_EX    ,
  output logic [31:0] immgen_EX ,
  output logic [4:0] EX_Rs1_addr,
  output logic [4:0] EX_Rs2_addr,
  output logic [4:0] EX_Rd_addr ,
  input logic  [31:0] i_instr_ID ,
  input logic  i_lui_ID          ,
  input logic  i_rdwren_ID       ,
  input logic  i_insnvld_ID      ,
  input logic  i_br_un_ID        ,
  input logic  i_opa_ID          ,
  input logic  i_opb_ID          ,
  input logic  i_memwren_ID      ,
  input logic  [1:0] i_wbsel_ID  ,
  input logic  [3:0] i_alu_op_ID ,
  output logic [31:0] o_instr_EX ,
  output logic  o_lui_EX         ,
  output logic  o_rdwren_EX      ,
  output logic  o_insnvld_EX     ,
  output logic  o_br_un_EX       ,
  output logic  o_opa_EX         ,
  output logic  o_opb_EX         ,
  output logic  o_memwren_EX     ,
  output logic  [1:0] o_wbsel_EX ,
  output logic  [3:0] o_alu_op_EX  ,  
  input logic  [31:0] i_pc_debug_ID,
  output logic [31:0] o_pc_debug_EX,
  input logic i_isload_ID          ,
  output logic o_isload_EX         ,
  input logic [31:0] i_pcfour_ID   , 
  output logic [31:0] o_pcfour_EX  
  
);
  always_ff @(posedge i_clk or negedge i_rst_n) begin
  if(!i_rst_n) begin
    rs1_EX       <= 32'b0;
    rs2_EX       <= 32'b0;
    immgen_EX    <= 32'b0;
    EX_Rs1_addr  <= 5'b0 ;
    EX_Rs2_addr  <= 5'b0 ;
    EX_Rd_addr   <= 5'b0 ;
    o_instr_EX   <= 32'b0;
    o_lui_EX     <= 1'b0 ;
    o_rdwren_EX  <= 1'b0 ;
    o_insnvld_EX <= 1'b0 ;
    o_br_un_EX   <= 1'b0 ;
    o_opa_EX     <= 1'b0 ;
    o_opb_EX     <= 1'b0 ;
    o_memwren_EX <= 1'b0 ;
    o_wbsel_EX   <= 2'b0 ;
    o_alu_op_EX  <= 4'b0 ;
    o_pc_debug_EX <= 32'h0;
    o_isload_EX  <= 1'b0 ;
    o_pcfour_EX  <= 32'b0;

  end
  else if (flush) begin
    rs1_EX       <= 32'b0;
    rs2_EX       <= 32'b0;
    immgen_EX    <= 32'b0;
    EX_Rs1_addr  <= 5'b0 ;
    EX_Rs2_addr  <= 5'b0 ;
    EX_Rd_addr   <= 5'b0 ;
    o_instr_EX   <= 32'b0;
    o_lui_EX     <= 1'b0 ;
    o_rdwren_EX  <= 1'b0 ;
    o_insnvld_EX <= 1'b0 ;
    o_br_un_EX   <= 1'b0 ;
    o_opa_EX     <= 1'b0 ;
    o_opb_EX     <= 1'b0 ;
    o_memwren_EX <= 1'b0 ;
    o_wbsel_EX   <= 2'b0 ;
    o_alu_op_EX  <= 4'b0 ; 
    o_pc_debug_EX <= 32'h0;
    o_isload_EX  <= 1'b0;
    o_pcfour_EX  <= 32'b0;

  end 
  else if (flush_fwd) begin
    rs1_EX       <= 32'b0;
    rs2_EX       <= 32'b0;
    immgen_EX    <= 32'b0;
    EX_Rs1_addr  <= 5'b0 ;
    EX_Rs2_addr  <= 5'b0 ;
    EX_Rd_addr   <= 5'b0 ;
    o_instr_EX   <= 32'b0;
    o_lui_EX     <= 1'b0 ;
    o_rdwren_EX  <= 1'b0 ;
    o_insnvld_EX <= 1'b0 ;
    o_br_un_EX   <= 1'b0 ;
    o_opa_EX     <= 1'b0 ;
    o_opb_EX     <= 1'b0 ;
    o_memwren_EX <= 1'b0 ;
    o_wbsel_EX   <= 2'b0 ;
    o_alu_op_EX  <= 4'b0 ; 
    o_pc_debug_EX <= 32'h0;
    o_isload_EX  <= 1'b0;
    o_pcfour_EX  <= 32'b0;

  end 
  else begin
    rs1_EX    <= rs1_ID;  
    rs2_EX    <= rs2_ID;
    immgen_EX <= immgen_ID;
    EX_Rs1_addr <= ID_Rs1_addr;
    EX_Rs2_addr <= ID_Rs2_addr;
    EX_Rd_addr  <= ID_Rd_addr ;
    o_instr_EX  <= i_instr_ID ;
    o_lui_EX    <= i_lui_ID   ;
    o_rdwren_EX <= i_rdwren_ID;
    o_insnvld_EX <= i_insnvld_ID;
    o_br_un_EX   <= i_br_un_ID  ;
    o_opa_EX     <= i_opa_ID    ;
    o_opb_EX     <= i_opb_ID    ;
    o_memwren_EX <= i_memwren_ID;
    o_wbsel_EX   <= i_wbsel_ID  ;
    o_alu_op_EX  <= i_alu_op_ID ;
    o_pc_debug_EX <= i_pc_debug_ID ;
    o_isload_EX  <= i_isload_ID ;
    o_pcfour_EX  <= i_pcfour_ID;

  end
  end

endmodule
