# Loading Programs

## How the CPU gets its program

`instruction_memory.sv` initializes its ROM once, at elaboration time:

```systemverilog
logic [DATA_WIDTH-1:0] mem [0:(2**ADDR_WIDTH)-1];

initial begin
  $readmemh("machine_code.mem", mem);
end
```

`mem/machine_code.mem` is a plain text file of hex bytes, one per line,
which `$readmemh` loads into the ROM array in order.

## The rebuild you can't skip

Because `$readmemh` runs at **elaboration time**, editing
`machine_code.mem` and re-running only **Implementation** will silently
keep running the *old* program — the new file contents aren't picked up
until **Synthesis** re-elaborates the design. The full cycle after any
program change is:

**Synthesis → Implementation → Generate Bitstream → Program Device**

This is the main practical annoyance of this workflow, and the motivation
for the VIO-based instruction loader described in [Roadmap](Roadmap.md),
which would let a new program be written directly into memory over JTAG
without touching synthesis at all.

## Encoding a program by hand

Each instruction is 4 bytes, written **most-significant byte first**, one
byte per line, matching how `instruction_memory.sv` reassembles them:

```systemverilog
imem_data = { mem[addr], mem[addr+1], mem[addr+2], mem[addr+3] };
```

So for a 32-bit instruction word `0xAABBCCDD`, the four lines in the `.mem`
file are `AA`, `BB`, `CC`, `DD` in that order.

## Current test program (`mem/machine_code.mem`)

This program exercises both the ALU/register file and the GPIO peripheral
in one run:

| Address | Assembly | Encoding | Effect |
|---|---|---|---|
| `0x00` | `addi x1, x0, 5` | `00500093` | `x1 = 5` |
| `0x04` | `addi x2, x0, 7` | `00700113` | `x2 = 7` |
| `0x08` | `add  x3, x1, x2` | `002081B3` | `x3 = 12` |
| `0x0C` | `lui  x4, 1` | `00001237` | `x4 = 0x1000` (GPIO base) |
| `0x10` | `addi x5, x0, 2` | `00200293` | `x5 = 2` (LED1 pattern) |
| `0x14` | `sw   x5, 0(x4)` | `00522023` | write `x5` to GPIO → LEDs |
| `0x18` | `jal  x0, 0` | `0000006F` | infinite loop (halt in place) |

### Verifying it on hardware

- Watch `dbg_x1`, `dbg_x2`, `dbg_x3` on the ILA — they should settle at
  `5`, `7`, and `12` respectively and hold.
- Watch the onboard LEDs — LED1 should turn on after the `sw`.
- The PC should visit all seven addresses (`0x00`–`0x18`) and then hold at
  `0x18`, since `jal x0, 0` is an unconditional jump to its own address
  (a "spin here forever" idiom) — this shows up on the ILA as `pc` settling
  at `0x18` rather than a fault.
- `rd_addr` returning to `0` at the very end is `jal x0, 0` legitimately
  encoding `rd = x0` (the jump-and-link result is discarded) — not a reset
  or a restart.
- The `sw` instruction does **not** produce a register-file write pulse
  (`rf_wr_en`) — that's expected, stores don't write back to a register.

### Earlier variant (`mem/machine_code_with_halt.mem`)

A smaller, earlier test program used while first bringing up the debug
infrastructure, before the GPIO peripheral existed. Kept here mainly as a
minimal known-good program to fall back to if a larger test isn't behaving
as expected.

## Related

See [Memory Map](Memory-Map.md) for what address `0x1000` actually decodes
to, and [Roadmap](Roadmap.md) for the planned faster way to load new
programs.
