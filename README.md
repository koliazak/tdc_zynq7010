# simple TDC

A carry-chain based Time-to-Digital Converter (TDC) on Xilinx Zynq-7010.

## Goal

Implement a fine-resolution TDC using FPGA native carry-chain logic, characterize its linearity, and explore coarse–fine extension to a full 20 ns measurement range.

## Hardware / Software

- **FPGA:** Xilinx Zynq-7010 (xc7z010)
- **Toolchain:** Vivado 2025.2
- **Debug:** Integrated VIO and ILA cores

## Architecture

- **Stimulus:** `MMCME2_ADV` generates two 50 MHz clocks (`start`, `stop`). `stop` supports dynamic fine phase shift (~18 ps/step).
- **Delay line:** 32 × `CARRY4` primitives (128 taps) configured as a pure carry propagator (`S=4'b1111`, `DI=4'b0000`).
- **Sampling:** Rising edge of `stop` latches the carry-chain thermometer code; result is synchronized to the system clock.
- **Debug:** VIO controls phase shift and reads results; ILA captures raw waveforms.
- **Analysis:** Python scripts extract transition points, DNL, INL, and basic TDC metrics from a phase sweep.

## Multi-Channel Architecture Updates
- 4 independent channels, each feauters 32-slice CARRY4 chain
- Each channel is constrained into its own PBlock across different FPGA regions
- `tdc_metrics.py` script allows us to compare cross-channel skew, DNL/INL variations, and layout-dependent delays.


## Achievements

- Single and multi-channel 32-slice carry chain confirmed by Vivado `report_carry_chains`.
- Average resolution: ~17 ps / tap.
- Dynamic range: ~2.2 ns over 128 taps.
- Working analysis flow: phase sweep -> CSV -> DNL/INL plots.
- Identified path to 20 ns range: lengthen delay line to ~5 ns + add 250 MHz coarse counter.
