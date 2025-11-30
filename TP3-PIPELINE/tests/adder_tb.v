`timescale 1ns / 1ps

module adder_tb;

    // Parameters
    parameter NB_DATA = 32;

    reg  [NB_DATA-1:0] i_data_A;
    reg  [NB_DATA-1:0] i_data_B;
    wire [NB_DATA-1:0] o_result;

    adder #(
        .NB_DATA(NB_DATA)
    ) uut (
        .i_data_A(i_data_A),
        .i_data_B(i_data_B),
        .o_result(o_result)
    );

    // Testbench 
    initial begin
        // Inicializacion
        i_data_A = 0;
        i_data_B = 0;

        // Casos de prueba
        run_test(32'h00000001, 32'h00000001, 32'h00000002, "Test 1: 1 + 1");
        run_test(32'hFFFFFFFF, 32'h00000001, 32'h00000000, "Test 2: -1 + 1");
        run_test(32'h7FFFFFFF, 32'h00000001, 32'h80000000, "Test 3: Max int + 1");
        run_test(32'h80000000, 32'hFFFFFFFF, 32'h7FFFFFFF, "Test 4: Min int - 1");

        #10 $finish;
    end

    initial begin
        $monitor("Time: %0t | A: %h | B: %h | Resultado: %h", $time, i_data_A, i_data_B, o_result);
    end

    // Funcion auxiliar para ejecutar pruebas
    task run_test(
        input [NB_DATA-1:0] A,
        input [NB_DATA-1:0] B,
        input [NB_DATA-1:0] expected,
        input [80*8:1] test_name
    );
    begin
        i_data_A = A;
        i_data_B = B;
        #10;
        if (o_result !== expected)
            $display("ERROR: %0s | A=%d, B=%d | Esperado=%d, Obtenido=%d", test_name, A, B, expected, o_result);
        else
            $display("OK: %0s | A=%d, B=%d | Resultado=%d", test_name, A, B, o_result);
    end
    endtask

endmodule