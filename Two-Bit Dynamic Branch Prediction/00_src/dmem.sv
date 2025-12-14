module dmem_64KiB (
    input  logic i_clk           ,
    input  logic rst_n           ,
    input  logic wr_en           ,     // wr_en3 nối vào
    input  logic [31:0] addr     ,     // Địa chỉ có thể truy cập 2048 từ (11 bit)
    input  logic [31:0] i_w_data ,     // Dữ liệu ghi (32-bit)
    input  logic [2:0 ] i_func3  ,                            
    output logic [31:0] r_data        // Dữ liệu đọc (32-bit)
);
 
// Khai báo bộ nhớd_mem với địa chỉ byte ,8bit 2048 ô
    logic [7:0] d_mem [0:65535] ;

   parameter [2:0]   LB  = 3'b000 ,
	                 SB  = 3'b000 ,
                     LBU = 3'b100 ,
                     LH  = 3'b001 ,
                     SH  = 3'b001 ,
                     LHU = 3'b101 ,
                     LW  = 3'b010 ,
                     SW  = 3'b010 ;
logic [31:0] nxt,nxt1,nxt2;
logic c1,c2,c3;
adder_32bit dut  (addr[31:0],32'h1,nxt ,c1);
adder_32bit dut1 (addr[31:0],32'h2,nxt1,c2);
adder_32bit dut2 (addr[31:0],32'h3,nxt2,c3);

    always_ff @(posedge i_clk or negedge rst_n) begin
    
    if(!rst_n) begin
        for (int i = 0; i <= 65535; i= i + 1 ) begin
        d_mem[i] <= 8'd0;
        end

    end
    else if(wr_en) begin // Store
        case(i_func3)
        SB: begin
            d_mem[addr[15:0]]   <= i_w_data[7:0];
            d_mem[nxt[15:0]]  <= d_mem[nxt[15:0]];
            d_mem[nxt1[15:0]] <= d_mem[nxt1[15:0]];
            d_mem[nxt2[15:0]] <= d_mem[nxt2[15:0]];
        end
        SH: begin 
           d_mem[addr[15:0]]   <= i_w_data[7:0] ;
           d_mem[nxt[15:0]]  <= i_w_data[15:8];
           d_mem[nxt1[15:0]] <= d_mem[nxt1[15:0]];
           d_mem[nxt2[15:0]] <= d_mem[nxt2[15:0]];
         end
        SW: begin
           d_mem[addr[15:0]]   <= i_w_data[7:0]  ; 
           d_mem[nxt[15:0]] <= i_w_data[15:8] ;
           d_mem[nxt1[15:0]] <= i_w_data[23:16];
           d_mem[nxt2[15:0]] <= i_w_data[31:24];
        end  
        default: begin
          d_mem[addr[15:0]]   <= d_mem[addr[15:0]]  ;
          d_mem[nxt[15:0]]  <= d_mem[nxt[15:0]];
          d_mem[nxt1[15:0]] <= d_mem[nxt1[15:0]];
          d_mem[nxt2[15:0]] <= d_mem[nxt2[15:0]];
        end
        endcase
    end
        else begin // wr_en = 0 
          d_mem[addr[15:0]]   <= d_mem[addr[15:0]]  ;
          d_mem[nxt[15:0]]  <= d_mem[nxt[15:0]];
          d_mem[nxt1[15:0]] <= d_mem[nxt1[15:0]];
          d_mem[nxt2[15:0]] <= d_mem[nxt2[15:0]];
        end          
    end   
always_comb begin
        if(!wr_en) begin
        case(i_func3)
        LB : r_data = {{24{d_mem[addr[15:0]][7]}},d_mem[addr[15:0]]};
        LBU: r_data = {24'b0,d_mem[addr[15:0]]};
        LH : r_data = {{16{d_mem[nxt[15:0]][7]}},d_mem[nxt[15:0]],d_mem[addr[15:0]]};
        LHU: r_data = {16'b0,d_mem[nxt[15:0]],d_mem[addr[15:0]]};
        LW : r_data = {d_mem[nxt2[15:0]],d_mem[nxt1[15:0]],d_mem[nxt[15:0]],d_mem[addr[15:0]] };
        default r_data = 32'h0;
        endcase 
    end
        else r_data = 32'h0;   
        end   
 
    endmodule
