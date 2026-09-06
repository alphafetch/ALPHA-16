module alu16(
    input [15:0] A,
    input [15:0] B,
    input [2:0] SEL,
    input CIN,
    output reg [15:0] RESULT,
    output reg COUT
);

    always @(*) begin
        case (SEL)
            3'b000: {COUT, RESULT} = A + B + CIN;
            3'b001: {COUT, RESULT} = {1'b0, A} + {1'b0, ~B} + CIN;
            3'b010: {COUT, RESULT} = A & B + 0;
            3'b011: {COUT, RESULT} = A | B + 0;
            3'b100: {COUT, RESULT} = A ^ B + 0;
            default: RESULT = 16'h0000;
        endcase
    end
endmodule