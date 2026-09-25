# Roadmap

## Done

- Live register-file visibility on the ILA (`dbg_x1`–`dbg_x3`), via
  hierarchical `mark_debug` taps — see [Debug Workflow](Debug-Workflow.md)
- Memory-mapped GPIO peripheral driving both onboard LEDs — see
  [Memory Map](Memory-Map.md)
- A combined ALU + GPIO test program, verified on hardware — see
  [Loading Programs](Loading-Programs.md)

## Designed, not yet built: JTAG/VIO instruction loader

**Problem:** changing `mem/machine_code.mem` currently requires a full
Synthesis → Implementation → Bitstream → Program cycle, because
`$readmemh` is evaluated at elaboration time (see
[Loading Programs](Loading-Programs.md)). That's slow for something as
simple as trying a different test program.

**Design:** add a debug write port directly into `instruction_memory.sv`,
driven by a second VIO IP, so a new program can be written into the live
ROM over JTAG without ever re-synthesizing:

```systemverilog
module instruction_memory #(
  parameter ADDR_WIDTH = 7,
  parameter DATA_WIDTH = 8
)(
  input  logic                    clk,
  input  logic                    imem_req,
  input  logic [31:0]             imem_addr,
  output logic [31:0]             imem_data,

  // debug write port
  input  logic                    dbg_wr_en,
  input  logic [ADDR_WIDTH-1:0]   dbg_wr_addr,
  input  logic [DATA_WIDTH-1:0]   dbg_wr_data
);
  ...
  always_ff @(posedge clk) begin
    if (dbg_wr_en)
      mem[dbg_wr_addr] <= dbg_wr_data;
  end
  ...
endmodule
```

A new `vio_loader` IP (0 input probes, 3 output probes — 1-bit `wr_en`,
7-bit `wr_addr`, 8-bit `wr_data`) drives these three signals from
`top_kr260_riscv.sv`, and a Tcl script walks a byte array, pulsing
`wr_en` once per byte to load a whole program:

```tcl
set loader [get_hw_vios -filter {CELL_NAME =~ "*u_vio_loader*"}]
set en   [get_hw_probes probe_out0 -of_objects $loader]
set addr [get_hw_probes probe_out1 -of_objects $loader]
set data [get_hw_probes probe_out2 -of_objects $loader]

set a 0
foreach b $bytes {
    set_property OUTPUT_VALUE $a $addr
    set_property OUTPUT_VALUE $b $data
    set_property OUTPUT_VALUE 1  $en
    commit_hw_vio $loader
    set_property OUTPUT_VALUE 0  $en
    commit_hw_vio $loader
    incr a
}
```

The reset VIO would typically be held low while loading, then released once
the new program is fully written, so the core doesn't start executing a
half-loaded program mid-load.

**Status:** designed and reasoned through, but not yet implemented in this
repo's RTL — the current build still uses the plain `.mem`-file-and-
resynthesize flow.

## Planned: UART over the PMOD USB-UART module

The KR260's PMOD connector can host a PMOD USB-UART module for a serial
interface to the core, using the standard PMOD UART pinout (RXD/TXD/~CTS/
~RTS/GND/VCC, 3.3V logic — verify against the specific module's datasheet
before wiring). This would follow the same pattern as the GPIO peripheral:
a new device at (for example) `0x20` in `mem_bus.sv`'s address map, with its
own peripheral module (`uart.sv`) handling the actual serialization. Not
yet implemented in this repo.

## Related

[Memory Map](Memory-Map.md) shows how a new peripheral slots into the
existing address-decode pattern, which both of the above would follow.
