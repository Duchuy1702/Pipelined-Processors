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
output logic [31:0] out_pc       ,
output logic o_Flush             ,
output logic o_ctrl              ,   
output logic o_mispred           ,   
output logic [1:0] pc_sel_tmp    
);

logic Branch , Jump , valid ;
logic co_branch , mispred_1, mispred_2 , mispred_3  ;
logic [13:0] pc_target; 
logic o_pc_branch , valid_data, taken  ;
logic [1:0] state, next_state ;
logic [10:0] index_IF , index_EX;
logic [10:0] tag_IF ,tag_EX , GHR;
logic br_pre  ; 

logic [27:0] BTB [0:2047];

localparam [2:0] BEQ    = 3'b000 ,
                 BNE    = 3'b001 ,
                 BLT    = 3'b100 ,
                 BGE    = 3'b101 ,
                 BLTU   = 3'b110 ,
                 BGEU   = 3'b111 ;

// đọc ra để tính lại next state ,valid khi có lệnh nhảy ở EX
assign state   =  BTB[index_EX][27:26]   ;
assign taken   =  (Jump | (co_branch & Branch)) ? 1 : 0; // Jump nhảy or branch và điều kiện đúng thì nhảy

// index cho các PC xor GHR
assign index_IF = i_pc_now[12:2] ^ GHR;
assign index_EX = pc_debug_EX[12:2] ^ GHR; 
//tag cho PC ở stage IF và tag cho stage EX
assign tag_IF = i_pc_now[12:2];
assign tag_EX = pc_debug_EX[12:2];
//Xử lý cho Global History Register
 assign br_pre = Jump | Branch ; // Cập nhât GHR mỗi khi có lệnh nhảy

two_bit_predictor dut0 ( .taken (taken),.state (state),.next_state (next_state),.valid_data (valid_data));
GHR dut1 (.i_clk(i_clk),.i_rst_n(i_rst_n),.predict_taken(taken),.branch_pre(br_pre),.GHR(GHR));

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
// Nếu có nhảy hoặc không nhảy thì cập nhật 2 bit dự đoán và pc_target
assign o_pc_branch = Jump | (co_branch & Branch) | (!co_branch & Branch) ;

always_ff @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
     for(int i = 0; i <= 2047; i = i + 1) begin
        BTB[i] <= 17'b0;
      end
    end
    else if (o_pc_branch) begin   // Cập nhật vào BHT và BTB
        BTB[index_EX] <= {next_state ,valid_data, tag_EX, i_alu_ex[15:2]};  
    end
    else BTB[index_EX] <= BTB[index_EX];
end

// đọc từ BTB ra cho việc dự đoán nhảy cho PC có lệnh nhảy ở stage IF
assign pc_target = BTB [index_IF][13:0]  ; 
assign pc_tag    = BTB [index_IF][24:14] ;
assign valid     = BTB [index_IF][25]    ;
assign out_pc = {16'h0 ,pc_target , 2'b0};

//=============================================
assign o_Flush     = o_mispred                                          ;
assign mispred_1   = Jump  & ( pc_debug_ID != i_alu_ex )                ;
assign mispred_2   = Branch & co_branch & ( pc_debug_ID != i_alu_ex )   ;
assign mispred_3   = Branch & !co_branch & ( pc_debug_ID != pc_four_EX );

assign o_mispred = mispred_1 | mispred_2 | mispred_3 ;

assign pc_sel_tmp = (mispred_1 | mispred_2 )        ? 2'b01 : 
                     mispred_3                      ? 2'b10 :
                     valid &  (i_pc_now == pc_tag ) ? 2'b11 :
                                                  pc_sel_ID ;


endmodule
