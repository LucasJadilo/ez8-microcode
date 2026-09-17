# EZ8 Microcode

This software generates the files that define the EZ8 CPU's microcode and
internal control logic:

- `ez8_cu_eprom0.bin`, `ez8_cu_eprom1.bin`, `ez8_cu_eprom2.bin`, `ez8_cu_eprom3.bin`:
  binary files for the Control Unit's EPROMs.
- `ez8_cu_truth_table.csv`: complete Control Unit's truth table.
- `ez8_cu_instruction_cycles.csv`: control signals for every clock cycle of every instruction (grouped by instruction).

The EZ8 is a fully simulated 8-bit RISC CPU designed from scratch as a hobby project.
Check the complete CPU documentation on [Hackster](https://www.hackster.io/LucasJadilo/ez8-8-bit-cpu-from-scratch-6d22d8).

## Build

All the project features, including the build process, code formatting, code analysis,
etc., are automated via a [Makefile](Makefile) (GNU Make required). Use the command
below to see the available options:

```sh
make help
```

This software depends on the [EZ8 C/C++ Library](https://github.com/LucasJadilo/ez8-lib-c).
