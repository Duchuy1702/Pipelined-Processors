
module lsu(
    input  logic         i_clk,
    input  logic         i_rst_n,
    input  logic         i_lsu_wren,
    input  logic [31:0]  i_lsu_addr,
    input  logic [31:0]  i_st_data,
    input  logic [31:0]  i_instr,
    input  logic [31:0]  i_io_sw,

    output logic [6:0]   o_io_hex0,
    output logic [6:0]   o_io_hex1,
    output logic [6:0]   o_io_hex2,
    output logic [6:0]   o_io_hex3,
    output logic [6:0]   o_io_hex4,
    output logic [6:0]   o_io_hex5,
    output logic [6:0]   o_io_hex6,
    output logic [6:0]   o_io_hex7,
    
    output logic [31:0]  o_ld_data,
    output logic [31:0]  o_io_ledr,
    output logic [31:0]  o_io_ledg,
    output logic [31:0]  o_io_lcd
);

   // Internal signals

    logic [31:0] r_input_data, r_output_data, r_dmem_data;
    logic        wren3, wren2, wren1;

   // Address decoding
 
    assign wren3 = (i_lsu_addr[31:16] == 16'h0000) ? i_lsu_wren : 1'b0;  // DMEM
    assign wren2 = (i_lsu_addr[31:16] == 16'h1000) ? i_lsu_wren : 1'b0;  // Output buffer
    
    // Input buffer (read switches)
 
  input_buf u_input_buf(
        .i_clk    (i_clk),
        .rst_n    (i_rst_n),
	    .func3    (i_instr[14:12]),
        .wren     (i_lsu_wren),
        .i_sw     (i_io_sw),
        .o_data   (r_input_data)
    );
  
    // Output buffer (LEDs, HEX, LCD)
    
    output_buf u_output_buf(
        .i_clk       (i_clk)         ,
        .i_rst_n     (i_rst_n)       ,
        .wren        (wren2)         ,
        .func3       (i_instr[14:12]),
        .addr        (i_lsu_addr)    ,
        .i_buf_data  (i_st_data)     ,
        .o_data      (r_output_data) ,
        .o_io_ledr   (o_io_ledr)     ,
        .o_io_ledg   (o_io_ledg)     ,
        .o_io_hex0   (o_io_hex0)     ,
        .o_io_hex1   (o_io_hex1)     ,
        .o_io_hex2   (o_io_hex2)     ,
        .o_io_hex3   (o_io_hex3)     ,
        .o_io_hex4   (o_io_hex4)     ,
        .o_io_hex5   (o_io_hex5)     ,
        .o_io_hex6   (o_io_hex6)     ,
        .o_io_hex7   (o_io_hex7)     ,
        .o_io_lcd    (o_io_lcd)
    );

    // Data memory (2KiB)
    
    dmem_2KiB u_dmem(
        .i_clk      (i_clk)         ,
        .rst_n      (i_rst_n)       ,
        .wr_en      (wren3)         ,
        .i_func3    (i_instr[14:12]),
        .addr       (i_lsu_addr)    ,
        .i_w_data   (i_st_data)     ,
        .r_data     (r_dmem_data)
    );

    // LOAD path (read data back to CPU)
 
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_lsu_wren) begin
            case (i_lsu_addr[31:16])
                16'h0000: o_ld_data <= r_dmem_data;       // dmem
                16'h1001: o_ld_data <= r_input_data;      // input buffer
                16'h1000: o_ld_data <= r_output_data;     // output buffer
                default:  o_ld_data <= 32'h0;
            endcase
        end else begin
            o_ld_data <= 32'h0;
        end
    end

endmodule
