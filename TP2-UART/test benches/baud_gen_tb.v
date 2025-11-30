`timescale 1ns/1ps

module baud_gen_tb;

    // Parámetros
    localparam NB_COUNTER = 9;
    localparam MOD        = 10; // Use small MOD for quick simulation (e.g., 10 instead of 163)

    // Señales
    reg  i_clk;
    reg  i_reset;
    wire o_tick;

    // UUT 
    baud_gen #(
        .NB_COUNTER(NB_COUNTER),
        .MOD(MOD)
    ) uut (
        .i_clk(i_clk),
        .i_reset(i_reset),
        .o_tick(o_tick)
    );

    // Clock generation: 20ns period (50 MHz)
    initial begin
        i_clk = 0;
        forever #10 i_clk = ~i_clk;
    end

    // Test sequence
    initial begin
        $display("Starting baud_rate_gen testbench...");
        
        // Reset
        i_reset = 1;
        repeat (2) @(posedge i_clk); // hold reset for 2 clock cycles
        i_reset = 0;
        
        // 50*20ns = 1000ns
        repeat (50) @(posedge i_clk);

        $display("Test completed!");
        $finish;
    end

    // Optional monitor for tick events
    always @(posedge i_clk) begin
        if (o_tick)
            $display("Tick generated at time %0.3f ns", $realtime);
    end

endmodule