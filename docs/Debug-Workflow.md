# Debug Workflow

This design has no UART, no display, and (until the GPIO addition) no
output pins at all — so the ILA (Integrated Logic Analyzer) and VIO
(Virtual I/O) are the only window into what the CPU is doing. This page
covers how that visibility is wired up.

## The core problem: nothing is observable by default

`top.sv` only exposes `clk`/`reset_n` (and, after the GPIO addition,
`led_out`) at its ports. With nothing else driven to a physical pin,
Vivado's synthesis has no reason to retain any of the internal datapath —
it will optimize the whole core away as unused logic.

The fix is `(* mark_debug = "true" *)` attributes, which force Vivado to
keep a signal and offer it in the **Set Up Debug** wizard, whether or not it
ever reaches a real pin.

## What's tapped, and why

In `top.sv`:

| Signal | What it tells you |
|---|---|
| `pc`, `instruction` | what's fetched each cycle |
| `opcode` | which instruction format is executing |
| `rd_addr`, `wr_data`, `rf_wr_en` | what gets written to the register file, and when (e.g. `rf_wr_en=1, rd_addr=3, wr_data=12` is `add x3,x1,x2` retiring) |
| `alu_res` | the ALU's result this cycle |
| `branch_taken` | whether a branch/jump redirected the PC |

## Watching specific registers continuously

`rd_addr`/`wr_data`/`rf_wr_en` only show a register's value **the one cycle
it's written**. To watch a register's value hold steady across the whole
run (useful for confirming a final result, like `x3` after an `add`), `top.sv`
adds hierarchical debug taps directly into the register file's internal
array:

```systemverilog
(* mark_debug = "true" *) wire [31:0] dbg_x1 = u_register_file.regs[1];
(* mark_debug = "true" *) wire [31:0] dbg_x2 = u_register_file.regs[2];
(* mark_debug = "true" *) wire [31:0] dbg_x3 = u_register_file.regs[3];
```

These aren't real ports or signals anywhere else in the design — just new
wires driven by a hierarchical reference into `u_register_file`, with
`mark_debug` forcing Vivado to keep them and offer them for the ILA exactly
like any other tapped signal. Add or remove lines here for whichever
registers matter to the program you're running.

## Run/halt control via VIO

See [Build Guide](Build-Guide.md) step 4 — `top_kr260_riscv.sv` instantiates
a `vio_0` IP with 1 output probe driving `reset_n`. This means:

- **`probe_out0 = 0`** (power-up default): the core sits held in reset at
  `RESET_PC`, giving you a clean starting point to arm the ILA trigger
  before anything runs.
- **`probe_out0 = 1`**: reset releases and the core starts executing.

No extra logic is needed for this — it falls out of driving `reset_n` from
a VIO instead of a fixed constant.

## Getting new probes to actually show up

Adding a new `mark_debug` signal (or changing the debug-tap list) needs a
full cycle, not just a re-implementation:

1. Re-run **Synthesis**.
2. Re-run **Tools → Set Up Debug** — pick the signals again, including any
   new ones.
3. Re-run **Implementation** and **Generate Bitstream**.
4. **Program the device** with the new bitstream.
5. In the Hardware Manager, if a signal you selected still isn't visible in
   the Waveform/Trigger Setup pane, that pane shows a **manually curated
   display list**, separate from what the ILA core actually has probes for.
   Click the **`+` ("Add Probes")** button and add the new probes to the
   view explicitly — this is easy to miss and was the actual fix the one
   time probes seemed to "disappear" despite the hardware being programmed
   correctly.

You can always check the ground truth of what the live ILA core actually
has, independent of what the GUI is currently displaying, with:

```tcl
get_hw_probes -of_objects [get_hw_ilas -of_objects [get_hw_devices xck26_0]]
```

If that Tcl command lists your signal but the dashboard doesn't show it,
it's the display-list issue above, not a synthesis/programming problem.

## Related

See [Troubleshooting](Troubleshooting.md) for the specific errors this
setup can produce (stale debug-core bindings, PL power issues, and so on),
and [Roadmap](Roadmap.md) for the planned VIO-based instruction loader,
which builds on this same debug infrastructure.
