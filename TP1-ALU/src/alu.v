module alu #(
    parameter NB_DATA=8,
    parameter NB_OP=6             
)
(
    input wire signed  [NB_DATA-1:0] i_data_a,
    input wire signed  [NB_DATA-1:0] i_data_b,
    input wire         [NB_OP-1:0]   i_operation_code,
    output wire signed [NB_DATA-1:0] o_result,
    output wire o_overflow,
    output wire o_zero
);

localparam ADD_OP = 6'b100000;
localparam SUB_OP = 6'b100010;
localparam AND_OP = 6'b100100;
localparam OR_OP  = 6'b100101;
localparam XOR_OP = 6'b100110;
localparam SRA_OP = 6'b000011;
localparam SRL_OP = 6'b000010;
localparam NOR_OP = 6'b100111;


reg signed [NB_DATA-1:0] result;
reg ovflw;
reg z;


always @(*) begin

    result  = {NB_DATA{1'b0}};
    ovflw   = 1'b0;

    case (i_operation_code)

        ADD_OP: // ADD
            begin
                result = i_data_a + i_data_b; 
                ovflw = (i_data_a[NB_DATA-1]== i_data_b[NB_DATA-1]) & (i_data_a[NB_DATA-1]!=result[NB_DATA-1]);
            end

        SUB_OP: // SUB
            begin
                result = i_data_a - i_data_b;
                ovflw = (i_data_a[NB_DATA-1]!= i_data_b[NB_DATA-1]) & (i_data_a[NB_DATA-1]!=result[NB_DATA-1]);
            end

        AND_OP: result = i_data_a & i_data_b; // AND

        OR_OP: result = i_data_a | i_data_b; // OR

        XOR_OP: result = i_data_a ^ i_data_b; //XOR

        SRA_OP: result = i_data_a >>> i_data_b; //SRA

        SRL_OP: result = i_data_a >> i_data_b; //SRL 

        NOR_OP: result = ~(i_data_a | i_data_b); //NOR

        default: result = {NB_DATA{1'b0}};

    endcase

    z = (result == {NB_DATA{1'b0}});

end

assign o_result = result;
assign o_overflow = ovflw;
assign o_zero = z;

endmodule
