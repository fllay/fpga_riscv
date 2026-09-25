# Troubleshooting

Real errors hit while bringing this design up on a KR260, and how they were
resolved. Kept here so the same afternoon isn't lost twice.

## "Probes not appearing" in the ILA dashboard

Symptom: after adding new `mark_debug` signals, rebuilding, and
reprogramming, the Waveform/Trigger Setup pane still shows only the old
signal list.

This turned out to be layered — check each in order:

1. **Reattach the probes file.** Use "Specify Debug Probes File" and point
   it at the freshly generated `.ltx`.
2. **Confirm a full rebuild actually happened**: Synthesis → Set Up Debug →
   Implementation → Bitstream → **Program Device**. A stale bitstream still
   programmed from before the RTL change will obviously lack the new
   probes.
3. **Check the hardware directly**, independent of the GUI:
   ```tcl
   get_hw_probes -of_objects [get_hw_ilas -of_objects [get_hw_devices xck26_0]]
   ```
   If this lists your signal, the ILA core genuinely has it.
4. **The actual fix, if step 3 succeeds but the dashboard still doesn't show
   it**: the Waveform/Trigger Setup pane displays a manually curated list of
   probes, separate from everything the core has. Click the **`+` ("Add
   Probes")** button and add the new probes to the view. See
   [Debug Workflow](Debug-Workflow.md).

## `[Labtools 27-3421] PL Power Status OFF, cannot connect PL TAP`

The FPGA fabric is genuinely unreachable over JTAG — this is a board
power-sequencing issue, not a bitstream/probe problem. On the KR260, PL
(fabric) power is gated on PS (processor system) boot progress, so if the
PS hasn't booted (or crashed partway through), the PL never powers up and
JTAG can't reach it.

Diagnose via the board's serial console (typically `ttyUSB1`–`ttyUSB3` at
115200 baud, e.g. `screen /dev/ttyUSB1 115200`) to see where boot is
stalling. If the SD card image is corrupted (for example after an unclean
shutdown), reflashing it with a fresh Ubuntu image (via Raspberry Pi
Imager, image from `ubuntu.com/download/amd`) and re-booting resolves it.

## `'logic' is an unknown type` / `syntax error near '@'`

Misleading — the actual cause is that the file is being compiled as plain
Verilog instead of SystemVerilog, so `logic`, `always_ff`, etc. aren't
recognized. Check **Source Node Properties → File Type** for the affected
file(s) and set it to **SystemVerilog**.

## `[Chipscope 16-213] debug port 'u_ila_0/probe0' has X unconnected channels`

Happens after adding or removing signals from the design (for example,
adding `mem_bus`/`gpio` to the datapath) without refreshing the debug core
binding — the ILA core still expects the old probe widths.

Fix: **Reset Runs** on both `synth_1` and `impl_1`, re-run **Synthesis**,
re-run **Set Up Debug** from scratch (don't reuse the old selection), then
**Implementation** and **Bitstream**.

## Syntax errors on a port list that looks fine

If Vivado flags a file with what looks like a clean port list, check for a
**missing comma** between ports — easy to miss when a comment sits right
after a port declaration, e.g.:

```systemverilog
module top_kr260_riscv (
    input wire clk     // 25 MHz, PACKAGE_PIN C3
    output wire [1:0] led_out   // <-- missing comma above this line
);
```

## `[DRC NSTD-1]` / `[DRC UCIO-1]` — unconstrained I/O

Symptom: bitstream generation fails with unconstrained-pin/IOSTANDARD
errors on a port that you're sure has a `set_property ... [get_ports ...]`
line in the XDC.

Cause: a **port name mismatch** between the XDC and the actual RTL port
name. `get_ports {led[0]}` returns nothing (and `set_property` silently
no-ops) if the design's port is actually named `led_out`, not `led` — easy
to hit if constraints were adapted from an earlier version of the design
(or a different project) without updating the names.

Fix: match the XDC port names exactly to the RTL:
```tcl
set_property PACKAGE_PIN F8 [get_ports {led_out[0]}]
set_property PACKAGE_PIN E8 [get_ports {led_out[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {led_out[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports {led_out[1]}]
```

## "Why did my program only reach 5 instructions?"

Not necessarily a bug — walk the waveform before assuming so. In one case
this turned out to be a correct run misread: `pc` had in fact visited every
address including the final `jal x0, 0`, and `rd_addr` returning to `0` at
the end was that same instruction legitimately encoding `rd = x0` (its
result is discarded), not a restart or fault. See
[Loading Programs](Loading-Programs.md) for how to read the current test
program's waveform correctly.
