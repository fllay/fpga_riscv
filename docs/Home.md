# RISC-V on KR260 — Wiki

A tutorial-style knowledge base for bringing up a single-cycle RV32I
processor on AMD/Xilinx's KR260 Robotics Starter Kit, from RTL to a live
JTAG/ILA/VIO debug session to a working GPIO peripheral.

This wiki goes deeper than the top-level `README.md` — treat the README as
the quick overview, and these pages as the full walkthrough.

## Pages

- **[Getting Started](Getting-Started.md)** — hardware/software you need, and
  how the repo is laid out
- **[Architecture](Architecture.md)** — the RV32I datapath, module by module
- **[Memory Map](Memory-Map.md)** — how `mem_bus.sv` routes RAM vs. GPIO
  accesses
- **[Build Guide](Build-Guide.md)** — step-by-step Vivado project setup
- **[Debug Workflow](Debug-Workflow.md)** — JTAG/ILA/VIO setup, register-file
  visibility, and the VIO run/halt trick
- **[Loading Programs](Loading-Programs.md)** — encoding instructions,
  `$readmemh` timing, and a walkthrough of the current test program
- **[Troubleshooting](Troubleshooting.md)** — real errors hit during this
  bring-up and how they were resolved
- **[Roadmap](Roadmap.md)** — what's designed but not yet built (VIO
  instruction loader, PMOD UART)
- **[Credits](Credits.md)** — attribution for the base CPU design

## Quick orientation

```
git_riscv/
├── rtl/          the CPU + peripherals (see Architecture, Memory Map)
├── board/        KR260-specific top-level wrapper
├── constraints/  pin/clock constraints for the KR260
├── sim/          a core-only testbench
├── mem/          machine-code programs the CPU boots from
└── docs/         you are here
```

If you just want to get a bitstream running on a board, start at
**[Getting Started](Getting-Started.md)** and follow the pages in order.
