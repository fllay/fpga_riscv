// top_kr260_riscv.sv
// Board-level wrapper for `top` (the single-cycle RISC-V core) on the KR260.
//
// `top` has only clk/reset_n at its ports -- nothing else is observable
// from outside the chip. Two things follow from that, both handled here:
//
//   1. reset_n is driven by a VIO, the same trick used for the counter's
//      reset -- except here it doubles as a genuinely useful run/halt
//      control for free: a VIO output probe defaults to 0 at power-up, so
//      the core sits held in reset (halted at RESET_PC) the moment it's
//      programmed, until you explicitly drive the probe to 1 from Vivado.
//      No extra logic needed for that behavior.
//   2. With nothing wired to an output pin, synthesis has no reason to
//      retain any of the core's internal logic on its own -- see the
//      (* mark_debug *) attributes added directly in the accompanying
//      top.sv, which are what keeps the design from being optimized away
//      as well as what the ILA watches.
`timescale 1ns/1ps

module top_kr260_riscv (
    input wire clk,    // 25 MHz, PACKAGE_PIN C3
    output wire [1:0] led_out  // onboard LEDs, PACKAGE_PIN F8 / E8
);

    // ---- run/halt control, driven live over JTAG via a VIO ----
    // This vio_0 is customized with 0 input probes / 1 output probe.
    // probe_out0 = 0 (VIO's power-up default) -> held in reset, core
    //                halted at RESET_PC
    // probe_out0 = 1                          -> reset released, core runs
    wire vio_run;
    vio_0 u_vio (
        .clk        (clk),
        .probe_out0 (vio_run)
    );

    top #(
        .RESET_PC (32'h0000)
    ) u_top (
        .clk     (clk),
        .reset_n (vio_run),
        .led_out  (led_out)
    );

endmodule
