module control_ID(
    input  logic [31:0] i_instr     , // input of instr_ID
    output logic        o_lui_sel   , // ID-EX
    output logic        o_pc_sel    , // ID-IF
    output logic        o_rd_wren   , // ID-EX-M_WB
    output logic        o_insn_vld  , // ID-EX-M_WB
    output logic        o_br_un     , // ID-EX
    output logic        o_opa_sel   , // ID-EX
    output logic        o_opb_sel   , // ID-EX
    output logic        o_mem_wren  , // ID-EX-M
    output logic [1:0]  o_wb_sel    , // ID-EX-M_WB
    output logic [3:0]  o_alu_op    , // ID_EX
    output logic        o_isload    
    
);

// Opcode
localparam [4:0] R_type   = 5'b01100,  // Phép toán
                 I_type   = 5'b00100,  // Phép toán 
                 S_type   = 5'b01000,  //Store
                 L_type   = 5'b00000,  //Load
                 SB_type  = 5'b11000,  //Branch
                 UL_type  = 5'b01101,  //LUI
                 UA_type  = 5'b00101,  //AUIPC
                 UJ_type  = 5'b11011,  //JAL
                 IJ_type  = 5'b11001;  //JALR

// Alu_op
localparam  [3:0] OP_ADD   = 4'b0000,
                  OP_SUB   = 4'b0001,
                  OP_SLL   = 4'b0010,
                  OP_SLT   = 4'b0011,
                  OP_SLTU  = 4'b0100,
                  OP_XOR   = 4'b0101,
                  OP_SRL   = 4'b0110,
                  OP_SRA   = 4'b0111,
                  OP_OR    = 4'b1000,
                  OP_AND   = 4'b1001;

// Func3 - ALU
 localparam [2:0] ADD  = 3'b000 ,
                  SLL  = 3'b001 ,
                  SLT  = 3'b010 ,
                  SLTU = 3'b011 ,
                  XOR  = 3'b100 ,
                  SRL  = 3'b101 ,
                  OR   = 3'b110 ,
                  AND  = 3'b111 ;

                 
// Func3 - BRANCH
 localparam [2:0] BEQ   = 3'b000 ,
                 BNE    = 3'b001 ,
                 BLT    = 3'b100 ,
                 BGE    = 3'b101 ,
                 BLTU   = 3'b110 ,
                 BGEU   = 3'b111 ;
                 

// Func3 - STORE
 localparam   [2:0] SB  = 3'b000,
                 SH     = 3'b001,
                 SW     = 3'b010;
                 

// Func3 - LOAD
 localparam  [2:0] LB   = 3'b000,
                 LH     = 3'b001,
                 LW     = 3'b010,
                 LBU    = 3'b100,
                 LHU    = 3'b101;               

// pc_sel
 localparam l_pc_four = 1'b0,
            l_pc_alu  = 1'b1;
// OPA 
localparam [1:0] l_opa_rs1_data = 1'b0,
                 l_opa_pc       = 1'b1;

// OPB
localparam [1:0] l_opb_rs2_data = 1'b0,
                 l_opb_imm_gen  = 1'b1;

// insn_vld
localparam l_unvalid      = 1'b0,
           l_valid        = 1'b1;

// rd_wren
localparam l_rdwn_un      = 1'b0,
           l_rdwn         = 1'b1;

// mem_wren
localparam l_memwn_un     = 1'b0,
           l_memwn        = 1'b1;

// wb_sel
localparam [1:0] l_wb_pc_four  = 2'b10,
                 l_wb_alu_data = 2'b01,
                 l_wb_lsu_data = 2'b00;

// br_un
localparam l_br_unsign    = 1'b0,
           l_br_sign      = 1'b1;

// lui_sel
localparam l_lui_un = 1'b0,
          l_lui    =  1'b1;

// =====================
always_comb begin : proc_control
    o_pc_sel    = l_pc_four;
    o_rd_wren   = l_rdwn_un;
    o_insn_vld  = l_unvalid;
    o_br_un     = l_br_unsign;
    o_opa_sel   = l_opa_rs1_data;
    o_opb_sel   = l_opb_rs2_data;
    o_mem_wren  = l_memwn_un;
    o_wb_sel    = l_wb_lsu_data; 
    o_alu_op    = OP_ADD; 
    o_lui_sel   = l_lui_un;
    o_isload    = 1'b0;
    case(i_instr[6:2])
        R_type: begin
            o_pc_sel    = l_pc_four     ;
            o_rd_wren   = l_rdwn        ;
            o_insn_vld  = l_valid       ;
            o_br_un     = l_br_unsign   ;
            o_opa_sel   = l_opa_rs1_data;
            o_opb_sel   = l_opb_rs2_data; 
            o_mem_wren  = l_memwn_un    ;
            o_wb_sel    = l_wb_alu_data ; 
            o_lui_sel   = l_lui_un      ;
            case (i_instr[14:12])
                ADD : o_alu_op = (i_instr[30]) ? OP_SUB : OP_ADD;
                SLL : o_alu_op = OP_SLL;
                SLT : o_alu_op = OP_SLT;
                SLTU: o_alu_op = OP_SLTU;
                XOR : o_alu_op = OP_XOR;
                SRL : o_alu_op = (i_instr[30]) ? OP_SRA : OP_SRL;
                OR  : o_alu_op = OP_OR;
                AND : o_alu_op = OP_AND;
                default: o_insn_vld = l_unvalid;
            endcase
        end
        I_type : begin
            o_pc_sel    = l_pc_four     ;
            o_rd_wren   = l_rdwn        ;
            o_insn_vld  = l_valid       ;
            o_br_un     = l_br_unsign   ;
            o_opa_sel   = l_opa_rs1_data;
            o_opb_sel   = l_opb_imm_gen ; 
            o_mem_wren  = l_memwn_un    ;
            o_wb_sel    = l_wb_alu_data ;
            o_lui_sel   = l_lui_un      ;
            case (i_instr[14:12])
                ADD : o_alu_op = OP_ADD;
                SLL : o_alu_op = OP_SLL;
                SLT : o_alu_op = OP_SLT;
                SLTU: o_alu_op = OP_SLTU;
                XOR : o_alu_op = OP_XOR;
                SRL : o_alu_op = (i_instr[30]) ? OP_SRA : OP_SRL;
                OR  : o_alu_op = OP_OR;
                AND : o_alu_op = OP_AND;
                default: o_insn_vld = l_unvalid;
            endcase
            
        end
        S_type : begin
            o_pc_sel    = l_pc_four;
            o_rd_wren   = l_rdwn_un;
            o_br_un     = l_br_unsign;
            o_opa_sel   = l_opa_rs1_data;
            o_opb_sel   = l_opb_imm_gen;
            o_alu_op    = OP_ADD;
            o_mem_wren  = l_memwn;
            o_wb_sel    = l_wb_lsu_data;
            o_lui_sel   = l_lui_un      ;
            case (i_instr[14:12])
                SB: o_insn_vld = l_valid;
                SH: o_insn_vld = l_valid;
                SW: o_insn_vld = l_valid;
                default: o_insn_vld = l_unvalid;
            endcase
            
        end
        L_type : begin
            o_pc_sel    = l_pc_four;
            o_rd_wren   = l_rdwn;
            o_br_un     = l_br_unsign;
            o_opa_sel   = l_opa_rs1_data;
            o_opb_sel   = l_opb_imm_gen;
            o_alu_op    = OP_ADD;
            o_mem_wren  = l_memwn_un;
            o_wb_sel    = l_wb_lsu_data;
            o_lui_sel   = l_lui_un ;
            o_isload    = 1'b1;
            case (i_instr[14:12])
                LB  : o_insn_vld = l_valid;
                LH  : o_insn_vld = l_valid;
                LW  : o_insn_vld = l_valid;
                LBU : o_insn_vld = l_valid;
                LHU : o_insn_vld = l_valid;
		default: begin 
		       	o_insn_vld = l_unvalid;
                o_wb_sel  = 2'bz;
            end
           endcase
        end
        SB_type: begin
            o_pc_sel    = l_pc_four;
            o_rd_wren   = l_rdwn_un;
            o_opa_sel   = l_opa_pc;
            o_opb_sel   = l_opb_imm_gen;
            o_alu_op    = OP_ADD;
            o_mem_wren  = l_memwn_un;
            o_wb_sel    = l_wb_alu_data;
            o_lui_sel   = l_lui_un      ;
            case(i_instr[14:12]) 
                BEQ  : begin 
                    o_insn_vld = l_valid;
                    o_br_un = l_br_sign;
                end
                BNE  : begin 
                    o_insn_vld = l_valid;
                    o_br_un = l_br_sign;
                end
                BLT  : begin 
                    o_insn_vld = l_valid;
                    o_br_un = l_br_sign;
                end
                BGE  : begin 
                    o_insn_vld = l_valid;
                    o_br_un = l_br_sign;
                end
                BLTU : begin 
                    o_insn_vld = l_valid;
                    o_br_un = l_br_unsign;
                end
                BGEU : begin 
                    o_insn_vld = l_valid;
                    o_br_un = l_br_unsign;
                end
                default: begin
                    o_insn_vld = l_unvalid;
                    o_br_un = l_br_unsign;
                end
            endcase
        end
        UL_type: begin
            o_pc_sel    = l_pc_four;
            o_rd_wren   = l_rdwn;
            o_insn_vld  = l_valid;
            o_br_un     = l_br_unsign;
            o_opa_sel   = l_opa_rs1_data;
            o_opb_sel   = l_opb_imm_gen;
            o_lui_sel   = l_lui     ;
            o_alu_op    = OP_ADD  ;
            o_mem_wren  = l_memwn_un;
            o_wb_sel    = l_wb_alu_data; 
        end
        UA_type: begin
            o_pc_sel    = l_pc_four;
            o_rd_wren   = l_rdwn;
            o_insn_vld  = l_valid;
            o_br_un     = l_br_unsign;
            o_opa_sel   = l_opa_pc;
            o_opb_sel   = l_opb_imm_gen;
            o_lui_sel   = l_lui_un    ;
            o_alu_op    = OP_ADD;
            o_mem_wren  = l_memwn_un;
            o_wb_sel    = l_wb_alu_data; 
        end
        UJ_type: begin
            o_pc_sel    = l_pc_four;
            o_rd_wren   = l_rdwn;
            o_insn_vld  = l_valid;
            o_br_un     = l_br_unsign;
            o_opa_sel   = l_opa_pc;
            o_opb_sel   = l_opb_imm_gen;
            o_lui_sel   = l_lui_un    ;
            o_alu_op    = OP_ADD;
            o_mem_wren  = l_memwn_un;
            o_wb_sel    = l_wb_pc_four; 
        end
        IJ_type: begin
            o_pc_sel    = l_pc_four;
            o_rd_wren   = l_rdwn;
            o_insn_vld  = l_valid;
            o_br_un     = l_br_unsign;
            o_opa_sel   = l_opa_rs1_data;
            o_opb_sel   = l_opb_imm_gen;
            o_lui_sel   = l_lui_un    ;
            o_alu_op    = OP_ADD;
            o_mem_wren  = l_memwn_un;
            o_wb_sel    = l_wb_pc_four;
        end
        default: begin
            o_pc_sel    = l_pc_four;
            o_rd_wren   = l_rdwn_un;
            o_insn_vld  = l_unvalid;
            o_br_un     = l_br_unsign;
            o_opa_sel   = l_opa_rs1_data;
            o_opb_sel   = l_opb_rs2_data;
            o_lui_sel   = l_lui_un;
            o_alu_op    = OP_ADD;
            o_mem_wren  = l_memwn_un;
            o_wb_sel    = l_wb_pc_four; 

        end
    endcase
end

endmodule
