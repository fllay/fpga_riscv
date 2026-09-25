// --------------------------------------------------------
// GPIO - memory-mapped output register
// --------------------------------------------------------
// One 32-bit write-through register. Only the bottom WIDTH bits are
// wired to a physical pin (WIDTH=2 for the KR260's two onboard LEDs),
// but the full 32-bit value is readable back for verification.
//
// Register map (single register, offset 0 within this device):
//   sw  -> writes gpio_out
//   lw  -> reads back the last written value
// --------------------------------------------------------
module gpio #(
    parameter WIDTH = 2
)(
    input  logic         clk,
    input  logic         reset_n,

    // already address-decoded/selected by mem_bus
    input  logic         req,
    input  logic         wr_en,
    input  logic [31:0]  wr_data,
    output logic [31:0]  rd_data,

    output logic [WIDTH-1:0] gpio_out
);

  logic [31:0] out_reg;

  always_ff @(posedge clk or negedge reset_n) begin
    if (!reset_n)
      out_reg <= 32'd0;
    else if (req && wr_en)
      out_reg <= wr_data;
  end

  assign gpio_out = out_reg[WIDTH-1:0];
  assign rd_data  = out_reg;

endmodule