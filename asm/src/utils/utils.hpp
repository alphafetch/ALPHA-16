#ifndef UTILS_UTILS_HPP
#define UTILS_UTILS_HPP

#include <string>
#include <vector>

#include "../core/prexecute.hpp"

std::string trim(const std::string& s);
std::vector<std::string> splitOperands(const std::string& operandStr);
Operand classifyOperand(const std::string& token);

#endif