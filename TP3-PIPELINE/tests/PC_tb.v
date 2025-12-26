`timescale 1ns / 1ps

module PC_tb;

    parameter NB_DATA = 32;

    reg                  i_clk;
    reg                  i_reset;
    reg                  i_PCwrite;
    reg  [NB_DATA-1:0]   i_PC;
    wire [NB_DATA-1:0]   o_PC;

    reg  [NB_DATA-1:0]   exp_PC;
    reg  [NB_DATA-1:0]   prev_PC;

    PC #(
        .NB_DATA(NB_DATA)
    ) dut (
        .i_clk(i_clk),
        .i_reset(i_reset),
        .i_PCwrite(i_PCwrite),
        .i_PC(i_PC),
        .o_PC(o_PC)
    );

    always #5 i_clk = ~i_clk;

    initial begin
        i_clk = 0; i_reset = 1;
        i_PCwrite = 0;
        i_PC = 0;

        #10;
        i_reset = 0;

        // Test multiple writes
        for (integer i = 0; i < 10; i = i + 1) begin
            exp_PC = $random & 32'hFFFFFFFF;
            i_PC = exp_PC;
            i_PCwrite = 1;
            #10;
            i_PCwrite = 0;
            #10;
            $display("[WRITE] i_PC = %10d -> o_PC = %10d | Status: %s", exp_PC, o_PC, (o_PC === exp_PC) ? "OK" : "ERR");

            // Test no write (PC should hold)
            prev_PC = o_PC;
            i_PC = $random & 32'hFFFFFFFF; // Change input but no write
            #10;
            $display("[HOLD] o_PC = %10d | Expected: %10d | Status: %s", o_PC, prev_PC, (o_PC === prev_PC) ? "OK" : "ERR");
        end

        // Test reset
        i_reset = 1; #10;
        $display("[RESET] o_PC = %10d | Expected: 0 | Status: %s", o_PC, (o_PC === 0) ? "OK" : "ERR");
        i_reset = 0; #10;

        $finish;
    end

endmodule