module stkPtr(
    input CLK,
    input CLEAR,
    input INC,
    input DEC,
    output reg [15:0] SP
);

    always @(posedge CLK) begin
        if (CLEAR)
            SP <= 16'h0000;
        else if (INC && DEC)
            SP <= SP;
        else if (INC && !DEC)
            SP <= SP + 1;
        else if (DEC && !INC)
            SP <= SP - 1;
    end
endmodule