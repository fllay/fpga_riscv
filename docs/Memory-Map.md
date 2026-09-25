# Memory Map

The original core design gave the CPU's data-memory port a single,
direct connection to `data_memory.sv`. Adding the onboard LEDs meant
introducing a second memory-mapped device, so `mem_bus.sv` sits between
`top.sv`'s data-memory port and the actual devices, deciding which one a
given access is for.

Nothing in `fetch`, `decode`, `register_file`, `control`, `branch_control`
or `alu` changes because of this — `mem_bus` is a drop-in replacement for
the `data_memory` instantiation that used to sit directly at the bottom of
`top.sv`.

## Address decode

`mem_bus` decodes on the upper byte of the data address, `dmem_addr[15:8]`:

| `dmem_addr[15:8]` | Device | Address range | Notes |
|---|---|---|---|
| `0x00` | RAM (`data_memory`) | `0x0000_0000`–`0x0000_003F` | 64 bytes; the module itself only decodes its own low 6 bits internally |
| `0x10` | GPIO (`gpio`) | `0x0000_1000` | single 32-bit write-through register |

Any other value returns `32'd0` on read and writes nowhere.

## How a write reaches the LEDs

1. The CPU executes `sw rX, 0(rY)` with `rY` holding `0x1000`.
2. `top.sv` drives `dmem_addr = 0x1000`, `dmem_wr_data = <rX>`, `dmem_req = 1`,
   `dmem_wr_en = 1` into `mem_bus`.
3. `mem_bus` computes `dev_sel = dmem_addr[15:8] = 0x10`, which matches
   `DEV_GPIO`, so `gpio_sel` (and not `ram_sel`) is asserted for that cycle.
4. Inside `gpio.sv`, `req && wr_en` is true, so `out_reg` latches
   `dmem_wr_data` on the next clock edge.
5. `gpio_out = out_reg[WIDTH-1:0]` (`WIDTH = 2`) drives `led_out`, which
   `top_kr260_riscv.sv` connects straight to the board's DS7/DS8 LEDs.

## Reads

`mem_bus` muxes `dmem_rd_data` from whichever device was selected:

```systemverilog
case (dev_sel)
  DEV_RAM:  dmem_rd_data = ram_rd_data;
  DEV_GPIO: dmem_rd_data = gpio_rd_data;
  default:  dmem_rd_data = 32'd0;
endcase
```

Reading back from `0x1000` returns the full 32-bit value last written to the
GPIO register (not just the 2 bits actually wired to LEDs) — handy for
verifying a write actually happened, from software or from the ILA, without
needing a scope on the pins.

## Extending the map

Adding a new peripheral means: give it its own `DEV_*` address, add a
`_sel` qualifier (`dmem_req && dev_sel == DEV_*`), instantiate it in
`mem_bus.sv`, and add a case arm to the read-data mux. See
[Roadmap](Roadmap.md) for the planned UART peripheral, which follows this
same pattern at `0x20`.
