module imem (
    input logic [31:0] pc,
    output logic [31:0] instr
);
    logic [31:0] mem [0:2047]; 

    initial begin
        $readmemh("../02_test/isa_4b.hex", mem);
    end
   
 always_comb begin
      instr = mem[pc[31:2]]; 
end
endmodule

