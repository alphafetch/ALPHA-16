module fetch(
    input CLK,
    input PC_CLEAR,
    input SH_BRANCH,
    input IR_CLEAR,
    input [15:0] BRANCH_TGT,
    input PC_HOLD,
    
    output reg [15:0] INSTRUCTION,
    output reg [7:0] NEXT_PC
);

    reg [7:0] PC;
    reg [15:0] ROM [0:255];

    // File `program.hex` in directory that it is run from
    initial $readmemh("./program.hex", ROM); 

    always @(posedge CLK) begin
        if (PC_CLEAR) begin
            PC <= 8'h00;
            NEXT_PC <= 8'h00;
        end else if (PC_HOLD) PC <= PC;
        else if (SH_BRANCH) begin
            PC <= BRANCH_TGT[7:0];
            NEXT_PC <= PC + 1;
        end else begin
            PC <= PC + 1;
            NEXT_PC <= PC + 1;
        end

        if (IR_CLEAR)
            INSTRUCTION <= 16'h0000;
        else
            INSTRUCTION <= ROM[PC];
    end
endmodule