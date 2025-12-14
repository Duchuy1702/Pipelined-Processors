module input_buf (
   input  logic i_clk        ,
   input  logic rst_n        ,
   input  logic wren         , 
   input  logic [2:0] func3  ,       // Tín hiệu cho phép ghi
   input  logic [31:0] i_sw  ,       // Đầu vào Switches (32-bit)
   output logic [31:0] o_data        // Đầu ra dữ liệu
);

logic [31:0] input_data;

localparam [2:0]  LW  = 3'b010  ,
                  LBU = 3'b100  ,
                  LH  = 3'b001  ,
                  LHU = 3'b101  ,
                  LB  = 3'b000  ;

always_ff @( posedge i_clk or negedge rst_n )begin
    if (!rst_n)
	    input_data <= 32'h0;	    
    else if (wren)
	    input_data <= i_sw;
    else  input_data <= input_data; 
 end	    
  
 always_comb begin
	 case(func3)
            LB  : o_data = {{24{input_data[7]}},input_data[7:0]};
            LBU : o_data = {24'b0,input_data[7:0]};
            LH  : o_data = {{16{input_data[15]}}, input_data[15:0]};
            LHU : o_data = {16'b0,input_data[15:0]};
            LW  : o_data = input_data;
            default: o_data = 32'h0;
        endcase
    end
      
endmodule
