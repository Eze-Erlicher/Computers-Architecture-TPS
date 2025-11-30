`timescale 1ns / 1ps

module mux4to1_tb;

    parameter NB_DATA = 32;

    reg  [NB_DATA-1:0] i_data_A;
    reg  [NB_DATA-1:0] i_data_B;
    reg  [NB_DATA-1:0] i_data_C;
    reg  [NB_DATA-1:0] i_data_D;
    reg  [1:0]         i_sel;
    wire [NB_DATA-1:0] o_data;

    mux4to1 #(
        .NB_DATA(NB_DATA)
    ) uut (
        .i_data_A(i_data_A),
        .i_data_B(i_data_B),
        .i_data_C(i_data_C),
        .i_data_D(i_data_D),
        .i_sel(i_sel),
        .o_data(o_data)
    );

    // Testbench
    initial begin
        // Casos de prueba
        run_test(32'h00000001, 32'h00000002, 32'h00000003, 32'h00000004, 2'b00, 32'h00000001, "Test 1: Select A");
        run_test(32'h00000001, 32'h00000002, 32'h00000003, 32'h00000004, 2'b01, 32'h00000002, "Test 2: Select B");
        run_test(32'h00000001, 32'h00000002, 32'h00000003, 32'h00000004, 2'b10, 32'h00000003, "Test 3: Select C");
        run_test(32'h00000001, 32'h00000002, 32'h00000003, 32'h00000004, 2'b11, 32'h00000004, "Test 4: Select D");

        #10 $finish;
    end

    // Funcion auxiliar para ejecutar pruebas
    task run_test(
        input [NB_DATA-1:0] A,
        input [NB_DATA-1:0] B,
        input [NB_DATA-1:0] C,
        input [NB_DATA-1:0] D,
        input [1:0] sel,
        input [NB_DATA-1:0] expected,
        input [80*8:1] test_name
    );
    begin
        i_data_A = A;
        i_data_B = B;
        i_data_C = C;
        i_data_D = D;
        i_sel = sel;
        #10;
        if (o_data !== expected)
            $display("ERROR: %0s | A=%d, B=%d, C=%d, D=%d, Sel=%b | Esperado=%d, Obtenido=%d", test_name, A, B, C, D, sel, expected, o_data);
        else
            $display("OK: %0s | A=%d, B=%d, C=%d, D=%d, Sel=%b | Resultado=%d", test_name, A, B, C, D, sel, o_data);
    end
    endtask

endmodule