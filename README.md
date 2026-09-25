# RISC-V 32I Single-Cycle CPU on KR260 (Kria K26 SOM)

A tutorial-style walkthrough of bringing up a single-cycle RV32I processor on
AMD/Xilinx's KR260 Robotics Starter Kit — from RTL, to a live JTAG/ILA/VIO
debug setup, to a memory-mapped GPIO peripheral driving the board's onboard
LEDs.

---

## What's in this repo

The CPU datapath (`rtl/risc_pkg.sv`, `fetch.sv`, `decode.sv`,
`register_file.sv`, `control.sv`, `branch_control.sv`, `alu.sv`,
`data_memory.sv`, `instruction_memory.sv`, and the core of `top.sv`) is based
on Yoav Dror's single-cycle RV32I design from his
[*Mastering RISC-V in SystemVerilog*](https://www.udemy.com/course/mastering-risc-v-in-systemverilog-from-isa-to-working-cpu/)
course. All credit for the core ISA implementation goes there — check that
repository's license before reusing or republishing this code further.

What this repo adds on top of that base is the KR260-specific bring-up work:

- A board-level wrapper (`board/top_kr260_riscv.sv`) with VIO-driven
  reset/run control
- A memory-mapped bus (`rtl/mem_bus.sv`) and GPIO peripheral (`rtl/gpio.sv`)
  that drive the board's two onboard LEDs
- Live register-file visibility on the ILA via hierarchical `mark_debug`
  taps, with no extra ports needed
- Vivado constraints (`constraints/kr260_led_counter.xdc`) for the KR260's
  clock and LED pins
- A worked example program (`mem/machine_code.mem`) exercising both the ALU
  and the GPIO peripheral

---

## Repository layout

```
git_riscv/
├── rtl/
│   ├── risc_pkg.sv            # shared types: opcodes, ALU ops, mem sizes, wb-src
│   ├── fetch.sv                # PC-driven instruction fetch
│   ├── decode.sv                # instruction decode (R/I/S/B/U/J)
│   ├── register_file.sv        # 32x32 register file
│   ├── control.sv               # main control unit
│   ├── branch_control.sv       # branch condition evaluation
│   ├── alu.sv                    # arithmetic/logic unit
│   ├── data_memory.sv          # byte-addressable data RAM
│   ├── instruction_memory.sv   # $readmemh-initialized instruction ROM
│   ├── mem_bus.sv               # address decoder: RAM vs. GPIO
│   ├── gpio.sv                   # memory-mapped LED output register
│   └── top.sv                    # top-level datapath + debug taps
├── board/
│   └── top_kr260_riscv.sv      # KR260 wrapper: VIO reset/run, LED port
├── constraints/
│   └── kr260_led_counter.xdc   # clock + LED pin constraints
├── sim/
│   └── test_bench.sv           # core-only testbench (pre-GPIO)
└── mem/
    ├── machine_code.mem            # current test program (see below)
    └── machine_code_with_halt.mem  # earlier, simpler test program
```

---

## Hardware target

- **Board:** KR260 Robotics Starter Kit (Kria K26 SOM, `xck26-sfvc784-2LV-c`)
- **Clock:** 25 MHz, `PACKAGE_PIN C3`, `LVCMOS18`
- **Outputs used:** onboard LEDs DS7/DS8 → `PACKAGE_PIN F8` / `E8`, `LVCMOS18`

---

## Architecture

- **ISA:** RV32I — R, I, S, B, U and J instruction types
- **Execution model:** single-cycle (one instruction retires per clock)
- `top.sv` has only `clk`/`reset_n` at its ports. With nothing driven to a
  physical pin, synthesis has no reason to keep any of the internal logic —
  the `(* mark_debug = "true" *)` attributes on `pc`, `instruction`,
  `opcode`, `rd_addr`, `wr_data`, `rf_wr_en`, `alu_res` and `branch_taken`
  are what force retention *and* what the ILA watches.
- Three extra debug taps reach directly into the register file
  (`u_register_file.regs[1..3]`) so `x1`–`x3` stay visible on the ILA for
  the full run, not just the one cycle they're written.

### Memory map (`mem_bus.sv`)

Decoded on `dmem_addr[15:8]`:

| Range           | Device | Notes                                   |
|-----------------|--------|------------------------------------------|
| `0x00`          | RAM    | `data_memory`, 64 bytes                 |
| `0x10` (0x1000) | GPIO   | single write-through register → LEDs    |

---

## Build flow (Vivado)

1. Create a Vivado project targeting `xck26-sfvc784-2LV-c`.
2. Add everything under `rtl/` and `board/top_kr260_riscv.sv` as design
   sources (mark them as **SystemVerilog**, not Verilog, in Source Node
   Properties — Vivado sometimes misdetects this).
3. Add `constraints/kr260_led_counter.xdc`.
4. Create a `vio_0` IP: 0 input probes, 1 output probe (drives
   `reset_n`/run-halt on the core).
5. Run **Synthesis**, then **Tools → Set Up Debug** and select the
   `mark_debug` signals you want on the ILA (including `dbg_x1`/`dbg_x2`/
   `dbg_x3`), then **Implementation** and **Generate Bitstream**.
6. Program the device, open the Hardware Manager dashboard, and use the
   VIO to release `reset_n` (drive `probe_out0` to `1`) once you're ready
   for the core to run.

---

## Loading a program

`instruction_memory.sv` initializes its ROM with `$readmemh("machine_code.mem", mem)`
at **elaboration time**, so changing `mem/machine_code.mem` requires a full
**Synthesis → Implementation → Bitstream** rebuild — a plain re-run of
Implementation alone won't pick up the change.

### Current test program (`mem/machine_code.mem`)

```asm
addi x1, x0, 5      # x1 = 5
addi x2, x0, 7      # x2 = 7
add  x3, x1, x2     # x3 = 12
lui  x4, 1          # x4 = 0x1000  (GPIO device base)
addi x5, x0, 2       # x5 = 2       (LED pattern: LED1 on)
sw   x5, 0(x4)       # write x5 to GPIO -> LEDs
jal  x0, 0           # infinite loop (halt)
```

Watch `dbg_x1`, `dbg_x2`, `dbg_x3` on the ILA to confirm the add, and the
onboard LEDs to confirm the GPIO write.

---

## Status / roadmap

**Working:**
- Live register-file debug on the ILA
- Memory-mapped GPIO driving both onboard LEDs
- Combined ALU + GPIO test program, verified on hardware

**Not yet implemented:**
- A JTAG/VIO-driven instruction-memory loader, to reload programs without a
  full resynthesis cycle
- UART over the PMOD USB-UART module

---

## Credits

- **Core RV32I single-cycle datapath:** Yoav Dror — *Mastering RISC-V in
  SystemVerilog* course.
- **KR260 board bring-up, GPIO peripheral, memory bus, and JTAG/ILA/VIO
  debug workflow:** added for this tutorial.
