# Alpha-16 Processor ISA

## Overview
The Alpha-16 is a small x16 CPU designed loosely off of the LC-3 (Little Computer 3). It is an original 16-bit RISC style ISA using Harvard architecture, and can run programs off of ROM.

## Features
- 16-bit data width
- 16-bit address bus
- 8 general purpose registers (R0-R7)
- A set of 11 instructions to utilize in ROM
- 8 different modes for R-type (ALU) instructions
- 16-bit addressable RAM
- 8-bit ROM with up to 256 instructions
- Carry flag for 32-bit addition (explained below)

## ISA
| Opcode | Hex | Mnemonic | [11:9] | [8:6] | [5:3] | [2:0] |
| --- | --- | --- | --- | --- | --- | --- |
| `0000` | `0xxx` | R-type | `ALUSel` | `Rd` | `Rs1` | `Rs2` |
| `0001` | `1xxx` | LOAD | `Rd` | `Rbase` | - | - |
| `0010` | `2xxx` | STORE | `Rsrc` | `Rbase` | - | - |
| `0011` | `3xxx` | BRANCH | `Rcond` | `target[8:6]` | `target[5:3]` | `target[2:0]` |
| `0100` | `4xxx` | JUMP | `target[11:9]` | `target[8:6]` | `target[5:3]` | `target[2:0]` |
| `0101` | `5xxx` | CALL | `target[11:9]` | `target[8:6]` | `target[5:3]` | `target[2:0]` |
| `0110` | `6xxx` | RETURN | - | - | - | - |
| `0111` | `7xxx` | MOVI | `Rd` | `imm[8:6]` | `imm[5:3]` | `imm[2:0]` |
| `1000` | `8xxx` | BNE | `Rcond` | `target[8:6]` | `target[5:3]` | `target[2:0]` |
| `1001` | `9xxx` | NOT | `Rd[11:9]` | `Rs1[8:6]` | - | - |
| `1010` | `axxx` | HALT | - | - | - | - |

### ALU Select (R-type)
| Value | Operation |
| --- | --- |
| `000` | ADD |
| `001` | SUB |
| `010` | AND |
| `011` | OR |
| `100` | XOR |
| `101` | ADDC (add w/ carry-flag) |
| `110` | SHL (bitshift left) |
| `111` | SHR (bitshift right) |

Example usage of `ADDC` in ALPHA-16 Assembly (AASM):
```asm
ADD  R4, R0, R2 ; low words:  R4 = R0 + R2, sets CF
ADDC R5, R1, R3 ; high words: R5 = R1 + R3 + CF
```

### Registers in Opcode Format
| Register | Definition |
| --- | --- |
| **`Rd`** | Desination register |
| **`Rs1`** | Source register |
| **`Rs2`** | Source register |
| **`Rsrc`** | Source register | 
| **`Rbase`** | Base address register (`LOAD`/`STORE`) |
| **`Rcond`** | Conditional reigster (`BRANCH`/`BNE`) |

### Notes
- `BRANCH` targets are 9 bits, zero-extended to 16 bits. Taken when `Rcond`'s value is exactly `0`.
    - The same applies for `BNE`, but taken when `Rcond`'s value is not equal to `0`.
- `JUMP`/`CALL` targets are 12 bits, zero-extended to 16 bits. Both unconditional.
- `MOVI`'s immediate is 9 bits, zero-extended to 16 bits.
- `SHL` moves the top bit into `COUT`.
- `SHR` moves the lower bit into `COUT`.
- `Hex` column only shows the opcode nibble (`[15:12]`); the full instruction word also depends on the operand fields - see test programs section for complete examples.

## Registers
| Register | Use |
| --- | --- |
| `R0` | General Purpose (Available) |
| `R1` | General Purpose (Available) |
| `R2` | General Purpose (Available) |
| `R3` | General Purpose (Available) |
| `R4` | General Purpose (Available) |
| `R5` | General Purpose (Available) |
| `R6` | General Purpose (Available) |
| `R7` | General Purpose (Available) |
| `STK_PTR` | Stack Pointer Register (Reserved) |
| `PC` | Program Counter (Reserved) |
| `CF` | Carry Flag Register (Reserved) |
| `PC_HOLD` | Halt Flag Register (Reserved) |

### Register Encoding
| Binary | Register |
| --- | --- |
| `000` - `111` | `R0` - `R7` |
| N/A - Not addressable | `STK_PTR` |
| N/A - Not addressable | `PC` / `CF` |
| N/A - Not addressable | `PC_HOLD` |

### Notes
- `STK_PTR`, `PC`, `CF`, `PC_HOLD` are unaccessible and are not referenced by any opcode.

## Example Programs

### Example Program 1

| Addr | AASM | Hex | Binary | Notes |
| --- | --- | --- | --- | --- |
| 0 | `MOVI R0, 5` | `7005` | `0111 0000 0000 0101` | Moves 5 into register 0 |
| 1 | `MOVI R1, 3` | `7203` | `0111 0010 0000 0011` | Moves 3 into register 1 |
| 2 | `ADD R2, R0, R1` | `0081` | `0000 0000 1000 0001` | Adds R0 and R1 into R2 |
| 3 | `STORE R2, R3` | `24c0` | `0010 0100 1100 0000` | Stores R2 into R3 |
| 4 | `LOAD R4, R3` | `18c0` | `0001 1000 1100 0000` | Loads R3 into R4 |
| 5 | `HALT` | `A000` | `1010 0000 0000 0000` | Halts the program |

**Code:**
```aasm
MOVI R0, 5
MOVI R1, 3
ADD R2, R0, R1
STORE R2, R3
LOAD R4, R3
HALT
```

> **Result:** `R2 = 8`, `RAM[0] = 8`, `R4 = 8`.

## Compilation / Assembly
### Using Icarus Verilog
1. Download Icarus Verilog v14 from [bleyer.org/icarus/](https://www.bleyer.org/icarus/)
2. Open your operating system's terminal
3. Enter the following commands:

    ```
    iverilog -o [destination_name] [path/to/core/core.v] [path/to/sub/dir/alu16.v] [path/to/sub/dir/controlUnit.v] [path/to/sub/dir/fetch.v] [path/to/sub/dir/POR.v] [path/to/sub/dir/RAM.v] [path/to/sub/dir/regFile16.v] [path/to/sub/dir/stkPtr.v]

    vvp [destination_name]
    ```

> **Note:** `vvp` must be run with the `.hex` file in the same directory.

### Assembling a `.aasm` File for ROM
1. Use the compiled assembler in `asm/bin/aasm_assembler.exe` on the command line:

    ```
    .\aasm_assembler <input .aasm file> [output .hex file]
    ```

2. If you used a custom filename for the output `.hex` file, enter it into `circ/sub/fetch.v` on line 17 in the string input field (defaults to `program.hex`, enter no second argument to use `program.hex` as the output file from the `aasm_assembler`).
3. Run the above compilation instructions for Icarus Verilog to compile and run the circuit.

### Compiling the Assembler
1. Install `g++` from the `MSYS2` ([msys2.org](msys2.org)) terminal.

    1. Install the `MSYS2` terminal from the provided website.
    2. Open it and run `pacman -S mingw-w64-x86_64-toolchain`.
2. Open Microsoft PowerShell and run the following command in the output directory (also containing the `src` folder):

    ```
    g++ -o aasm_assembler.exe src/assembler.cpp src/core/mnemonics.cpp src/core/prexecute.cpp src/core/encode.cpp src/utils/utils.cpp
    ```

## Known Assembler / Circuit Caveats:
- No bounds check on operands.
- `HALT` pauses `PC` at `PC + 2` instead of the current `PC`.
- Any `PC`-redirecting instruction (`BRANCH`/`BNE`/`JUMP`/`CALL`/`RETURN`) allows exactly one wrong-path instruction - already in flight when the redirect fires - to execute before the correct target takes over. Not yet fixed in this build.

## Miscellaneous Notes
- CPU requires `POR` `RESET` wire held for a fixed number of clock cycles before it fetches instructions.
- The above compilation instructions only allow for local compilation, assuming no use of an emulator or physical hardware. This will not allow for graphical display (not yet implemented) nor output of any kind without using a testbench program through Icarus Verilog.