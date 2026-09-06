#ifndef CORE_MNEMONICS_HPP
#define CORE_MNEMONICS_HPP

#include <cstdint>
#include <string>
#include <unordered_map>

enum class OperandFormat { RTYPE, LOAD, STORE, BRANCH, JUMP, MOVI, NOT_FMT, NONE };

#define MNEMONIC_LIST \
    X(ADD,    0b0000, 0b000, RTYPE  ) \
    X(SUB,    0b0000, 0b001, RTYPE  ) \
    X(AND,    0b0000, 0b010, RTYPE  ) \
    X(OR,     0b0000, 0b011, RTYPE  ) \
    X(XOR,    0b0000, 0b100, RTYPE  ) \
    X(ADDC,   0b0000, 0b101, RTYPE  ) \
    X(SHL,    0b0000, 0b110, RTYPE  ) \
    X(SHR,    0b0000, 0b111, RTYPE  ) \
    X(LOAD,   0b0001, 0,     LOAD   ) \
    X(STORE,  0b0010, 0,     STORE  ) \
    X(BRANCH, 0b0011, 0,     BRANCH ) \
    X(JUMP,   0b0100, 0,     JUMP   ) \
    X(CALL,   0b0101, 0,     JUMP   ) \
    X(RETURN, 0b0110, 0,     NONE   ) \
    X(MOVI,   0b0111, 0,     MOVI   ) \
    X(BNE,    0b1000, 0,     BRANCH ) \
    X(NOT,    0b1001, 0,     NOT_FMT) \
    X(HALT,   0b1010, 0,     NONE   ) 

struct MnemonicInfo {
    uint8_t opcode;
    uint8_t aluSel;
    OperandFormat format;
};

std::unordered_map<std::string, MnemonicInfo> buildMnemonicTable();

#endif