#ifndef CORE_PREXECUTE_HPP
#define CORE_PREXECUTE_HPP

#include <string>
#include <vector>
#include <unordered_map>

struct Operand {
    enum class Type { REGISTER, IMMEDIATE, LABEL } type;
    int value;
    std::string label;
};

struct ParsedInstr {
    std::string mnemonic;
    std::vector<Operand> operands;
    int address;
};

std::vector<ParsedInstr> tokenize(std::istream& in, std::unordered_map<std::string, int>& symTable);

#endif