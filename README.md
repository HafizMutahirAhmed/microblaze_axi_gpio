# MicroBlaze + AXI GPIO on Opal Kelly XEM7310

A Vivado 2022.2 project that puts a MicroBlaze soft processor and two AXI GPIO
peripherals on an Opal Kelly **XEM7310-A75** (Artix-7 `xc7a75tfgg484-1`).
The host PC sends a 32-bit word over USB (Opal Kelly FrontPanel) into one GPIO.
The other GPIO drives the board's 8 LEDs.

```
 Host PC ──USB──► okHost ──► okWireIn (ep 0x00) ──32b──► input_gpio (all-inputs, 32b)
                                                               │
 200 MHz diff clk ──► clk_wiz_0 ──100 MHz──► MicroBlaze ◄──LMB──► 32 KB BRAM (I + D)
                                                │
                                              mdm_1 (JTAG debug)
                                                               │
                                     led_gpio (all-outputs, 8b) ──► led_tri_o[7:0]
```

## Repository layout

| Path | What it is |
|------|------------|
| `microblaze_axi_gpio.xpr` | Vivado project file |
| `microblaze_axi_gpio.srcs/sources_1/new/top.sv` | Top level: FrontPanel host interface, WireIn, block design instance |
| `microblaze_axi_gpio.srcs/sources_1/bd/ip_blocks/` | Block design `ip_blocks` (`.bd`) and its IP configs (`.xci`) |
| `scripts/ip_blocks_bd.tcl` | Block design exported with `write_bd_tcl`, so you can rebuild it without the `.bd` |

Vivado output directories (`.cache`, `.gen`, `.runs`, `.hw`, `.ip_user_files`, `.sim`) are git-ignored. Vivado regenerates them.

## Block design (`ip_blocks`)

| Instance | IP | Configuration |
|----------|----|---------------|
| `microblaze_0` | MicroBlaze 11.0 | I-LMB, D-LMB, AXI data port, debug enabled |
| `microblaze_0_local_memory` | LMB + BRAM controllers | 32 KB at `0x0000_0000` |
| `input_gpio` | AXI GPIO 2.0 | 32-bit, all inputs (`GPIO_0_tri_i`) |
| `led_gpio` | AXI GPIO 2.0 | 8-bit, all outputs (`GPIO_1_tri_o`) |
| `clk_wiz_0` | Clocking Wizard 6.0 | Generates the 100 MHz processor clock |
| `rst_clk_wiz_0_100M` | Processor System Reset 5.0 | Reset for the processor clock domain |
| `mdm_1` | MDM 3.2 | Debug module |

## External files (not in this repo)

The project points to files outside this folder. You need them to synthesize:

- **Opal Kelly FrontPanel HDL** (`okHost`, `okWireIn`, `okLibrary.v`, ...). This code is proprietary and ships with the FrontPanel SDK.
- **`xem7310.xdc`**: the board pin constraints from Opal Kelly.
- **XEM7310 board files**, installed in the Vivado board store.

Fix the paths in the `.xpr`, or re-add these files in Vivado, to match where they live on your machine.

## Status

Tested on XEM7310 hardware and working.

Notes on the files as committed:

- In the saved `.bd`, each GPIO's `S_AXI` appears as an external port (`S_AXI_0`, `S_AXI_1`).
- `top.sv` instantiates `mb_wrapper`. The wrapper generated from this block design is
  named `ip_blocks_wrapper`.
- The IP `.xci` files record `xc7vx485t` as the device. If Vivado reports that the IPs are
  locked, run *Report IP Status → Upgrade* for the A75 part.
- The MicroBlaze software (Vitis app) is not included.

## Rebuilding the block design from Tcl

In a Vivado project that targets `xc7a75tfgg484-1`:

```tcl
source scripts/ip_blocks_bd.tcl
make_wrapper -files [get_files ip_blocks.bd] -top
```
