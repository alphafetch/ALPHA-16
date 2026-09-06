#include "prexecute.hpp"

#include <iostream>
#include <string>

#include "mnemonics.hpp"
#include "../utils/utils.hpp"

using std::vector, std::string, std::unordered_map, std::istream;

vector<ParsedInstr> tokenize(istream& in, unordered_map<string, int>& symTable) {
    vector<ParsedInstr> result;
    int currentAddr = 0;
    string line;

    while (std::getline(in, line)) {
        auto commentPos = line.find(';');
        if (commentPos != string::npos) line = line.substr(0, commentPos);
        line = trim(line);
        if (line.empty()) continue;

        if (line.back() == ':') {
            symTable[line.substr(0, line.size() - 1)] = currentAddr;
            continue;
        }

        size_t spacePos = line.find(' ');
        string mnemonic = (spacePos == string::npos) ? line : trim(line.substr(0, spacePos));
        string operandStr = (spacePos == string::npos) ? "" : trim(line.substr(spacePos + 1));

        ParsedInstr instr;
        instr.mnemonic = mnemonic;
        instr.address = currentAddr;
        for (const string& tok : splitOperands(operandStr)) 
            if (!tok.empty()) instr.operands.push_back(classifyOperand(tok));
        
        result.push_back(instr);
        currentAddr++;
    }

    return result;
}