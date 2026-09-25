# Credits

## Core RV32I single-cycle datapath

The processor core — `risc_pkg.sv`, `fetch.sv`, `decode.sv`,
`register_file.sv`, `control.sv`, `branch_control.sv`, `alu.sv`,
`data_memory.sv`, `instruction_memory.sv`, and the datapath body of
`top.sv` — is based on **Yoav Dror**'s single-cycle RV32I design from his
course, [*Mastering RISC-V in SystemVerilog*](https://www.udemy.com/course/mastering-risc-v-in-systemverilog-from-isa-to-working-cpu/).

All credit for the ISA implementation and datapath design belongs there.
**Check that original repository's license before reusing or republishing
this code further** — this wiki does not establish or change any licensing
terms for the core CPU.

## KR260 bring-up (this repo's own contribution)

Everything specific to getting the core running on a KR260 board was built
for this tutorial:

- The board-level wrapper and VIO reset/run control (`board/top_kr260_riscv.sv`)
- The memory bus and GPIO peripheral (`rtl/mem_bus.sv`, `rtl/gpio.sv`)
- The KR260 pin/clock constraints (`constraints/kr260_led_counter.xdc`)
- The JTAG/ILA/VIO debug workflow, including the hierarchical
  register-file debug taps (see [Debug Workflow](Debug-Workflow.md))
- The worked test program and this wiki's documentation
