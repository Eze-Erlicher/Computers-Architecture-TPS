module top #(
    parameter N_SWITCHES=8,
    parameter N_BUTTONS=3,
    parameter NB_OPERATIONS=6,
    parameter N_LEDS=8
)
(
    input wire                   i_clk,
    input wire  [N_SWITCHES-1:0] i_sw,
    input wire  [N_BUTTONS-1:0]  i_button,
    input wire                   reset_button,
    output wire [N_LEDS-1:0]     o_led,
    output wire                  o_overflow,
    output wire                  o_zero
);

//Internal signals
    reg signed [N_SWITCHES-1:0] i_data_a, i_data_b;
    reg [NB_OPERATIONS-1:0]i_operation_code;

    alu #(
        .NB_DATA(N_SWITCHES),
        .NB_OP(NB_OPERATIONS)
    ) alu_unit (
        .i_data_a(i_data_a),
        .i_data_b(i_data_b),
        .i_operation_code(i_operation_code),
        .o_result(o_led),
        .o_overflow(o_overflow),
        .o_zero(o_zero)
    );

    always @(posedge i_clk) begin

        if (reset_button) begin
            i_data_a <= {(N_SWITCHES) {1'b0}};
            i_data_b <= {(N_SWITCHES) {1'b0}};
            i_operation_code <= {(NB_OPERATIONS) {1'b0}};
        end

        else begin 
            if (i_button[0]) begin //Pulsador 1 = Data A
                i_data_a <= i_sw;
            end
            if (i_button[1]) begin //Pulsador 2 = Data B
                i_data_b <= i_sw;
            end
            if (i_button[2]) begin //Pulsador 3 = Operation
                i_operation_code <= i_sw[NB_OPERATIONS-1:0]; 
            end
        end

    end

endmodule
