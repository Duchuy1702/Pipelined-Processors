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

logic Branch , Jump , valid1, valid2, valid3, valid4  ;
logic co_branch , mispred_1, mispred_2 , mispred_3  ;
logic [13:0] pc_target1 , pc_target2 , pc_target3, pc_target4 ; 
logic o_pc_branch1 ,o_pc_branch2 , valid_data, taken  ;
logic [1:0] state1, next_state1, state2, next_state2, state3, next_state3, state4, next_state4 ;
logic [10:0] index_IF_base , index_EX_base;
logic [10:0] index_IF_4bit , index_EX_4bit;
logic [10:0] index_IF_8bit , index_EX_8bit;
logic [10:0] index_IF_14bit , index_EX_14bit;
logic [10:0] tag_IF ,tag_EX ;
logic [31:0] GHR;
logic br_pre , co_take;
logic [10:0] pc_tag4, pc_tag3, pc_tag2 ; 
logic [11:0] fold4 ;
logic [15:0] fold8 ;
logic [10:0] fold14;

logic [16:0] BTB  [0:2047] ; // bảng dự đoán lịch sử nhảy base 
logic [27:0] BTB4 [0:2047] ; // bảng dự đoán lịch sử nhảy 4bit 
logic [27:0] BTB8 [0:2047] ; // bảng dự đoán lịch sử nhảy 8bit
logic [27:0] BTB14[0:2047] ; // bảng dự đoán lịch sử nhảy 14bit 

localparam [2:0] BEQ    = 3'b000 ,
                 BNE    = 3'b001 ,
                 BLT    = 3'b100 ,
                 BGE    = 3'b101 ,
                 BLTU   = 3'b110 ,
                 BGEU   = 3'b111 ;

// đọc ra để tính lại next state ,valid khi có lệnh nhảy ở EX
assign state1   =  BTB  [index_EX_base][16:15]   ;
assign state2   =  BTB4 [index_EX_4bit][27:26]   ;
assign state3   =  BTB8 [index_EX_8bit][27:26]   ;
assign state4   =  BTB14[index_EX_14bit][27:26]  ;
assign taken    =  (Jump | (co_branch & Branch)) ; // Jump nhảy or branch và điều kiện đúng thì nhảy

// Table base

assign index_IF_base = i_pc_now[12:2]    ;
assign index_EX_base = pc_debug_EX[12:2] ; 

// Table 4 bit
// index cho các PC xor fold4
assign fold4 = {3{GHR[3:0]}};
assign index_IF_4bit = i_pc_now[12:2]    ^ fold4[10:0] ;
assign index_EX_4bit = pc_debug_EX[12:2] ^ fold4[10:0] ;

// Table 8 bit
assign fold8 = {2{GHR[7:0]}};
assign index_IF_8bit = i_pc_now[12:2]    ^ fold8[10:0] ;
assign index_EX_8bit = pc_debug_EX[12:2] ^ fold8[10:0] ;

// Table 14 bit
assign fold14 = GHR[10:0] ^ GHR[13:3] ;
assign index_IF_14bit = i_pc_now[12:2]    ^ fold14[10:0] ;
assign index_EX_14bit = pc_debug_EX[12:2] ^ fold14[10:0] ;
 
//tag cho PC ở stage IF và tag cho stage EX
assign tag_IF = i_pc_now[12:2];
assign tag_EX = pc_debug_EX[12:2];

//Xử lý cho Global History Register
 assign br_pre = Jump | Branch ; // Cập nhât GHR mỗi khi có lệnh nhảy

two_bit_predictor dut1 ( .taken (taken),.state (state1),.next_state (next_state1),.valid_data (valid_data1));
two_bit_predictor dut2 ( .taken (taken),.state (state2),.next_state (next_state2),.valid_data (valid_data2));
two_bit_predictor dut3 ( .taken (taken),.state (state3),.next_state (next_state3),.valid_data (valid_data3));
two_bit_predictor dut4 ( .taken (taken),.state (state4),.next_state (next_state4),.valid_data (valid_data4));

GHR dut0 (.i_clk(i_clk),.i_rst_n(i_rst_n),.predict_taken(taken),.branch_pre(br_pre),.GHR(GHR));

assign Branch = (instr_EX[6:2] == 5'b11000) ;
assign Jump   = ((instr_EX[6:2] ==  5'b11011) | (instr_EX[6:2] == 5'b11001));
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
// Nếu có nhảy thì cập nhật 2 bit dự đoán và pc_target
assign o_pc_branch1 = Jump | (co_branch & Branch) ;  
// Nếu không nhảy thì chỉ cập nhật 2 bit dự đoán   
assign o_pc_branch2 = !co_branch & Branch         ;

always_ff @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
     for(int i = 0; i <= 2047; i = i + 1) begin
        BTB[i]   <= 17'b0;
        BTB4[i]  <= 28'b0;
        BTB8[i]  <= 28'b0;
        BTB14[i] <= 28'b0;
      end
    end
    else if (o_pc_branch1) begin   // Cập nhật vào BHT và BTB
        BTB  [index_EX_base ] <= {next_state1 ,valid_data1, i_alu_ex[15:2]}; 
        BTB4 [index_EX_4bit ] <= {next_state2 ,valid_data2, tag_EX, i_alu_ex[15:2]};
        BTB8 [index_EX_8bit ] <= {next_state3 ,valid_data3, tag_EX, i_alu_ex[15:2]};
        BTB14[index_EX_14bit] <= {next_state4 ,valid_data4, tag_EX, i_alu_ex[15:2]}; 
    end
    else if (o_pc_branch2)begin 
        BTB  [index_EX_base ] <= {next_state1 ,valid_data1, BTB[index_EX_base][13:0]}; 
        BTB4 [index_EX_4bit ] <= {next_state2 ,valid_data2, tag_EX, BTB4[index_EX_4bit][13:0]} ;
        BTB8 [index_EX_8bit ] <= {next_state3 ,valid_data3, tag_EX, BTB8[index_EX_8bit][13:0]} ;
        BTB14[index_EX_14bit] <= {next_state4 ,valid_data4, tag_EX, BTB14[index_EX_14bit][13:0]}; 
    end   
    else BTB[index_EX_base] <= BTB[index_EX_base] ;
end

// đọc từ BTB ra cho việc dự đoán nhảy cho PC có lệnh nhảy ở stage IF từ mô hình 14bit đến base
assign pc_target1 = BTB [index_IF_base][13:0]   ; 
assign valid1     = BTB [index_IF_base][14]     ;
//================================================================================
assign pc_target2 = BTB4 [index_IF_4bit][13:0]  ; 
assign pc_tag2    = BTB4 [index_IF_4bit][24:14] ;
assign valid2     = BTB4 [index_IF_4bit][25]    ;
//================================================================================
assign pc_target3 = BTB8 [index_IF_8bit][13:0]  ; 
assign pc_tag3    = BTB8 [index_IF_8bit][24:14] ;
assign valid3     = BTB8 [index_IF_8bit][25]    ;
//================================================================================
assign pc_target4 = BTB14 [index_IF_14bit][13:0]  ; 
assign pc_tag4    = BTB14 [index_IF_14bit][24:14] ;
assign valid4     = BTB14 [index_IF_14bit][25]    ;
//================================================================================
assign out_pc = (valid4 & (pc_tag4 == tag_IF)) ?  {16'h0 ,pc_target4 , 2'b0} :
                (valid3 & (pc_tag3 == tag_IF)) ?  {16'h0 ,pc_target3 , 2'b0} :
                (valid2 & (pc_tag2 == tag_IF)) ?  {16'h0 ,pc_target2 , 2'b0} :
                valid1                         ?  {16'h0 ,pc_target1 , 2'b0} :
                                                     32'h0                   ;
//================================================================================
assign co_take = (valid4 & (pc_tag4 == tag_IF)) | (valid3 & (pc_tag3 == tag_IF)) | (valid2 & (pc_tag2 == tag_IF )) | valid1 ;
//================================================================================
assign o_Flush     = o_mispred                                          ;
assign mispred_1   = Jump  & ( pc_debug_ID != i_alu_ex )                ;
assign mispred_2   = Branch & co_branch & ( pc_debug_ID != i_alu_ex )   ;
assign mispred_3   = Branch & !co_branch & ( pc_debug_ID != pc_four_EX );

assign o_mispred = mispred_1 | mispred_2 | mispred_3 ;

assign pc_sel_tmp = (mispred_1 | mispred_2 )        ? 2'b01 : 
                     mispred_3                      ? 2'b10 :
                     co_take                        ? 2'b11 :
                                                  pc_sel_ID ;


endmodule
