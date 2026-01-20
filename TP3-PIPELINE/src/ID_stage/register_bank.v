module register_bank #(
    parameter NB_DATA = 32,
    parameter NB_REG  = 5
)
(
    input  wire               i_clk,
    input  wire               i_reset,
    input  wire [NB_REG-1:0]  i_read_reg1,
    input  wire [NB_REG-1:0]  i_read_reg2,
    input  wire [NB_REG-1:0]  i_write_reg,
    input  wire [NB_DATA-1:0] i_write_data,
    input  wire               i_write_enable,

    output wire [NB_DATA-1:0] o_register1,
    output wire [NB_DATA-1:0] o_register2
);

reg [NB_DATA-1:0] registers [2**NB_REG-1:0];

integer i;

always @(negedge i_clk) begin

    if (i_reset) begin
        for (i = 0; i < 2**NB_REG; i = i + 1) begin
            registers[i] <= 0;
        end
    end

    else if (i_write_enable) begin
        registers[i_write_reg] <= i_write_data;
    end
end

assign o_register1 = registers[i_read_reg1];
assign o_register2 = registers[i_read_reg2];

endmodule