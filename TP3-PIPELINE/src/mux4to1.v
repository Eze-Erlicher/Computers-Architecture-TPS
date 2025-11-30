module mux4to1 #(
    parameter NB_DATA = 32
)
(
    input  wire [NB_DATA-1:0] i_data_A,
    input  wire [NB_DATA-1:0] i_data_B,
    input  wire [NB_DATA-1:0] i_data_C,
    input  wire [NB_DATA-1:0] i_data_D,
    input  wire [1:0]         i_sel,
    output wire [NB_DATA-1:0] o_data
);

reg [NB_DATA-1:0] mux_out;

always @(*) begin
    case (i_sel)
        2'b00: mux_out = i_data_A;
        2'b01: mux_out = i_data_B;
        2'b10: mux_out = i_data_C;
        2'b11: mux_out = i_data_D;
        default: mux_out = {NB_DATA{1'b0}};
    endcase
end

assign o_data = mux_out;

endmodule