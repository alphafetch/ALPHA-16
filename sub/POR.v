module POR(
    input CLK,
    output reg RESET
);
    reg [3:0] counter = 0;

    always @(posedge CLK) begin
        if (counter < 4'hF) begin
            counter <= counter + 1;
            RESET <= 1;
        end else begin
            RESET <= 0;
        end
    end
endmodule