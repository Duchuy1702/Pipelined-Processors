 module pipelined (
    input  logic        i_clk     ,
    input  logic        i_reset   ,
    input  logic [31:0] i_io_sw   ,
    output logic        o_ctrl    ,
    output logic        o_mispred ,
    output logic [31:0] o_io_lcd  ,
    output logic [31:0] o_io_ledg ,
    output logic [31:0] o_io_ledr ,
    output logic [6:0]  o_io_hex0 ,
    output logic [6:0]  o_io_hex1 ,
    output logic [6:0]  o_io_hex2 ,
    output logic [6:0]  o_io_hex3 ,
    output logic [6:0]  o_io_hex4 ,
    output logic [6:0]  o_io_hex5 ,
    output logic [6:0]  o_io_hex6 ,
    output logic [6:0]  o_io_hex7 ,
    output logic [31:0] o_pc_debug,
    output logic        o_insn_vld
);

    // -------------------------------
    // Các tín hiệu của stage IF
    // -------------------------------
    logic [31:0] pc_next, pc_now, pc_four_IF, pc_debug_IF ;
    logic [31:0] instr_IF_tmp;
    logic [31:0] alu_EX ;
    logic pc_sel_tmp, enable_pc;
    
    // -------------------------------
    // Các tín hiệu của stage ID
    // -------------------------------
    logic [31:0] instr_ID_tmp; 
    logic [31:0] pc_debug_ID, pc_four_ID ; 
    logic rd_wren_ID;  
    logic [4:0] ID_Rs1addr ,ID_Rs2addr , ID_Rdaddr;
    logic lui_sel_ID , pc_sel_ID ;
    logic insn_vld_ID, br_un_ID ;
    logic [31:0] rs1_data_ID, rs2_data_ID; 
    logic [31:0] immgen_ID; 
    logic [1:0] opa_sel_ID, opb_sel_ID, wb_sel_ID;
    logic mem_wren_ID, ID_isload,enable_ID  ;
    logic [3:0] op_alu_ID;
    logic [4:0] WB_Rd_addr_tmp;
    logic fwd_rs1_ID, fwd_rs2_ID;
    logic [31:0] rs1_data_ID_tmp, rs2_data_ID_tmp; 

    // -------------------------------
    // Các tín hiệu của stage EX
    // -------------------------------
    logic [31:0] rs1_data_EX, rs2_data_EX;
    logic [31:0] immgen_EX_tmp ,pc_debug_EX   ;
    logic [31:0] instr_EX_tmp;
    logic lui_sel_EX;
    logic rd_wren_EX; 
    logic insn_vld_EX, br_un_EX;
    logic [1:0] opa_sel_EX, opb_sel_EX, wb_sel_EX;
    logic mem_wren_EX, EX_isload;
    logic [3:0] op_alu_EX;
    logic [4:0] EX_Rs1addr ,EX_Rs2addr , EX_Rdaddr;
    logic brc_less_tmp, brc_equal_tmp;
    logic [1:0] forwardA_tmp;
    logic [1:0] forwardB_tmp;
    logic [31:0] pc_four_EX;
    logic [31:0] operand_a , operand_b;
    logic [31:0] data_sela  ;
    logic [1:0] fwd_rs1_brc, fwd_rs2_brc;
    logic [31:0]  rs1_brc_nxt, rs2_brc_nxt;
    logic flush_EX;

    // -------------------------------
    // Các tín hiệu của stage Memmory
    // -------------------------------
     
    logic mem_wren_M        ;
    logic [31:0] rs2_data_M ;
    logic [31:0] pc_four_M  ;
    logic        insn_vld_M ;
    logic [31:0] instr_M    ;
    logic [31:0] alu_M      ;
    logic [4:0] M_Rdaddr    ;
    logic rd_wren_M         ;
    logic M_isload          ;
    logic [1:0] wb_sel_M    ;
    logic [31:0] pc_debug_M ;

    // -------------------------------
    // Các tín hiệu của stage WB
    // -------------------------------
    logic [31:0] WB_tmp ;
    logic rd_wren_WB    ;
    logic [31:0] pc_four_WB, alu_WB, ld_data_WB ;
    logic [1:0] wb_sel_WB ;
    
    // -------------------------------
    // Các tín hiệu của branch_pre
    // -------------------------------
   
    logic flush_pre;
    logic o_ctrl_EX, o_ctrl_M ;
    logic o_mispred_EX, o_mispred_M ;
    logic pc_branch;

    //==========================================================================================
    //==========================================================================================

    // -------------------------------
    // Gôm các khối của IF
    // -------------------------------
    
    imem imem_dut (         // Instruction Memory_IF
        .pc     (pc_now),
        .instr  (instr_IF_tmp)
    );

    mux2_1 pc_sel (         // PC selection_IF
        .sel      (pc_sel_tmp) ,
        .i_data_0 (pc_four_IF),
        .i_data_1 (alu_EX)     ,
        .o_data   (pc_next)
    );

    PC_plus_4 pc4 (         // PC_plus_4_IF
        .i_pc      (pc_now),
        .o_pc_next (pc_four_IF)
    );
    pc_IF pc_dut (             // PC_clock_IF
        .i_clk     (i_clk)     ,
        .i_rst_n   (i_reset)   ,
        .pc_enable (enable_pc ),
        .i_pc_next (pc_next)   ,
        .o_pc      (pc_now)
    );
   
    assign pc_debug_IF = pc_now;
    //========================================================================================
    //===================================== D-FF of IF -> ID =================================
DFF_IF_ID D1(
    .i_clk (i_clk)         ,
    .i_rst_n (i_reset)     ,
    .flush (flush_pre)      ,
    .enable (enable_ID)    ,
    .instr_IF(instr_IF_tmp),
    .instr_ID(instr_ID_tmp), 
    .i_pcfour_IF(pc_four_IF), 
    .o_pcfour_ID(pc_four_ID),
    .i_pc_debug_IF(pc_debug_IF),
    .o_pc_debug_ID(pc_debug_ID)
);
    // -------------------------------
    // Gôm các khối của ID
    // -------------------------------

    regfile u_regfile (     //Register file
        .i_clk      (i_clk)              ,
        .i_rst_n    (i_reset)            ,
        .i_rd_wren  (rd_wren_WB)         ,
        .i_rs1_addr (instr_ID_tmp[19:15]),
        .i_rs2_addr (instr_ID_tmp[24:20]),
        .i_rd_addr  (WB_Rd_addr_tmp)     ,
        .i_rd_data  (WB_tmp)             ,
        .o_rs1_data (rs1_data_ID_tmp)    ,
        .o_rs2_data (rs2_data_ID_tmp)
    );
    
    mux2_1 rs1_data(
        .sel      (fwd_rs1_ID)     ,
        .i_data_0 (rs1_data_ID_tmp),
        .i_data_1 (WB_tmp)         ,
        .o_data   (rs1_data_ID)

    );

    mux2_1 rs2_data(
        .sel      (fwd_rs2_ID) ,
        .i_data_0 (rs2_data_ID_tmp),
        .i_data_1 (WB_tmp)     ,
        .o_data   (rs2_data_ID)

    );


    immgen u_immgen (     // ImmGen_ID
        .i_instr (instr_ID_tmp),
        .o_immgen(immgen_ID)
    );

    assign ID_Rs1addr = instr_ID_tmp[19:15];
    assign ID_Rs2addr = instr_ID_tmp[24:20];
    assign ID_Rdaddr  = instr_ID_tmp[11:7] ;

    // -------------------------------
    // Control Unit
    // -------------------------------
control_ID dut1 (
    .i_instr     (instr_ID_tmp),
    .o_lui_sel   (lui_sel_ID)  ,
    .o_pc_sel    (pc_sel_ID)   ,
    .o_rd_wren   (rd_wren_ID)  ,
    .o_insn_vld  (insn_vld_ID) ,
    .o_br_un     (br_un_ID)    ,
    .o_opa_sel   (opa_sel_ID)  ,
    .o_opb_sel   (opb_sel_ID)  ,
    .o_mem_wren  (mem_wren_ID) ,
    .o_wb_sel    (wb_sel_ID)   ,
    .o_alu_op    (op_alu_ID)   ,
    .o_isload    (ID_isload)   

 );

//========================================================================================
//===================================== D-FF of ID -> EX =================================
 DFF_ID_EX D2(
   .i_clk       (i_clk)          ,
   .i_rst_n     (i_reset)        ,
   .flush       (flush_pre)      ,
   .flush_fwd   (flush_EX )      ,
   .rs1_ID      (rs1_data_ID)    ,
   .rs2_ID      (rs2_data_ID)    ,
   .immgen_ID   (immgen_ID)      ,
   .rs1_EX      (rs1_data_EX)    ,
   .rs2_EX      (rs2_data_EX),
   .immgen_EX   (immgen_EX_tmp)  ,
   .ID_Rs1_addr (ID_Rs1addr)     ,
   .ID_Rs2_addr (ID_Rs2addr)     ,
   .ID_Rd_addr  (ID_Rdaddr)      ,
   .EX_Rs1_addr (EX_Rs1addr)     ,
   .EX_Rs2_addr (EX_Rs2addr)     ,
   .EX_Rd_addr  (EX_Rdaddr)      ,
   .i_instr_ID  (instr_ID_tmp)   ,
   .i_lui_ID    (lui_sel_ID)     ,
   .i_rdwren_ID  (rd_wren_ID)    ,
   .i_insnvld_ID (insn_vld_ID)   ,
   .i_br_un_ID   (br_un_ID)      ,
   .i_opa_ID     (opa_sel_ID)    ,
   .i_opb_ID     (opb_sel_ID)    ,
   .i_memwren_ID (mem_wren_ID)   ,
   .i_wbsel_ID   (wb_sel_ID)     ,
   .i_alu_op_ID  (op_alu_ID)     ,
   .o_instr_EX   (instr_EX_tmp)  ,
   .o_lui_EX     (lui_sel_EX)    ,
   .o_rdwren_EX  (rd_wren_EX)    ,
   .o_insnvld_EX (insn_vld_EX)   ,
   .o_br_un_EX   (br_un_EX)      ,
   .o_opa_EX     (opa_sel_EX)    ,
   .o_opb_EX     (opb_sel_EX)    ,
   .o_memwren_EX  (mem_wren_EX)  ,
   .o_wbsel_EX    (wb_sel_EX)    ,
   .o_alu_op_EX   (op_alu_EX)    ,
   .i_pcfour_ID   (pc_four_ID)   , 
   .o_pcfour_EX   (pc_four_EX)   ,
   .i_pc_debug_ID (pc_debug_ID)  ,
   .o_pc_debug_EX (pc_debug_EX)  ,
   .i_isload_ID   (ID_isload)    ,
   .o_isload_EX   (EX_isload)     

 );
    // -------------------------------
    // Gôm các khối của EX
    // -------------------------------

    mux4_1 rs1_brc (           
        .sel      (fwd_rs1_brc) ,
        .i_data_0 (rs1_data_EX) ,
        .i_data_1 (WB_tmp)      ,
        .i_data_2 (alu_M)       ,
        .i_data_3 (32'h0)       ,
        .o_data   (rs1_brc_nxt)
    );

    mux4_1 rs2_brc (           
        .sel      (fwd_rs2_brc) ,
        .i_data_0 (rs2_data_EX) ,
        .i_data_1 (WB_tmp)      ,
        .i_data_2 (alu_M)       ,
        .i_data_3 (32'h0)       ,
        .o_data   (rs2_brc_nxt)
    );

    brc u_brc (  
        .i_br_un     (br_un_EX)    ,
        .i_rs1_data  (rs1_brc_nxt) ,
        .i_rs2_data  (rs2_brc_nxt) ,
        .o_brc_less  (brc_less_tmp) ,
        .o_brc_equal (brc_equal_tmp)
    );

    // Operand mux
    mux4_1 sela (
        .sel      (forwardA_tmp) ,
        .i_data_0 (rs1_data_EX)  ,
        .i_data_1 (WB_tmp)       ,
        .i_data_2 (alu_M)        ,
        .i_data_3 (pc_debug_EX)  ,
        .o_data   (data_sela)
    );

    mux4_1 selb (
        .sel      (forwardB_tmp) ,
        .i_data_0 (rs2_data_EX)  ,
        .i_data_1 (WB_tmp)       ,
        .i_data_2 (alu_M)        ,
        .i_data_3 (immgen_EX_tmp),
        .o_data   (operand_b)
    );
  
 mux2_1 sel3 (           
        .sel      (lui_sel_EX) ,
        .i_data_0 (data_sela)  ,
        .i_data_1 (32'h0)      ,
        .o_data   (operand_a)
    );

alu alu_dut (
        .i_alu_op    (op_alu_EX) ,
        .i_operand_a (operand_a) ,
        .i_operand_b (operand_b) ,
        .o_alu_data  (alu_EX)
    );
//========================================================================================
//===================================== D-FF of EX -> M ==================================
DFF_EX_M D3 (
    .i_clk        (i_clk)       ,  
    .i_rst_n      (i_reset)     ,
    .alu_EX       (alu_EX)      ,
    .rs2_EX       (rs2_brc_nxt) ,
    .alu_M        (alu_M)       ,
    .rs2_M        (rs2_data_M)  ,
    .EX_Rd_addr   (EX_Rdaddr)   ,
    .M_Rd_addr    (M_Rdaddr)    ,
    .i_rdwren_EX  (rd_wren_EX)  ,
    .i_insnvld_EX (insn_vld_EX) ,
    .i_memwren_EX (mem_wren_EX) ,
    .i_wbsel_EX   (wb_sel_EX)   ,
    .o_rdwren_M   (rd_wren_M)   ,
    .o_insnvld_M  (insn_vld_M)  ,
    .o_memwren_M  (mem_wren_M)  ,
    .o_wbsel_M    (wb_sel_M)    ,
    .i_instr_EX   (instr_EX_tmp),
    .o_instr_M    (instr_M)     ,
    .i_pcfour_EX  (pc_four_EX)  , 
    .o_pcfour_M   (pc_four_M)   ,
    .i_ctrl_EX    (o_ctrl_EX)   ,
    .o_ctrl_M     (o_ctrl_M)    ,
    .i_mispred_EX (o_mispred_EX), 
    .o_mispred_M  (o_mispred_M) ,
    .i_pc_debug_EX(pc_debug_EX) ,
    .o_pc_debug_M (pc_debug_M)

);

    // -------------------------------
    // Gôm các khối của MEM
    // -------------------------------

lsu u_lsu (
    .i_clk      (i_clk)     ,
    .i_rst_n    (i_reset)   ,
    .i_lsu_wren (mem_wren_M),
    .i_lsu_addr (alu_M)     , // ALU result = memory address
    .i_st_data  (rs2_data_M),
    .i_instr    (instr_M)   , //
    .i_io_sw    (i_io_sw)   ,
    .o_io_hex0  (o_io_hex0) ,
    .o_io_hex1  (o_io_hex1) ,
    .o_io_hex2  (o_io_hex2) ,
    .o_io_hex3  (o_io_hex3) ,
    .o_io_hex4  (o_io_hex4) ,
    .o_io_hex5  (o_io_hex5) ,
    .o_io_hex6  (o_io_hex6) , 
    .o_io_hex7  (o_io_hex7) ,
    .o_ld_data  (ld_data_WB) ,
    .o_io_ledr  (o_io_ledr) ,
    .o_io_ledg  (o_io_ledg) ,
    .o_io_lcd   (o_io_lcd)
  
);

//========================================================================================
//===================================== D-FF of M -> WB ==================================
 DFF_M_WB D4(
    .i_clk       (i_clk)      ,
    .i_rst_n     (i_reset)    ,
    .pc_four_M   (pc_four_M)  ,
    .alu_M       (alu_M)      ,
    .pc_four_WB  (pc_four_WB) ,
    .alu_WB      (alu_WB)     ,
    .M_Rd_addr    (M_Rdaddr) ,
    .WB_Rd_addr   (WB_Rd_addr_tmp),
    .i_rdwren_M   (rd_wren_M)   ,
    .i_insnvld_M  (insn_vld_M)  ,
    .i_wbsel_M    (wb_sel_M)    ,
    .o_rdwren_WB  (rd_wren_WB)  ,
    .o_insnvld_WB (o_insn_vld)  ,
    .o_wbsel_WB   (wb_sel_WB)   ,
    .ctrl_M       (o_ctrl_M)    ,
    .mispred_M    (o_mispred_M) ,
    .ctrl_WB      ( o_ctrl )    ,
    .mispred_WB   ( o_mispred ) ,
    .i_pc_debug_M (pc_debug_M)  ,
    .o_pc_debug_WB (o_pc_debug)

 );

    // -------------------------------
    //  Khối WB_Writeback mux
    // -------------------------------
mux4_1 u_mux4_1 (
        .sel      (wb_sel_WB) ,
        .i_data_0 (ld_data_WB),
        .i_data_1 (alu_WB)    , 
        .i_data_2 (pc_four_WB),
        .i_data_3 (32'h0)     ,
        .o_data   (WB_tmp)
    );

 Forwarding fd_dut (
   .EX_RdWren   (rd_wren_EX)     , 
   .MEM_RdWren  (rd_wren_M)      ,
   .WB_RdWren   (rd_wren_WB)     ,
   .EX_isload   (EX_isload)      , 
   .MEM_RdAddr  (M_Rdaddr)       , 
   .EX_RdAddr   (EX_Rdaddr)      ,
   .EX_Rs1Addr  (EX_Rs1addr)     , 
   .EX_Rs2Addr  (EX_Rs2addr)     , 
   .WB_RdAddr   (WB_Rd_addr_tmp) , 
   .op_sel_a_EX (opa_sel_EX)     , 
   .op_sel_b_EX (opb_sel_EX)     , 
   .ID_rs1addr  (ID_Rs1addr)     ,
   .ID_rs2addr  (ID_Rs2addr)     ,
   .ForwardA    (forwardA_tmp)   , 
   .ForwardB    (forwardB_tmp)   , 
   .For_rs1_ID  (fwd_rs1_ID)     ,
   .For_rs2_ID  (fwd_rs2_ID)     ,
   .EX_flush    (flush_EX )      , 
   .fwd_rs1_brc (fwd_rs1_brc)    , 
   .fwd_rs2_brc (fwd_rs2_brc)    , 
   .ID_enable   (enable_ID)      ,
   .pc_enable   (enable_pc )      
 );

br_predict branch(
    .instr_EX   (instr_EX_tmp) ,
    .i_brc_less (brc_less_tmp),
    .i_brc_equal(brc_equal_tmp),
    .o_Flush    (flush_pre)    ,
    .o_ctrl     (o_ctrl_EX)    ,         // Có lệnh BRANCH và JUMP
    .o_mispred  (o_mispred_EX) ,         // Nhảy PC
    .o_pc_branch(pc_branch)

);
assign pc_sel_tmp = pc_branch | pc_sel_ID ;

 endmodule
