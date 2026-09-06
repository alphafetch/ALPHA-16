module controlUnit(
    input [15:0] INSTRUCTION,
    input [15:0] RDATA1,
    input CLK,

    output reg SH_BRANCH,
    output reg RET,
    output reg [15:0] BRANCH_TGT_RAW,
    output reg [2:0] RADDR1,
    output reg [2:0] RADDR2,
    output reg WRITE,
    output reg [2:0] WADDR,
    output reg [1:0] REG_WRITEBACK_SEL,
    output reg [2:0] SEL,
    output reg ALU_B_SEL,
    output reg IN_ENABLE,
    output reg OUT_ENABLE,
    output reg [1:0] RAM_ADDR_SEL,
    output reg RAM_DIN_SEL,
    output reg INC,
    output reg DEC,
    output reg [15:0] IMMEDIATE,
    output reg CARRY_UPD,
    output reg [1:0] ALU_CIN_SEL
);
    wire [3:0] OPCODE = INSTRUCTION[15:12];
    reg [3:0] Rbase;
    reg [3:0] Rcond;
    reg [15:0] target;

    always @(*) begin
        SH_BRANCH = 1'b0;
        RET = 1'b0;
        BRANCH_TGT_RAW = 16'h0000;
        RADDR1 = 3'b000;
        RADDR2 = 3'b000;
        WRITE = 1'b0;
        WADDR = 3'b000;
        REG_WRITEBACK_SEL = 2'b00;
        SEL = 3'b000;
        ALU_B_SEL = 1'b0;
        IN_ENABLE = 1'b0;
        OUT_ENABLE = 1'b0;
        RAM_ADDR_SEL = 2'b00;
        RAM_DIN_SEL = 1'b0;
        INC = 1'b0;
        DEC = 1'b0;
        IMMEDIATE = 16'h0000;
        CARRY_UPD = 1'b0;
        ALU_CIN_SEL = 2'b00;

        case (OPCODE)
            4'h0: begin // 0000 R-type
                SEL = INSTRUCTION[11:9]; // Operation type
                ALU_B_SEL = 1'b0; // Input for ALU.B
                RADDR1 = INSTRUCTION[5:3]; // Read address for A
                RADDR2 = INSTRUCTION[2:0]; // Read address for B
                WRITE = 1'b1; // Write to a register
                WADDR = INSTRUCTION[8:6]; // Register address to write to
                REG_WRITEBACK_SEL = 2'b00; // Selector to write back
                CARRY_UPD = (INSTRUCTION[11:9] == 3'b000) || (INSTRUCTION[11:9] == 3'b101);
                if (INSTRUCTION[11:9] == 3'b101) ALU_CIN_SEL = 2'b10; // ADDC -> CF
                else if (INSTRUCTION[11:9] == 3'b001) ALU_CIN_SEL = 2'b01; // SUB -> 1
                else ALU_CIN_SEL = 2'b00; // All else -> 0
            end
            4'h1: begin // 0001 LOAD
                RADDR1 = INSTRUCTION[8:6]; // Address to load from
                RAM_ADDR_SEL = 2'b01; // Selection for the RAM address
                OUT_ENABLE = 1'b1; // Enable RAM output
                WRITE = 1'b1; // Enable register write
                WADDR = INSTRUCTION[11:9]; // Register write address
                REG_WRITEBACK_SEL = 2'b01; // Selector to write back
            end
            4'h2: begin // 0010 STORE
                RADDR1 = INSTRUCTION[8:6]; // Read address 1
                RADDR2 = INSTRUCTION[11:9]; // Read address 2
                RAM_ADDR_SEL = 2'b01; // Selection for RAM address
                IN_ENABLE = 1'b1; // Enable RAM input
                RAM_DIN_SEL = 1'b0; // Selector for input to RAM
            end
            4'h3: begin // 0011 BRANCH
                RADDR1 = INSTRUCTION[11:9]; // Address to read from in the regFile
                if (RDATA1 == 16'h0000) begin // If the value is 0, branch
                    SH_BRANCH = 1'b1; // Enable branching
                    BRANCH_TGT_RAW = {7'b0, INSTRUCTION[8:0]}; // Set the branch target
                end
            end
            4'h4: begin // 0100 JUMP
                SH_BRANCH = 1'b1; // Enable branching
                BRANCH_TGT_RAW = {4'b0, INSTRUCTION[11:0]}; // Set the unconditional branch target
            end
            4'h5: begin // 0101 CALL
                SH_BRANCH = 1'b1; // Enable branching
                BRANCH_TGT_RAW = {4'b0, INSTRUCTION[11:0]}; // Set the callbranch target
                RAM_ADDR_SEL = 2'b00; // Set the address to write to in RAM
                RAM_DIN_SEL = 1'b1; // Set the data to write
                IN_ENABLE = 1'b1; // Enable RAM input
                INC = 1'b1; // Increment the stack
            end
            4'h6: begin // 0110 RETURN
                RAM_ADDR_SEL = 2'b10; // Select the RAM address
                OUT_ENABLE = 1'b1; // Enable RAM output
                DEC = 1'b1; // Decrement the stack
                RET = 1'b1; // Enable return
                SH_BRANCH = 1'b1; // Enable branching
            end
            4'h7: begin // 0111 MOVI
                WADDR = INSTRUCTION[11:9]; // Write address
                IMMEDIATE = {7'b0, INSTRUCTION[8:0]}; // Immediate out
                WRITE = 1'b1; // Enable write
                REG_WRITEBACK_SEL = 2'b10; // Set the write mode
            end
            default: ; // 1000, 1001, 1010, 1011, 1100, 1101, 1110, 1111 INVALID
        endcase
    end
endmodule