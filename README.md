# Sail -> SystemVerilog
This repository demonstrates how to use the Sail to system verilog backend. The objective is to build a purely combinational translation of the Sail.

## 1. Sail Setup
1. [Install OPAM](https://opam.ocaml.org/doc/Install.html) + `opam init`
2. Clone [Sail](https://github.com/rems-project/sail) and `cd` into it
3. Get Sail dependencies: `opam install . --deps-only`
4. Build Sail: `dune build --release && dune install`
5. Install z3

## 2. Clone either this repository recursively or [sail-riscv](https://github.com/riscv/sail-riscv/)
If you clone the original repository make sure the Makefile amd `main.sail` in this repository are in its parent directory, i.e.:
```
somewhere
|- Makefile
|- main.sail
|- sail-riscv
    |- ...
|- ...
```

## 3. Alternative Main
We can't really use the main that comes with `sail-riscv` since it was designed for simulation, not for verification. It therefore includes an infinite loop, and various bits of setup we don't really want. We can instead reduce it to something like this:

```sail
function main(insn_bits) : bits(32) -> unit = {
    let insn = if isRVC(insn_bits[15..0]) then {
        encdec_compressed(insn_bits[15..0])
    } else {
        encdec(insn_bits)
    };

    let res = execute(insn);
}
```

This simply does decode + execute, with no instruction fetch checking. You can find this in [main.sail](/main.sail).

## 4. Build the SystemVerilog
[The Makefile](/Makefile) I have supplied is a modified version of the one in sail-riscv. It includes a new rule: `sv`, which translates the RISC-V Sail into system verilog. It does not apply every extension, but it does do a handful. (The compiler is still young, and does not yet support everything we need for all of them)

The output system verilog will be in `out.sv`.

`make sv` runs Sail with the following flags:
``` bash
sail
    -sv # Invoke the System Verilog backend
    -sv_comb # Output a combinational version, not a simulation version
    -sv_inregs # Make all the Sail registers get their values from input wires
    -sv_outregs # Make all the Sail registers put their values into output wires
    -sv_nostrings # Don't include strings. Technically unsound since we don't check if they are used, we just replace them all with unit
    -sv_nopacked # Don't emit packed structures. Currently the packed enums are not padded so everything variant has the same size
    -sv_nomem # Don't emit dynamic memory (which is intended for simulation)
    -sv_unreachable translate32 -sv_unreachable walk32 # Don't emit any code for the translate32 function. Instead just set the sail_reached_unreachable flag. Necessary due to recursion issues, but currently means page table walks are not supported.
    -sv_fun2wires __read_mem # Instead of making __read_mem (called MEMr in the Sail) a function, make it wires going in and out of the module
    -sv_fun2wires __write_mem # Same for MEMw
    # ^ These two allow us to control what goes in memory, and check what comes out
    -memo_z3 # Memoize z3 calls (this is the z3_problems file) Speeds up compilation after the first run a lot
```

The Makefile will output 32 bit RISC-V. If you switch to 64 bit you may wish to increase `-sv_int_size` and `-sv_bit_size` to ~256 (especially if it's for CHERI).

## 5. Connecting to JasperGold
The spec module can be loaded like any other module (with `-sv12`). It will also need `-incdir $SAIL_SRC/sail/lib/sv`, where `$SAIL_SRC` is the path to the Sail source you cloned in step 1.

You will also need to include `stubs.sv`, which implements the external functions that the Sail was expecting to find.

We typically don't work directly against the generated module - instead we create a layer on top of it we call the spec api to clean things up:
1. It leaves CSRs we don't currently find interesting undriven
2. It cleans up the interface for `__read_mem` and `__write_mem` since the generated names are ugly and non-descriptive
3. It maps the GPRs into arrays, i.e. instead of having wires `x1_in`, `x2_in`, ... `x1_out`, `x2_out`, ... we just have `regs_in[15:0]` and `regs_out[15:0]`
4. It maps raw bit patterns like mstatus to and from nicer types

You will notice that JG takes a fairly long time and a lot of memory to elaborate `sail_out`. We add additional `-sv_unreachable` calls to the `SAIL_SV_FLAGS` field in the Makefile to remove some instructions and therefore reduce the elaboration size. I would recommend the configuration in [unreach_mem_rvc.txt](/unreach_mem_rvc.txt) to start, which removes `LOAD`, `STORE` and all the compressed instructions.
