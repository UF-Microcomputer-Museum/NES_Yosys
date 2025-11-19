module clk_div(
    input clk,
    input rst,
    output reg div
);

    wire clk;

    initial begin
        div = 0;
    end

    always @(posedge clk) begin
        if (!rst) begin
            div <= 0;
        end
        else begin
            div <= ~div;
        end
    end

endmodule