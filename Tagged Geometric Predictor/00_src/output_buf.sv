module output_buf(
    input logic          i_clk            ,
    input logic          i_rst_n          ,
    input logic          wren             ,  // Write enable signal
    input logic  [2:0]   func3            ,  
    input logic  [31:0]  addr             ,  // Address = rs1 + immgen
    input logic  [31:0]  i_buf_data       ,  // Data from rs2 to be written
    output logic [31:0]  o_data           ,  // Data output to CPU
    output logic [31:0]  o_io_ledr        ,  // Output to red LEDs
    output logic [31:0]  o_io_ledg        ,  // Output to green LEDs
    output logic [6:0]   o_io_hex0        ,  // HEX display 0
    output logic [6:0]   o_io_hex1        ,  // HEX display 1
    output logic [6:0]   o_io_hex2        ,  // HEX display 2
    output logic [6:0]   o_io_hex3        ,  // HEX display 3
    output logic [6:0]   o_io_hex4        ,  // HEX display 4
    output logic [6:0]   o_io_hex5        ,  // HEX display 5
    output logic [6:0]   o_io_hex6        ,  // HEX display 6
    output logic [6:0]   o_io_hex7        ,  // HEX display 7
    output logic [31:0]  o_io_lcd          // Output to LCD
);

logic [31:0] outbuf [0:4];
logic [31:0] data_out;

// == Func3 values for Load/Store instructions ==
localparam [2:0] LB  = 3'b000 ,
                 SB  = 3'b000 ,
                 LBU = 3'b100 ,
                 LH  = 3'b001 ,
                 SH  = 3'b001 ,
                 LHU = 3'b101 ,
                 LW  = 3'b010 ,
                 SW  = 3'b010 ;

always_ff @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin 
      outbuf[0] <= 32'h0; // LED RED
      outbuf[1] <= 32'h0; // LED GREEN
      outbuf[2] <= 32'h0; // HEX 0-3
      outbuf[3] <= 32'h0; // HEX 4-7
      outbuf[4] <= 32'h0; // LCD    
    end
     else if(wren) begin // === Store operations ===
        case(addr[15:12])
        4'h0: begin
         case(func3)
         SB: begin // Store Byte (SB)
            outbuf[0][7:0]  <= i_buf_data[7:0];
            outbuf[0][31:8] <= outbuf[0][31:8]; 
        end
        SH: begin // Store H
            outbuf[0][15:0]  <= i_buf_data[15:0];
            outbuf[0][31:16] <= outbuf[0][31:16];
        end
        SW: outbuf[0] <= i_buf_data; // Store Word (SW)
        default: outbuf[0] <= outbuf[0];
        endcase
        end
        4'h1:begin
         case(func3)
         SB: begin // Store Byte (SB)
            outbuf[1][7:0]  <= i_buf_data[7:0];
            outbuf[1][31:8] <= outbuf[1][31:8]; 
        end
        SH: begin // Store H
            outbuf[1][15:0]  <= i_buf_data[15:0];
            outbuf[1][31:16] <= outbuf[1][31:16];
        end
        SW: outbuf[1] <= i_buf_data; // Store Word (SW)
        default: outbuf[1] <= outbuf[1];
        endcase
        end  
        4'h2:begin
         case(func3)
         SB: begin // Store Byte (SB)
            outbuf[2][7:0]  <= i_buf_data[7:0];
            outbuf[2][31:8] <= outbuf[2][31:8]; 
        end
        SH: begin // Store H
            outbuf[2][15:0]  <= i_buf_data[15:0];
            outbuf[2][31:16] <= outbuf[2][31:16];
        end
        SW: outbuf[2] <= i_buf_data; // Store Word (SW)
        default: outbuf[2] <= outbuf[2];
        endcase
        end
        4'h3:begin
         case(func3)
         SB: begin // Store Byte (SB)
            outbuf[3][7:0]  <= i_buf_data[7:0];
            outbuf[3][31:8] <= outbuf[3][31:8]; 
        end
        SH: begin // Store H
            outbuf[3][15:0]  <= i_buf_data[15:0];
            outbuf[3][31:16] <= outbuf[3][31:16];
        end
        SW: outbuf[3] <= i_buf_data; // Store Word (SW)
        default: outbuf[3] <= outbuf[3];
        endcase
        end 
        4'h4: begin
         case(func3)
         SB: begin // Store Byte (SB)
            outbuf[4][7:0]  <= i_buf_data[7:0];
            outbuf[4][31:8] <= outbuf[4][31:8]; 
        end
        SH: begin // Store H
            outbuf[4][15:0]  <= i_buf_data[15:0];
            outbuf[4][31:16] <= outbuf[4][31:16];
        end
        SW: outbuf[4] <= i_buf_data; // Store Word (SW)
        default: outbuf[4] <= outbuf[4];
        endcase
        end
        default : outbuf[0] <= outbuf[0];
    endcase
    end
 end
 
always_comb begin
 if(!wren) begin
   case(addr[15:12])
        4'h0: data_out = outbuf[0];
        4'h1: data_out = outbuf[1];
        4'h2: data_out = outbuf[2];
        4'h3: data_out = outbuf[3];
        4'h4: data_out = outbuf[4];
        default: data_out = 32'h0;
   endcase
end
   else data_out = 32'h0;
end

always_comb begin
    if(!wren) begin // === Load operations ===
        case(func3)
        LB :  o_data = {{24{data_out[7]}}, data_out[7:0]};      // Load Byte (sign-extended)
        LBU:  o_data = {24'b0, data_out[7:0]};                  // Load Byte Unsigned
        LH :  o_data = {{16{data_out[15]}}, data_out[15:0]};    // Load Halfword (sign-extended)
        LHU:  o_data = {16'b0, data_out[15:0]};                 // Load Halfword Unsigned
        LW :  o_data = data_out;                                // Load Word (32-bit)
        default o_data = 32'h0;                                 // Default zero
        endcase 
    end
    else o_data = 32'h0;                                         // If write enabled, output is inactive
end   

// ================== Peripheral Output Mapping ==================

assign o_io_ledr = {15'b0,outbuf[0][16:0]};                         // LEDR output mapping
assign o_io_ledg = {24'b0,outbuf[1][7:0]};                          // LEDG output mapping
assign o_io_hex0 = outbuf[2][6:0]  ;                                // HEX0 display
assign o_io_hex1 = outbuf[2][14:8] ;                                // HEX1 display
assign o_io_hex2 = outbuf[2][22:16];                                // HEX2 display
assign o_io_hex3 = outbuf[2][30:24];                                // HEX3 display
assign o_io_hex4 = outbuf[3][6:0]  ;                                // HEX4 display
assign o_io_hex5 = outbuf[3][14:8] ;                                // HEX5 display
assign o_io_hex6 = outbuf[3][22:16];                                // HEX6 display
assign o_io_hex7 = outbuf[3][30:24];                                // HEX7 display
assign o_io_lcd  = { outbuf[4][31],20'b0, outbuf[4][10:0]};           // LCD mapping

endmodule

