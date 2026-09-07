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

## Instruction Set
| Opcode | Hex | Mnemonic | `[11:9]` | `[8:6]` | `[5:3]` | `[2:0]` |
| --- | --- | --- | --- | --- | --- | --- |
| `0000` | `0xxx` | R-type | `ALUSel` | `Rd` | `Rs1` | `Rs2` |
| `0001` | `1xxx` | LOAD | `Rd` | `Rbase` | - | - |
| `0010` | `2xxx` | STORE | `Rsrc` | `Rbase` | - | - |
| `0011` | `3xxx` | BRANCH | `Rcond` | `target[8:6]` | `target[5:3]` | `target[2:0]` |
| `0100` | `4xxx` | JUMP | `target[11:9]` | `target[8:6]` | `target[5:3]` | `target[2:0]` |
| `0101` | `5xxx` | CALL | `target[11:9]` | `target[8:6]` | `target[5:3]` | `target[2:0]` |
| `0110` | `6000` | RETURN | - | - | - | - |
| `0111` | `7xxx` | MOVI | `Rd` | `imm[8:6]` | `imm[5:3]` | `imm[2:0]` |
| `1000` | `8xxx` | BNE | `Rcond` | `target[8:6]` | `target[5:3]` | `target[2:0]` |
| `1001` | `9xxx` | NOT | `Rd[11:9]` | `Rs1[8:6]` | - | - |
| `1010` | `a000` | HALT | - | - | - | - |

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

### Registers in Opcode Formatting
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
| `BUBBLE_FLAG` | Bubble Flag Register (Reserved) |

### Register Encoding
| Binary | Register |
| --- | --- |
| `000` - `111` | `R0` - `R7` |
| N/A - Not addressable | `STK_PTR` |
| N/A - Not addressable | `PC` / `CF` |
| N/A - Not addressable | `PC_HOLD` |
| N/A - Not addressable | `BUBBLE_FLAG` |

### Notes
- `STK_PTR`, `PC`, `CF`, `PC_HOLD`, and `BUBBLE_FLAG` are unaccessible and are not referenced by any opcode.

## Example Programs

### Example Program 1

| Addr | AASM | Hex | Binary | Notes |
| --- | --- | --- | --- | --- |
| 0 | `MOVI R0, 5` | `7005` | `0111 0000 0000 0101` | Moves 5 into register 0 |
| 1 | `MOVI R1, 3` | `7203` | `0111 0010 0000 0011` | Moves 3 into register 1 |
| 2 | `ADD R2, R0, R1` | `0081` | `0000 0000 1000 0001` | Adds R0 and R1 into R2 |
| 3 | `STORE R2, R3` | `24c0` | `0010 0100 1100 0000` | Stores R2 into R3 |
| 4 | `LOAD R4, R3` | `18c0` | `0001 1000 1100 0000` | Loads R3 into R4 |
| 5 | `HALT` | `a000` | `1010 0000 0000 0000` | Halts the program |

**Code:**
```aasm
MOVI  R0, 5       ; store 5 in register 0
MOVI  R1, 3       ; store 3 in register 1
ADD   R2, R0, R1  ; add them into register 2
STORE R2, R3      ; store the result in RAM[0] (R3 currently == 0)
LOAD  R4, R3      ; load RAM[0] into register 4
HALT              ; halt the program
```

> **Result:** `R2 = 8`, `RAM[0] = 8`, `R4 = 8`.

### Example Program 2

| Addr | AASM | Hex | Binary | Notes |
| --- | --- | --- | --- | --- |
| 0 | `MOVI R5, 0` | `7a00` | `0111 1010 0000 0000` | Moves 0 into register 5 |
| 1 | `BRANCH R5, 5` | `3a05` | `0011 1010 0000 0101` | Branches to 5 if register 5 is 0 |
| 2 | `MOVI R6, 99` | `7c63` | `0111 1100 0110 0011` | - |
| 3 | `MOVI R6, 99` | `7c63` | `0111 1100 0110 0011` | - |
| 4 | `MOVI R6, 99` | `7c63` | `0111 1100 0110 0011` | - |
| 5 | `MOVI R7, 1` | `7e01` | `0111 1110 0000 0001` | Marker to move 1 into register 7 |
| 6 | `HALT` | `a000` | `1010 0000 0000 0000` | Halts the program |

**Code:**
```aasm
MOVI   R5, 0     ; store 0 in register 5
BRANCH R5, stop  ; branch to label stop if register 5 is 0
MOVI   R6, 99    ; trap
MOVI   R6, 99    ; trap
MOVI   R6, 99    ; trap
stop:            ; stop label
MOVI   R7, 1     ; move 1 into register 7
HALT             ; halt the program
```

> **Result:** `R5 = 0`, `R7 = 1`.

### Example Program 3
| Addr | AASM | Hex | Binary | Notes |
| --- | --- | --- | --- | --- |
| 0 | `CALL 3` | `5003` | `0101 0000 0000 0011` | Call the subroutine at index 3 |
| 1 | `MOVI R0, 42` | `702a` | `0111 0000 0010 1010` | Move 42 into register 0 after return |
| 2 | `HALT` | `a000` | `1010 0000 0000 0000` | Halt the program |
| 3 | `MOVI R1, 7` | `7207` | `0111 0010 0000 0111` | Subroutine body |
| 4 | `RETURN` | `6000` | `0110 0000 0000 0000` | Return to caller |
| 5 | `HALT` | `a000` | `1010 0000 0000 0000` | Catch any bugs and halt |

**Code:**
```aasm
CALL sub    ; call the subroutine
MOVI R0, 42 ; move 42 into register 0 after return
HALT        ; halt the program

; Subroutines
sub:        ; subroutine label
MOVI R1, 7  ; move 7 into register 1
RETURN      ; return to caller

HALT        ; catch
```

> **Result:** `R0 = 42`, `R1 = 7`.

### Example Program 4
| Addr | AASM | Hex | Binary | Notes |
| --- | --- | --- | --- | --- |
| 0 | `MOVI R0, 5` | `7005` | `0111 0000 0000 0101` | Move 5 into register 0 |
| 1 | `MOVI R1, 3` | `7103` | `0111 0001 0000 0010` | Move 3 into register 1
| 2 | `SUB R2, R0, R1` | `0281` | `0000 0010 1000 0001` | Subtract R1 from R0 into R2 |
| 3 | `AND R3, R0, R1` | `04c1` | `0000 0100 1100 0001` | And R0 and R1 into R3 |
| 4 | `OR R4, R0, R1` | `0701` | `0000 0111 0000 0001` | Or R0 and R1 into R4 |
| 5 | `XOR R5, R0, R1` | `0941` | `0000 1001 0100 0001` | Xor R0 and R1 into R5 |
| 6 | `ADDC R6, R0, R1` | `0b81` | `0000 1011 1000 0001` | Add with carry R0 and R1 into R6 |
| 7 | `NOT R7, R0` | `9e00` | `1001 1110 0000 0000` | Not R0 into R7 |
| 8 | `BNE R2, 10` | `840a` | `1000 0100 0000 1010` | Branch to 10 if R2 is not 0 |
| 9 | `MOVI R7, 99` | `7e63` | `0111 1110 0110 0011` | Move 99 into R7 (trap) |
| 10 | `SHL R0, R0, R0` | `0c00` | `0000 1100 0000 0000` | Shift R0 left |
| 11 | `SHR R1, R1, R1` | `0e49` | `0000 1110 0100 1001` | Shift R1 right |
| 12 | `HALT` | `a000` | `1010 0000 0000 0000` | Halt the program |

**Code:**
```aasm
MOVI R0, 5      ; move 5 into R0
MOVI R1, 3      ; move 3 into R1
SUB  R2, R0, R1 ; R0 - R1 -> R2
AND  R3, R0, R1 ; R0 & R1 -> R3
OR   R4, R0, R1 ; R0 | R1 -> R4
XOR  R5, R0, R1 ; R0 ^ R1 -> R5
ADDC R6, R0, R1 ; R0 + R1 + CIN -> R6
NOT  R7, R0     ; ~R0 -> R7
BNE  R2, skip   ; If R2 != 0 go to skip 
MOVI R7, 99     ; trap
skip:
SHL  R0, R0, R0 ; shift R0 left one bit
SHR  R1, R1, R1 ; shift R1 right one bit
HALT            ; halt the program
```

> **Result:** `R0 = 0x000A`, `R1 = 0x0001`, `R2 = 0x0002`, `R3 = 0x0001`, `R4 = 0x0007`, `R5 = 0x0006`, `R6 = 0x0008`, `R7 = 0xFFFA`.

## Compilation / Assembly
### Using Icarus Verilog
1. Download Icarus Verilog v14 from [bleyer.org/icarus/](https://www.bleyer.org/icarus/)
2. Open your operating system's terminal
3. Enter the following commands:

    ```
    iverilog -o [destination_name] [path/to/core/core.v] [path/to/sub/dir/alu16.v] [path/to/sub/dir/controlUnit.v] [path/to/sub/dir/fetch.v] [path/to/sub/dir/POR.v] [path/to/sub/dir/RAM.v] [path/to/sub/dir/regFile16.v] [path/to/sub/dir/stkPtr.v]

    vvp [destination_name]
    ```

> **Note:** `vvp` must be run with the `.hex` file in the same directory, and the `.hex` file must be named `program.hex` or the string be changed inside `fetch.v` before running `iverilog` and `vvp`.

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
- No bounds check on operands (ex. `ADD R5, R4` is not checked, even though it is invalid syntax).
- `HALT` freezes execution two addresses after its own position in ROM, due to the fetch pipeline's one-instruction lookahead plus `PC_HOLD`'s own registration delay - confirmed consistent across straight line, branching, and `CALL`/`RETURN` programs.
- `STORE` does not take immedate values (ex. `STORE R5, R4` works, and stores the value in R5 to RAM[R4], and does not take immediate values for either, so `STORE 5, 4` would not store `5` to RAM slot `4`).

## Miscellaneous Notes
- CPU requires `POR` `RESET` wire held for a fixed number of clock cycles before it fetches instructions.
- The above compilation instructions only allow for local compilation, assuming no use of an emulator or physical hardware. This will not allow for graphical display (not yet implemented) nor output of any kind without using a testbench program through Icarus Verilog.