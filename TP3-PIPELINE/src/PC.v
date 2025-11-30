module PC #(
    parameter NB_DATA = 32
)
(
    input  wire               i_clk,
    input  wire               i_reset,
    input  wire               i_PCwrite,
    input  wire [NB_DATA-1:0] i_PC,
    output wire [NB_DATA-1:0] o_PC
);

reg [NB_DATA-1:0] out_PC;

always @(posedge i_clk, posedge i_reset) begin

    if(i_reset) begin
        out_PC = 0;
    end

    else begin
        if(i_PCwrite) begin
            out_PC <= i_PC;
        end
    end
end

assign o_PC = out_PC;

endmodule