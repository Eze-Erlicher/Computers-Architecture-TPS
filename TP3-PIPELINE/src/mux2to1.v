module mux2to1 #(
    parameter NB_DATA = 32
)
(
    input  wire [NB_DATA-1:0] i_data_A,
    input  wire [NB_DATA-1:0] i_data_B,
    input  wire               i_sel,
    output wire [NB_DATA-1:0] o_data
);

reg [NB_DATA-1:0] mux_out;

always @(*) begin
    case (i_sel)
        1'b0: mux_out = i_data_A;
        1'b1: mux_out = i_data_B;
        default: mux_out = {NB_DATA{1'b0}};
    endcase
end

assign o_data = mux_out;

endmodule