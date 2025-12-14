module immgen(
    input logic [31:0]  i_instr,
    output logic [31:0] o_immgen
);

// OPCODE TYPES
localparam [4:0] R_type  = 5'b01100 ,
                 I_type  = 5'b00100 ,
                 S_type  = 5'b01000 ,  // Store
                 L_type  = 5'b00000 ,  // Load
                 SB_type = 5'b11000 ,  // Branch
                 UL_type = 5'b01101 ,  // LUI 
                 UA_type = 5'b00101 ,  // AUIPC
                 UJ_type = 5'b11011 ,  // JAL
                 IJ_type = 5'b11001 ;  // JALR (I-Type format)

always_comb begin
    case (i_instr[6:2])
        R_type:  o_immgen = 32'b0;  // R-type has no immediate

        // I-type (ADDI, LW, JALR)
        I_type, L_type, IJ_type: 
            o_immgen = {{20{i_instr[31]}}, i_instr[31:20]};

        // S-type (SW, SH, SB)
        S_type:
            o_immgen = {{20{i_instr[31]}}, i_instr[31:25], i_instr[11:7]};

        // SB-type (BEQ, BNE, BLT, BGE, BLTU, BGEU)
        SB_type:
            o_immgen = {{20{i_instr[31]}}, i_instr[7], i_instr[30:25], i_instr[11:8], 1'b0};

        // U-type (LUI, AUIPC)
        UL_type, UA_type:
            o_immgen = {i_instr[31:12], 12'b0};

        // UJ-type (JAL)
        UJ_type:
            o_immgen = {{12{i_instr[31]}},i_instr[19:12], i_instr[20],i_instr[30:21], 1'b0};
        
        default:
            o_immgen = 32'h0;
    endcase
end

endmodule
