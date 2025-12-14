module Forwarding(
  input  logic  EX_RdWren        ,
  input  logic  MEM_RdWren       , 
  input  logic  WB_RdWren        ,
  input  logic  EX_isload        ,
  input  logic [4:0] MEM_RdAddr  ,
  input  logic [4:0] EX_RdAddr   ,
  input  logic [4:0] EX_Rs1Addr  ,
  input  logic [4:0] EX_Rs2Addr  ,
  input  logic [4:0] WB_RdAddr   ,
  input  logic [1:0] op_sel_a_EX ,
  input  logic [1:0] op_sel_b_EX ,
  input  logic [4:0] ID_rs1addr  ,
  input  logic [4:0] ID_rs2addr  ,
  output logic [1:0] ForwardA    ,
  output logic [1:0] ForwardB    ,
  output logic [1:0] fwd_rs1_brc ,
  output logic [1:0] fwd_rs2_brc ,
  output logic EX_flush          ,
  output logic For_rs1_ID        ,
  output logic For_rs2_ID        ,
  output logic ID_enable         ,
  output logic pc_enable     

);

logic co_load_a;
logic co_load_b;

assign fwd_rs1_brc = (MEM_RdWren & (MEM_RdAddr != 0) & (MEM_RdAddr == EX_Rs1Addr)) ?  2'b10 :
                     (WB_RdWren & (WB_RdAddr != 0) & (WB_RdAddr == EX_Rs1Addr))    ? 2'b01  : 2'b00;

assign fwd_rs2_brc =  (MEM_RdWren & (MEM_RdAddr != 0) & (MEM_RdAddr == EX_Rs2Addr)) ?  2'b10 :
                     (WB_RdWren & (WB_RdAddr != 0) & (WB_RdAddr == EX_Rs2Addr))     ? 2'b01  : 2'b00;

assign For_rs1_ID = (WB_RdWren & (WB_RdAddr != 0) & (WB_RdAddr == ID_rs1addr) ) ? 1 : 0 ;
assign For_rs2_ID = (WB_RdWren & (WB_RdAddr != 0) & (WB_RdAddr == ID_rs2addr) ) ? 1 : 0 ;

assign co_load_a = (EX_RdAddr == ID_rs1addr);
assign co_load_b = (EX_RdAddr == ID_rs2addr); 


assign ForwardA = (MEM_RdWren & (MEM_RdAddr != 0) & (MEM_RdAddr == EX_Rs1Addr) & (op_sel_a_EX == 2'b00)) ? 2'b10 :
                  (WB_RdWren & (WB_RdAddr != 0) & (WB_RdAddr == EX_Rs1Addr) & (op_sel_a_EX == 2'b00))    ? 2'b01  : op_sel_a_EX ;

assign ForwardB = (MEM_RdWren & (MEM_RdAddr != 0) & (MEM_RdAddr == EX_Rs2Addr) & (op_sel_b_EX == 2'b00)) ? 2'b10 :
                  (WB_RdWren & (WB_RdAddr != 0) & (WB_RdAddr == EX_Rs2Addr) & (op_sel_b_EX == 2'b00))    ? 2'b01  : op_sel_b_EX ;

always_comb begin
if (EX_RdWren & (EX_RdAddr != 0) & EX_isload & ( co_load_a | co_load_b)) begin
  EX_flush  = 1;
  pc_enable  = 0;
  ID_enable  = 0;
 end
else begin
 EX_flush  = 0;
 pc_enable  = 1;
 ID_enable  = 1;
 end  
end
endmodule
