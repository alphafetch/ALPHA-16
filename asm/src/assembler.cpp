#include <iostream>
#include <string>
#include <fstream>
#include <unordered_map>
#include <iomanip>

#include "core/mnemonics.hpp"
#include "core/prexecute.hpp"
#include "core/encode.hpp"

using std::string, std::cerr, std::unordered_map, std::vector;

int main(int argc, char* argv[]) {
    if (argc < 2) {
        cerr << "Usage: " << argv[0] << " <input.aasm> [output.hex]\n";
        return 1;
    }

    string inPath = argv[1];
    string outPath = (argc >= 3) ? argv[2] : "program.hex";

    unordered_map<string, MnemonicInfo> mnemonics = buildMnemonicTable();
    unordered_map<string, int> symTable;

    std::ifstream file(inPath);
    if (!file.is_open()) {
        cerr << "Error: could not open file: " << inPath << "\n";
        return 1;
    }

    vector<ParsedInstr> tokens = tokenize(file, symTable);
    vector<uint16_t> data = encode(
        tokens, mnemonics, symTable
    );

    std::ofstream outFile(outPath);
    if (!outFile.is_open()) {
        cerr << "Error: could not open file: " << outPath << "\n";
        return 1;
    }

    for (uint16_t word : data) {
        outFile << std::hex << std::setw(4) << std::setfill('0') << word << '\n';
    }

    std::cout << "File assembled in " << outPath << ".\n";
 
    return 0;
}