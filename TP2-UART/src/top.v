module top
#(
    parameter NB_DATA   = 8,
    parameter NB_ALU_OP = 6
)
(
    input wire   i_clk,
    input wire   i_reset,
    input wire   i_rx,
    output wire  o_tx
);

wire tick;
wire [NB_DATA-1:0] rx_data;
wire [NB_DATA-1:0] tx_data;
wire rx_done;
wire tx_start;
wire tx_done;

wire [NB_ALU_OP-1:0] alu_opcode;
wire [NB_DATA-1:0] alu_data_A;
wire [NB_DATA-1:0] alu_data_B;
wire [NB_DATA-1:0] alu_result;

// Instances
clk_wiz_0 clk_50MHz
   (
    // Clock out ports
    .clk_out1(clk_out50MHz),     // output clk_out1
    // Status and control signals
    .reset(i_reset), // input reset
    .locked(locked),       // output locked
   // Clock in ports
    .clk_in1(i_clk)      // input clk_in1
);

baud_gen #(
    .BAUD_RATE(19200),
    .CLOCK_FREQ(50_000_000),
    .NB_COUNTER(16)
) baud_unit (
    .i_clk(clk_out50MHz),
    .i_reset(i_reset),
    .o_tick(tick)
);

rx_mod #(
    .NB_DATA(NB_DATA),
    .STOP_TICKS(16)
) rx_unit (
    .i_clk(clk_out50MHz),
    .i_s_tick(tick),
    .i_rx(i_rx),
    .i_reset(i_reset),
    .o_rx_data(rx_data),
    .o_rx_done_tick(rx_done)
);

tx_mod #(
    .NB_DATA(NB_DATA),
    .STOP_TICKS(16)
) tx_unit (
    .i_clk(clk_out50MHz),
    .i_s_tick(tick),
    .i_tx_start(tx_start),
    .i_tx_data(tx_data),
    .i_reset(i_reset),
    .o_tx(o_tx),
    .o_tx_done_tick(tx_done)
);

interface #(
    .NB_DATA(NB_DATA),
    .NB_ALU_OP(NB_ALU_OP)
) interface_unit (
    .i_clk(clk_out50MHz),
    .i_reset(i_reset),
    .i_rx_data(rx_data),
    .i_rx_done(rx_done),
    .i_alu_res(alu_result),
    .o_tx_start(tx_start),
    .o_tx_data(tx_data),
    .o_alu_OP(alu_opcode),
    .o_alu_A(alu_data_A),
    .o_alu_B(alu_data_B)
);

alu #(
    .NB_DATA(NB_DATA),
    .NB_OP(NB_ALU_OP)
) alu_unit (
    .i_data_a(alu_data_A),
    .i_data_b(alu_data_B),
    .i_operation_code(alu_opcode),
    .o_result(alu_result),
    .o_overflow(),
    .o_zero()
);

endmodule