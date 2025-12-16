module instruction_fetch_top #(
    parameter PC_WIDTH = 9,
    parameter NB_DATA  = 32,
)
(
    input  wire                i_clk,
    input  wire                i_reset,
    input  wire                i_enable,
    input  wire                i_PCSource,
    input  wire [NB_DATA-1:0]  i_branch_address,
    output wire [PC_WIDTH-1:0] o_PC,
    output wire [NB_DATA-1:0]  o_instruction,
)

wire out_adder;
wire [PC_WIDTH-1:0] out_mux;

mux2to1 #(
    .NB_DATA(PC_WIDTH)
) mux_unit
(
    .i_data0(out_adder),
    .i_data1(i_branch_address),
    .i_select(i_PCSource),
    .o_data(out_mux)
);

adder #(
    .NB_DATA(PC_WIDTH)
) adder_unit
(
    .i_data0(o_PC),
    .i_data1(4),
    .o_data(out_adder)
);

PC #(
    .NB_DATA(NB_DATA)
) pc_unit
(
    .i_clk(i_clk),
    .i_reset(i_reset),
    .i_PCwrite(i_enable),
    .i_PC(in_PCmux),
    .o_PC(o_PC)
);

IF_ID_latch #(
    .NB_INSTRUCT(NB_DATA),
    .NB_PC(PC_WIDTH)
) latch_unit
(
    .i_clk(i_clk),
    .i_reset(i_reset),
    .i_IF_flush(),
    .i_IF_ID_write(),
    .i_instruction(),
    .i_PC(o_PC),
    .o_instruction(o_instruction),
    .o_PC()
);


endmodule