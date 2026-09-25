// --------------------------------------------------------
// mem_bus - address decoder / peripheral interconnect
// --------------------------------------------------------
// Sits between the CPU's data-memory port (dmem_*, unchanged from
// top.sv) and the actual memory-mapped devices. Nothing in fetch,
// decode, register_file, control, branch_control or alu changes --
// this only replaces the direct data_memory instantiation that used
// to sit at the bottom of top.sv.
//
// Address map (decoded on dmem_addr[15:8]):
//   0x00  RAM   (data_memory, same 64-byte RAM as before)
//   0x10  GPIO  (0x0000_1000) -- single output register, see gpio.sv
// --------------------------------------------------------
import risc_pkg::*;

module mem_bus (
  input  logic         clk,
  input  logic         reset_n,

  // CPU side -- identical signals top.sv already drove into
  // data_memory directly before this module existed
  input  logic         dmem_req,
  input  logic         dmem_wr_en,
  input  mem_size_t    dmem_data_size,
  input  logic [31:0]  dmem_addr,
  input  logic [31:0]  dmem_wr_data,
  input  logic         dmem_zero_extend,
  output logic [31:0]  dmem_rd_data,

  // physical peripheral pins
  output logic [1:0]   led_out
);

  localparam logic [7:0] DEV_RAM  = 8'h00;
  localparam logic [7:0] DEV_GPIO = 8'h10;

  wire [7:0] dev_sel = dmem_addr[15:8];

  wire ram_sel  = dmem_req && (dev_sel == DEV_RAM);
  wire gpio_sel = dmem_req && (dev_sel == DEV_GPIO);

  logic [31:0] ram_rd_data, gpio_rd_data;

  data_memory u_data_memory (
    .clk               (clk),
    .dmem_req          (ram_sel),
    .dmem_wr_en        (dmem_wr_en),
    .dmem_data_size    (dmem_data_size),
    .dmem_addr         (dmem_addr),
    .dmem_wr_data      (dmem_wr_data),
    .dmem_zero_extend  (dmem_zero_extend),
    .dmem_rd_data      (ram_rd_data)
  );

  gpio #(.WIDTH(2)) u_gpio (
    .clk      (clk),
    .reset_n  (reset_n),
    .req      (gpio_sel),
    .wr_en    (dmem_wr_en),
    .wr_data  (dmem_wr_data),
    .rd_data  (gpio_rd_data),
    .gpio_out (led_out)
  );

  always_comb begin
    case (dev_sel)
      DEV_RAM:  dmem_rd_data = ram_rd_data;
      DEV_GPIO: dmem_rd_data = gpio_rd_data;
      default:  dmem_rd_data = 32'd0;
    endcase
  end

endmodule