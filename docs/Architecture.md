# Architecture

## ISA and execution model

- **ISA:** RV32I — R, I, S, B, U and J instruction types
- **Execution model:** single-cycle. Every instruction fetches, decodes,
  executes, accesses memory and writes back within one clock period; there
  is no pipelining and no multi-cycle sequencing.

## Shared definitions

`risc_pkg.sv` centralizes everything the other modules need to agree on:
opcodes, ALU operation encodings, memory access sizes, and the write-back
source selector (`wb_src_t`) used to choose what gets written into the
register file (ALU result, memory read data, immediate, or `pc+4`).

## Datapath, module by module

| Module | Role |
|---|---|
| `instruction_memory.sv` | Byte-addressable ROM, initialized via `$readmemh("machine_code.mem", mem)`. See [Loading Programs](Loading-Programs.md) for why editing it needs a full rebuild. |
| `fetch.sv` | Drives `imem_addr` from the current `pc` and requests the next instruction. |
| `decode.sv` | Splits the 32-bit instruction into `opcode`/`funct3`/`funct7`/register fields, and produces the sign/zero-extended `immediate` plus one-hot format flags (`r_type`, `i_type`, `s_type`, `b_type`, `u_type`, `j_type`). |
| `control.sv` | The main control unit — maps `opcode`/`funct3`/`funct7` and the format flags to every downstream control signal: ALU operation, operand-select muxes, memory request/size/write-enable, and the register write-back source. |
| `register_file.sv` | 32×32-bit register file, `x0`–`x31`. Two combinational read ports (`rs1_data`, `rs2_data`), one synchronous write port. |
| `branch_control.sv` | Evaluates the branch condition (`funct3`-selected comparison of `rs1_data`/`rs2_data`) and produces `branch_taken`. |
| `alu.sv` | Executes the selected `alu_op` on `alu_a`/`alu_b`. |
| `data_memory.sv` | Byte-addressable data RAM — 64 bytes in this build, reached through `mem_bus.sv` rather than directly (see [Memory Map](Memory-Map.md)). |
| `mem_bus.sv` / `gpio.sv` | KR260-specific addition: routes `top`'s data-memory port between RAM and the onboard-LED GPIO register. Not part of the original core design — see [Memory Map](Memory-Map.md). |
| `top.sv` | Wires all of the above together, holds the PC/reset logic, and carries the `(* mark_debug = "true" *)` taps used by the ILA (see [Debug Workflow](Debug-Workflow.md)). |

## PC and control flow

```
next_seq_pc = pc + 4
next_pc     = (branch_taken | pc_sel) ? {alu_res[31:1], 1'b0} : next_seq_pc
pc         <= next_pc   (on every clock, once out of reset)
```

`pc_sel` covers unconditional jumps (`jal`/`jalr`); `branch_taken` covers
conditional branches. Both redirect the PC to the ALU result (used as the
branch/jump target address), with bit 0 forced low per the RISC-V spec.

## Why `top.sv` needs debug attributes at all

`top` only exposes `clk` and `reset_n` at its ports on the KR260 build — it
drives nothing else out to a pin except (after the GPIO addition) `led_out`.
With no other observable output, Vivado's synthesis has no reason to keep
any of the internal datapath logic; it would optimize the entire core away
as dead logic. The `(* mark_debug = "true" *)` attributes in `top.sv` are
what force retention, and they double as exactly the signals worth watching
on the ILA. See [Debug Workflow](Debug-Workflow.md) for the full list and
how to wire them into a live dashboard.
