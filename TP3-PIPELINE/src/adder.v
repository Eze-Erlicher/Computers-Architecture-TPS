module adder #(
    parameter NB_DATA = 32
)
(
    input wire  [NB_DATA-1:0] i_data_A,
    input wire  [NB_DATA-1:0] i_data_B,
    output wire [NB_DATA-1:0] o_result
);

reg [NB_DATA-1:0] adder_out;

always @(*) begin
    adder_out = i_data_A + i_data_B;  
end

assign o_result = adder_out;

endmodule