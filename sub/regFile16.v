module regFile16(
    input CLK,
    input [2:0] RADDR1,
    input [2:0] RADDR2,
    input WRITE,
    input [2:0] WADDR,
    input [15:0] WDATA,
    input CLEAR,

    output [15:0] RDATA1,
    output [15:0] RDATA2
);

    reg [15:0] registers [0:7];
    integer i;
    always @(posedge CLK) begin
        if (CLEAR) begin
            for (i = 0; i < 8; i = i + 1) begin
                registers[i] <= 16'h0000;
            end
        end

        if (WRITE) begin
            registers[WADDR] <= WDATA;
        end
    end

    assign RDATA1 = registers[RADDR1];
    assign RDATA2 = registers[RADDR2];
endmodule