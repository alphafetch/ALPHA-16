#include "utils.hpp"

#include <sstream>
#include <algorithm>

using std::vector, std::string;

std::string trim(const std::string& s) {
    size_t start = s.find_first_not_of(" \t");
    if (start == std::string::npos) return "";
    size_t end = s.find_last_not_of(" \t");
    return s.substr(start, end - start + 1);
}

vector<string> splitOperands(const string& operandStr) {
    vector<string> result;
    std::stringstream ss(operandStr);
    string token;
    while (std::getline(ss, token, ',')) {
        result.push_back(trim(token));
    }

    return result;
}

Operand classifyOperand(const string& token) {
    if (token.size() == 2 && (token[0] == 'R' || token[0] == 'r')
        && token[1] >= '0' && token[1] <= '7') {
        return Operand{Operand::Type::REGISTER, token[1] - '0', ""};
    }

    bool isNumber = !token.empty() && std::all_of(token.begin(), token.end(), ::isdigit);
    if (isNumber) {
        return Operand{Operand::Type::IMMEDIATE, std::stoi(token), ""};
    }

    return Operand{Operand::Type::LABEL, 0, token};
}