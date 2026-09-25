# Getting Started

## Hardware

- **Board:** KR260 Robotics Starter Kit (Kria K26 SOM, `xck26-sfvc784-2LV-c`)
- A **JTAG connection** to the board (the onboard USB-JTAG is enough — no
  external programmer needed)
- Nothing else is required for the base RTL in this repo: the design only
  drives the two onboard LEDs (DS7/DS8) as output, and takes its 25 MHz
  clock from the board itself.

## Software

- **Vivado** (this project was built with 2024.1; other recent versions
  should work but pin/IP details may shift slightly)
- A **serial console** tool (e.g. `screen`) if you ever need to check the
  KR260's Linux boot over UART — useful for diagnosing power/boot issues,
  see [Troubleshooting](Troubleshooting.md)

## Repo layout

```
git_riscv/
├── rtl/
│   ├── risc_pkg.sv            shared types: opcodes, ALU ops, mem sizes, wb-src
│   ├── fetch.sv                 PC-driven instruction fetch
│   ├── decode.sv                 instruction decode (R/I/S/B/U/J)
│   ├── register_file.sv         32x32 register file
│   ├── control.sv                main control unit
│   ├── branch_control.sv        branch condition evaluation
│   ├── alu.sv                     arithmetic/logic unit
│   ├── data_memory.sv           byte-addressable data RAM
│   ├── instruction_memory.sv    $readmemh-initialized instruction ROM
│   ├── mem_bus.sv                address decoder: RAM vs. GPIO
│   ├── gpio.sv                    memory-mapped LED output register
│   └── top.sv                     top-level datapath + debug taps
├── board/
│   └── top_kr260_riscv.sv       KR260 wrapper: VIO reset/run, LED port
├── constraints/
│   └── kr260_led_counter.xdc    clock + LED pin constraints
├── sim/
│   └── test_bench.sv            core-only testbench (pre-GPIO)
├── mem/
│   ├── machine_code.mem             current test program
│   └── machine_code_with_halt.mem   earlier, simpler test program
└── docs/                         this wiki
```

## Where to go next

Read **[Architecture](Architecture.md)** first if you want to understand the
CPU itself, or skip straight to **[Build Guide](Build-Guide.md)** if you just
want a bitstream running on the board.
