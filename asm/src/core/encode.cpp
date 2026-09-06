#include "encode.hpp"
#include <iostream>

using std::vector, std::string, std::unordered_map, std::cerr;

static int resolveValue(const Operand& op, const unordered_map<string, int>& symTable, bool& ok) {
    switch (op.type) {
        case Operand::Type::IMMEDIATE:
        case Operand::Type::REGISTER:
            return op.value;
        case Operand::Type::LABEL: {
            auto it = symTable.find(op.label);
            if (it == symTable.end()) {
                cerr << "Unresolved label: " << op.label << "\n";
                ok = false;
                return 0;
            }
            return it->second;
        }
    }
    ok = false;
    return 0;
}

vector<uint16_t> encode(const vector<ParsedInstr>& instrs,
                         const unordered_map<string, MnemonicInfo>& mnemonics,
                         const unordered_map<string, int>& symTable) {
    vector<uint16_t> result;

    for (const auto& instr : instrs) {
        auto it = mnemonics.find(instr.mnemonic);
        if (it == mnemonics.end()) {
            cerr << "Unknown mnemonic: " << instr.mnemonic << " at address " << instr.address << "\n";
            result.push_back(0);
            continue;
        }
        const MnemonicInfo& info = it->second;
        uint16_t word = static_cast<uint16_t>(info.opcode) << 12;
        bool ok = true;

        switch (info.format) {
            case OperandFormat::RTYPE:
                word |= (static_cast<uint16_t>(info.aluSel) & 0x7) << 9;
                word |= (static_cast<uint16_t>(resolveValue(instr.operands[0], symTable, ok)) & 0x7) << 6;
                word |= (static_cast<uint16_t>(resolveValue(instr.operands[1], symTable, ok)) & 0x7) << 3;
                word |= (static_cast<uint16_t>(resolveValue(instr.operands[2], symTable, ok)) & 0x7);
                break;
            case OperandFormat::LOAD:
                word |= (static_cast<uint16_t>(resolveValue(instr.operands[0], symTable, ok)) & 0x7) << 9;
                word |= (static_cast<uint16_t>(resolveValue(instr.operands[1], symTable, ok)) & 0x7) << 6;
                break;
            case OperandFormat::STORE:
                word |= (static_cast<uint16_t>(resolveValue(instr.operands[0], symTable, ok)) & 0x7) << 9;
                word |= (static_cast<uint16_t>(resolveValue(instr.operands[1], symTable, ok)) & 0x7) << 6;
                break;
            case OperandFormat::BRANCH:
                word |= (static_cast<uint16_t>(resolveValue(instr.operands[0], symTable, ok)) & 0x7) << 9;
                word |= (static_cast<uint16_t>(resolveValue(instr.operands[1], symTable, ok)) & 0x1FF);
                break;
            case OperandFormat::JUMP:
                word |= (static_cast<uint16_t>(resolveValue(instr.operands[0], symTable, ok)) & 0xFFF);
                break;
            case OperandFormat::MOVI:
                word |= (static_cast<uint16_t>(resolveValue(instr.operands[0], symTable, ok)) & 0x7) << 9;
                word |= (static_cast<uint16_t>(resolveValue(instr.operands[1], symTable, ok)) & 0x1FF);
                break;
            case OperandFormat::NOT_FMT:
                word |= (static_cast<uint16_t>(resolveValue(instr.operands[0], symTable, ok)) & 0x7) << 9;
                word |= (static_cast<uint16_t>(resolveValue(instr.operands[1], symTable, ok)) & 0x7) << 6;
                break;
            case OperandFormat::NONE:
                break;
        }

        if (!ok) cerr << "  (in instruction '" << instr.mnemonic << "' at address " << instr.address << ")\n";
        result.push_back(word);
    }
    return result;
}