#include "mnemonics.hpp"

using std::unordered_map, std::string;

unordered_map<string, MnemonicInfo> buildMnemonicTable() {
    unordered_map<string, MnemonicInfo> table;
    #define X(name, opcode, aluSel, format) \
        table.insert({string(#name), MnemonicInfo{opcode, aluSel, OperandFormat::format}});
    MNEMONIC_LIST
    #undef X
    return table;
}