module Core(
    input CLK
);

    wire RESET;
    wire [15:0] INSTRUCTION;
    wire [7:0] NEXT_PC;
    wire [15:0] RDATA1, RDATA2;
    wire [15:0] ALU_RESULT;
    wire ALU_COUT;
    wire [1:0] ALU_CIN_SEL;
    wire ALU_CIN = (ALU_CIN_SEL == 2'b10) ? CF : (ALU_CIN_SEL == 2'b01) ? 1'b1 : 1'b0;
    wire [15:0] RAM_OUT;
    wire [15:0] STK_PTR;
    wire RET;
    wire [15:0] BRANCH_TGT_RAW;
    wire [15:0] BRANCH_TGT_MUX;
    wire SH_BRANCH;
    wire [2:0] WADDR;
    wire [2:0] RADDR1;
    wire [2:0] RADDR2;
    wire WRITE;
    wire [2:0] SEL;
    wire IN_ENABLE;
    wire OUT_ENABLE;
    wire INC, DEC;
    wire [15:0] IMMEDIATE;
    wire [1:0] RAM_ADDR_SEL;
    wire [1:0] REG_WRITEBACK_SEL;
    wire ALU_B_SEL;
    wire RAM_DIN_SEL;

    reg [15:0] RAM_ADDR;
    reg [15:0] REG_WRITEBACK;
    reg [15:0] ALU_B;
    reg [15:0] RAM_DIN;
    reg CF; // Carry flag

    always @(*) begin
        case (RAM_ADDR_SEL)
            2'b00: RAM_ADDR = STK_PTR;
            2'b01: RAM_ADDR = RDATA1;
            2'b10: RAM_ADDR = STK_PTR - 1;
            default: RAM_ADDR = 16'h0000;
        endcase

        case (REG_WRITEBACK_SEL)
            2'b00: REG_WRITEBACK = ALU_RESULT;
            2'b01: REG_WRITEBACK = RAM_OUT;
            2'b10: REG_WRITEBACK = IMMEDIATE;
            2'b11: REG_WRITEBACK = ~RDATA1;
            default: REG_WRITEBACK = 16'h0000;
        endcase 

        case (ALU_B_SEL)
            1'b0: ALU_B = RDATA2;
            1'b1: ALU_B = RAM_OUT;
            default: ALU_B = 16'h0000;
        endcase

        case (RAM_DIN_SEL) 
            1'b0: RAM_DIN = RDATA2;
            1'b1: RAM_DIN = NEXT_PC;
            default: RAM_DIN = 16'h0000;
        endcase 
    end

    always @(posedge CLK) begin
        if (RESET) CF <= 1'b0;
        else if (CARRY_UPD) CF <= ALU_COUT;
    end

    POR por_inst(.CLK(CLK), .RESET(RESET));

    fetch fetch_inst(
        .CLK(CLK), .PC_CLEAR(RESET), .SH_BRANCH(SH_BRANCH),
        .IR_CLEAR(RESET), .BRANCH_TGT(BRANCH_TGT_MUX),
        .INSTRUCTION(INSTRUCTION), .NEXT_PC(NEXT_PC)
    );

    regFile16 rf_inst(
        .CLK(CLK), .CLEAR(RESET),
        .RADDR1(RADDR1), .RADDR2(RADDR2),
        .WRITE(WRITE), .WADDR(WADDR), .WDATA(REG_WRITEBACK),
        .RDATA1(RDATA1), .RDATA2(RDATA2)
    );

    alu16 alu_inst(
        .A(RDATA1), .B(ALU_B), .SEL(SEL),
        .CIN(ALU_CIN), .RESULT(ALU_RESULT), .COUT(ALU_COUT)
    );

    RAM ram_inst(
        .CLK(CLK), .CLEAR(RESET), .ADDR(RAM_ADDR),
        .DIN(RAM_DIN), .IN_ENABLE(IN_ENABLE), .OUT_ENABLE(OUT_ENABLE),
        .DOUT(RAM_OUT)
    );

    stkPtr stkptr_inst(
        .CLK(CLK), .CLEAR(RESET),
        .INC(INC), .DEC(DEC), .SP(STK_PTR)
    );

    controlUnit cu_inst(
        .INSTRUCTION(INSTRUCTION), .RDATA1(RDATA1), .CLK(CLK),

        .SH_BRANCH(SH_BRANCH), .RET(RET), .BRANCH_TGT_RAW(BRANCH_TGT_RAW),
        .RADDR1(RADDR1), .RADDR2(RADDR2), .WRITE(WRITE), 
        .WADDR(WADDR), .REG_WRITEBACK_SEL(REG_WRITEBACK_SEL), .SEL(SEL),
        .ALU_B_SEL(ALU_B_SEL), .IN_ENABLE(IN_ENABLE), .OUT_ENABLE(OUT_ENABLE),
        .RAM_ADDR_SEL(RAM_ADDR_SEL), .RAM_DIN_SEL(RAM_DIN_SEL), .INC(INC),
        .DEC(DEC), .IMMEDIATE(IMMEDIATE), .CARRY_UPD(CARRY_UPD),
        .ALU_CIN_SEL(ALU_CIN_SEL)
    );

    assign BRANCH_TGT_MUX = RET ? RAM_OUT : BRANCH_TGT_RAW;
endmodule