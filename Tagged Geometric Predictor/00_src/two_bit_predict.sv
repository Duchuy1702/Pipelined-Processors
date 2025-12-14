module two_bit_predictor (
  input logic  taken           ,
  input logic [1:0] state      ,
  output logic [1:0] next_state,
  output logic valid_data

  );

  parameter STRONG_NOT_TAKEN = 2'b00;
  parameter WEAK_NOT_TAKEN   = 2'b01;
  parameter WEAK_TAKEN       = 2'b10;
  parameter STRONG_TAKEN     = 2'b11;

  always_comb begin
    case (state)
      STRONG_TAKEN :begin
          next_state      = (taken) ? STRONG_TAKEN : WEAK_TAKEN;
          valid_data = 1;
        end
      WEAK_TAKEN : begin
          next_state      = (taken) ? STRONG_TAKEN : WEAK_NOT_TAKEN;
          valid_data = 1;
        end
      WEAK_NOT_TAKEN :begin
          next_state      = (taken) ? WEAK_TAKEN : STRONG_NOT_TAKEN;
          valid_data = 0;
        end
      STRONG_NOT_TAKEN : begin
          next_state      = (taken) ? WEAK_NOT_TAKEN : STRONG_NOT_TAKEN;
          valid_data = 0;
        end
      default : begin
          next_state      = STRONG_NOT_TAKEN;
          valid_data = 0;
        end
    endcase
  end


endmodule