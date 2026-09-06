# Alpha-16 Processor ISA
## Features
- 16-bit data width
- 16-bit address bus
- 8 general purpose registers (R0-R7)
- A set of 8 instructions to utilize in ROM
- Harvard architecture with ROM and RAM
- Carry flag for 32-bit addition (explained below)

## ISA
| Opcode | Mnemonic | [11:9] | [8:6] | [5:3] | [2:0] |
| --- | --- | --- | --- | --- | --- |
| `0000` | R-type | `ALUSel` | `Rd` | `Rs1` | `Rs2` |
| `0001` | LOAD | `Rd` | `Rbase` | - | - |
| `0010` | STORE | `Rsrc` | `Rbase` | - | - |
| `0011` | BRANCH | `Rcond` | `target[8:6]` | `target[5:3]` | `target[2:0]` |
| `0100` | JUMP | `target[11:9]` | `target[8:6]` | `target[5:3]` | `target[2:0]` |
| `0101` | CALL | same as JUMP | - | - | - |
| `0110` | RETURN | - | - | - | - |
| `0111` | MOVI | `Rd` | `imm[8:6]` | `imm[5:3]` | `imm[2:0]` |

### ALU Select (R-type Mnemonic)
| Value | Operation |
| --- | --- |
| `000` | ADD |
| `001` | SUB |
| `010` | AND |
| `011` | OR |
| `100` | XOR |
| `101` | ADDC (add w/ carry-flag) |
| `110` | SHL (bitshift left) |

**Use of ADDC:**

Example usage in ALPHA-16 Assembly:
```asm
ADD  R4, R0, R2 ; low words:  R4 = R0 + R2, sets CF
ADDC R5, R1, R3 ; high words: R5 = R1 + R3 + CF
```

### Notes
- `BRANCH` target is 9 bits, zero-extended to 16 bits. Taken when `Rcond`'s value is exactly `0`.
- `JUMP`/`CALL` targets are 12 bits, zero-extended to 16 bits. Both unconditional.
- `MOVI`'s immediate is 9 bits, zero-extended to 16 bits.
- `SHL` moves the top bit into `COUT`.

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

### Register Encoding
| Binary | Register |
| --- | --- |
| `000` - `111` | `R0` - `R7` |
| N/A - Not addressable | `STK_PTR` |
| N/A - Not addressable | `PC` / `CF` |

### Notes
- `STK_PTR`, `PC`, and `CF` are unaccessible and are not referenced by any opcode.

## Compilation from Source
### Using Icarus Verilog
1. Download Icarus Verilog v12 from [bleyer.org](bleyer.org/icarus/)
2. Open your operating system's terminal
3. Enter the following commands:

    1. `iverilog -o [destination_name] [path/to/core/core.v] [path/to/sub/dir/alu16.v] [path/to/sub/dir/controlUnit.v] [path/to/sub/dir/fetch.v] [path/to/sub/dir/POR.v] [path/to/sub/dir/RAM.v] [path/to/sub/dir/regFile16.v] [path/to/sub/dir/stkPtr.v]`
    2. `vvp [destination_name]`

## Overview
The Alpha-16 is a small x16 CPU designed loosely off of the LC-3 (Little Computer 3). It is an original 16-bit RISC style ISA using Harvard architecture, and can run programs off of ROM.

## Miscellaneous Notes
- CPU requires `POR` `RESET` wire held for a fixed number of clock cycles before it fetches instructions.