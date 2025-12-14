module GHR (
input logic i_clk         ,
input logic i_rst_n       ,
input logic predict_taken ,
input logic branch_pre    ,
output logic [31:0] GHR

);

always_ff @(posedge i_clk or negedge i_rst_n) begin
     if (!i_rst_n)
        GHR <= 32'h0; 
     else if (branch_pre)  
        GHR <= {GHR[30:0], predict_taken } ;
     else GHR <= GHR;
end

endmodule