module SLT_32bit (
    input logic [31:0] a_i,    // Operand A (rs1)
    input logic [31:0] b_i,    // Operand B (rs2)
    output logic [31:0 ] Result          // Kết quả (A < B với so sánh có dấu)
);
 logic A_sign      ;
 logic B_sign      ;
 logic [31:0] D_sub;
 logic C_o         ;

subtractor_32bit dut (.a_i(a_i)  ,
                      .b_i(b_i)  ,
                      .d_o(D_sub),
                      .b_o(C_o)) ;

 assign A_sign = a_i[31];
 assign B_sign = b_i[31];
 
 assign Result = {{31{1'b0}}, (A_sign ^ B_sign) ? A_sign : C_o };

endmodule
