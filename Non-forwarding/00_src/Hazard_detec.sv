module control_data (
  input  logic  M_RdWren        , 
  input  logic  WB_RdWren       ,
  input  logic  EX_RdWren       ,
  input  logic [4:0] M_RdAddr   ,
  input  logic [4:0] EX_RdAddr  ,
  input  logic [4:0] WB_RdAddr  ,
  input  logic [4:0] ID_rs1addr ,
  input  logic [4:0] ID_rs2addr ,
  input  logic [31:0] instr_ID  ,
  output logic  Flush_EX        ,
  output logic  enable_pc       ,
  output logic  enable_ID

);
logic co_wb_EX , co_wb_M , co_wb_WB , co_exp ;
assign co_exp = ((instr_ID[6 :2] == 5'b00101) | (instr_ID[6 :2] == 5'b01101) | (instr_ID[6 :2] ==5'b11011)) ? 0 : 1 ;

assign co_wb_EX = (EX_RdWren & (EX_RdAddr != 0) & ((EX_RdAddr == ID_rs1addr) | (EX_RdAddr == ID_rs2addr)));

assign co_wb_M  = (M_RdWren & (M_RdAddr != 0) & ((M_RdAddr == ID_rs1addr) | (M_RdAddr == ID_rs2addr)));

assign co_wb_WB = (WB_RdWren & (WB_RdAddr != 0) & ((WB_RdAddr == ID_rs1addr) | (WB_RdAddr == ID_rs2addr)));


assign Flush_EX = (co_wb_EX | co_wb_M  | co_wb_WB) & co_exp;

assign enable_pc = Flush_EX ;

assign enable_ID = Flush_EX ; 

endmodule