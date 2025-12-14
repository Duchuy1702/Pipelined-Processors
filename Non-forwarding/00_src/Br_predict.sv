module br_predict(
input logic [31:0] instr_EX,
input logic i_brc_less     ,
input logic i_brc_equal    ,
output logic en_pc         ,
output logic o_Flush       ,
output logic o_ctrl        ,   // Có lệnh BRANCH và JUMP
output logic o_mispred     ,   // Nhảy PC
output logic o_pc_branch

);

logic Branch , Jump;
logic co_branch;

localparam [2:0] BEQ    = 3'b000 ,
                 BNE    = 3'b001 ,
                 BLT    = 3'b100 ,
                 BGE    = 3'b101 ,
                 BLTU   = 3'b110 ,
                 BGEU   = 3'b111 ;


assign Branch = (instr_EX[6:2] == 5'b11000) ? 1 : 0;
assign Jump   = ((instr_EX[6:2] ==  5'b11011) | (instr_EX[6:2] == 5'b11001)) ? 1: 0;
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

assign o_pc_branch = Jump| (co_branch & Branch) ;
assign o_Flush     = o_pc_branch;
assign o_mispred   = o_pc_branch;
assign en_pc       = o_mispred ? 0 : 1 ;

endmodule
