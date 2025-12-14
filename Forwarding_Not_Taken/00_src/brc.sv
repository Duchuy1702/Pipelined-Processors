module brc(
    input logic         i_br_un, // 1 sign, 0 unsign
    input logic [31:0]  i_rs1_data,
    input logic [31:0]  i_rs2_data,

    output logic        o_brc_less,
    output logic        o_brc_equal
);

assign o_brc_equal = ~(|(i_rs1_data ^ i_rs2_data));
logic [31:0] slt_w;
logic [31:0] sltu_w;

SLT_32bit  SLT0(i_rs1_data, i_rs2_data, slt_w)     ;
SLTU_32bit SLTU0(i_rs1_data, i_rs2_data, sltu_w)   ;

always_comb begin 
    if (i_br_un) o_brc_less = slt_w[0];
    else o_brc_less = sltu_w[0];
end

endmodule
