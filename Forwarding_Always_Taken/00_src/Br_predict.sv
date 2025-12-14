module br_predict(
input  logic i_clk               ,
input  logic i_rst_n             ,     
input  logic [31:0] instr_EX     ,
input  logic [31:0] pc_four_ID   ,
input  logic [31:0] i_alu_ex     ,
input  logic i_brc_less          ,
input  logic [31:0] pc_debug_EX  ,
input  logic [31:0] pc_four_EX   ,
input  logic i_brc_equal         ,
input  logic [31:0] i_pc_now     ,
input  logic  pc_sel_ID          ,
input  logic [31:0] pc_debug_ID  ,
output logic o_Flush             ,
output logic o_ctrl              ,   
output logic o_mispred           ,   
output logic [1:0] pc_sel_tmp    
);

logic Branch , Jump , Jalr , valid ;
logic co_branch , mispred_1, mispred_2 , mispred_3  ;

localparam [2:0] BEQ    = 3'b000 ,
                 BNE    = 3'b001 ,
                 BLT    = 3'b100 ,
                 BGE    = 3'b101 ,
                 BLTU   = 3'b110 ,
                 BGEU   = 3'b111 ;


assign Branch = (instr_EX[6:2] == 5'b11000) ;
assign Jump   = ((instr_EX[6:2] ==  5'b11011) | (instr_EX[6:2] == 5'b11001));
assign Jalr   = (instr_EX[6:2] == 5'b11001) ;
assign o_ctrl = Jump | Branch;

always_comb begin
case(instr_EX[14:12])
    BEQ  : begin 
    co_branch = i_brc_equal;
    end
    BNE  : begin                        
    co_branch = ~i_brc_equal;
    end
    BLT  : begin 
    co_branch = i_brc_less ;
    end
    BGE  : begin 
    co_branch = ~i_brc_less ;
    end
    BLTU : begin 
    co_branch = i_brc_less ;
    end
    BGEU : begin 
    co_branch = ~i_brc_less ;
    end
    default: begin
    co_branch = 1'b0 ;
    end
endcase
end

assign o_Flush     = o_mispred                                          ;
assign mispred_1   = Jalr  & ( pc_debug_ID != i_alu_ex )                ;
assign mispred_2   = Branch & co_branch & ( pc_debug_ID != i_alu_ex )   ;
assign mispred_3   = Branch & !co_branch & ( pc_debug_ID != pc_four_EX );

assign o_mispred = mispred_1 | mispred_2 | mispred_3 ;

assign pc_sel_tmp = (mispred_1 | mispred_2 ) ? 2'b01 : 
                     mispred_3               ? 2'b10 :
                                           pc_sel_ID ;


endmodule
