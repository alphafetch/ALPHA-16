module RAM(
    input CLK,
    input CLEAR,
    input [15:0] ADDR,
    input [15:0] DIN,
    input IN_ENABLE,
    input OUT_ENABLE,
    output [15:0] DOUT
);

    reg [15:0] RAM [0:65535];
    integer i;

    always @(posedge CLK) begin
        if (CLEAR) begin
            for (i = 0; i < 65536; i = i + 1) begin
                RAM[i] <= 16'h0000;
            end
        end

        if (IN_ENABLE)
            RAM[ADDR] <= DIN;
    end

    assign DOUT = OUT_ENABLE ? RAM[ADDR] : 16'h0000;
endmodule