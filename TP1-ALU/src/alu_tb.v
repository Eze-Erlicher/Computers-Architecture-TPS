`timescale 1ns / 1ps


// Testbench para ALU
module alu_tb;

    parameter NB_DATA = 8;
    parameter NB_OP   = 6;

    // Códigos de operación
    localparam OP_ADD = 6'b100000;
    localparam OP_SUB = 6'b100010;
    localparam OP_AND = 6'b100100;
    localparam OP_OR  = 6'b100101;
    localparam OP_XOR = 6'b100110;
    localparam OP_SRA = 6'b000011;
    localparam OP_SRL = 6'b000010;
    localparam OP_NOR = 6'b100111;

    reg [NB_DATA-1:0] data_a, data_b;
    reg  [NB_OP-1:0]   op_code;
    wire [NB_DATA-1:0] result;
    wire overflow, zero;

    alu #(
        .NB_DATA(NB_DATA),
        .NB_OP(NB_OP)
    ) uut (
        .i_data_a(data_a),
        .i_data_b(data_b),
        .i_operation_code(op_code),
        .o_result(result),
        .o_overflow(overflow),
        .o_zero(zero)
    );

    reg [NB_DATA-1:0] A, B, expected;
    reg [NB_OP-1:0] op;


    initial begin
        // Inicialización
        data_a = 0;
        data_b = 0;
        op_code = 0;
        #10;

        repeat (10) begin
            A = $random;
            B = $random;

            // Suma
            expected = A + B;
            run_test(A, B, OP_ADD, expected, "ADD");

            // Resta
            expected = A - B;
            run_test(A, B, OP_SUB, expected, "SUB");

            // AND
            expected = A & B;
            run_test(A, B, OP_AND, expected, "AND");

            // OR
            expected = A | B;
            run_test(A, B, OP_OR, expected, "OR");

            // XOR
            expected = A ^ B;
            run_test(A, B, OP_XOR, expected, "XOR");

            // SRA
            expected = A >>> B;
            run_test(A, B, OP_SRA, expected, "SRA");

            // SLA
            expected = A <<< B;
            run_test(A, B, OP_SRL, expected, "SRL");

            // NOR
            expected = ~(A | B);
            run_test(A, B, OP_NOR, expected, "NOR");
        end

        // Casos específicos para overflow y zero
        // Overflow positivo: 255 + 1 (para 8 bits)
        run_test(255, 1, OP_ADD, 0, "ADD Overflow Positivo");
        // Overflow negativo: 100 - 128 (para 8 bits)
        run_test(100, -128, OP_SUB, 228, "SUB Overflow Negativo");
        // Zero: 5 - 5
        run_test(5, 5, OP_SUB, 0, "SUB Zero");
        // Zero: 0 & 0
        run_test(0, 0, OP_AND, 0, "AND Zero");

        $finish;
    end


    // Tarea de prueba
    task run_test(
        input [NB_DATA-1:0] A,
        input [NB_DATA-1:0] B,
        input [NB_OP-1:0] op,
        input [NB_DATA-1:0] expected,
        input [80:1] op_name
    );
    begin
        data_a = A;
        data_b = B;
        op_code = op;
        #10;
        if (result !== expected)
            $display("ERROR: %0s | A=%d, B=%d | Expected=%d, Obtained=%d | Overflow=%b, Zero=%b", op_name, A, B, expected, result, overflow, zero);
        else
            $display("OK: %0s | A=%d, B=%d | Result=%d | Overflow=%b, Zero=%b", op_name, A, B, result, overflow, zero);
    end
    endtask

endmodule
