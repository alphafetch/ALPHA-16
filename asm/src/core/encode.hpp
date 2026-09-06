#ifndef CORE_ENCODE_HPP
#define CORE_ENCODE_HPP

#include <vector>
#include <cstdint>
#include <unordered_map>
#include <string>
#include "prexecute.hpp"
#include "mnemonics.hpp"

std::vector<uint16_t> encode(const std::vector<ParsedInstr>& instrs,
                              const std::unordered_map<std::string, MnemonicInfo>& mnemonics,
                              const std::unordered_map<std::string, int>& symTable);

#endif