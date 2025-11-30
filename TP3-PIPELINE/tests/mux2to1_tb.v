`timescale 1ns / 1ps

module mux2to1_tb;

    parameter NB_DATA = 32;

    reg  [NB_DATA-1:0] i_data_A;
    reg  [NB_DATA-1:0] i_data_B;
    reg                i_sel;
    wire [NB_DATA-1:0] o_data;

    mux2to1 #(
        .NB_DATA(NB_DATA)
    ) uut (
        .i_data_A(i_data_A),
        .i_data_B(i_data_B),
        .i_sel(i_sel),
        .o_data(o_data)
    );

    // Testbench 
    initial begin
        // Casos de prueba
        run_test(32'h00000001, 32'h00000002, 1'b0, 32'h00000001, "Test 1: Select A");
        run_test(32'h00000001, 32'h00000002, 1'b1, 32'h00000002, "Test 2: Select B");

        #10 $finish;
    end

    // Funcion auxiliar para ejecutar pruebas
    task run_test(
        input [NB_DATA-1:0] A,
        input [NB_DATA-1:0] B,
        input sel,
        input [NB_DATA-1:0] expected,
        input [80*8:1] test_name
    );
    begin
        i_data_A = A;
        i_data_B = B;
        i_sel = sel;
        #10;
        if (o_data !== expected)
            $display("ERROR: %0s | A=%d, B=%d, Sel=%b | Esperado=%d, Obtenido=%d", test_name, A, B, sel, expected, o_data);
        else
            $display("OK: %0s | A=%d, B=%d, Sel=%b | Resultado=%d", test_name, A, B, sel, o_data);
    end
    endtask

endmodule