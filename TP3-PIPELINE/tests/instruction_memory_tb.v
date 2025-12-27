`timescale 1ns / 1ps

module instruction_memory_tb;

    parameter PC_WIDTH = 9;
    parameter NB_WIDTH = 32;
    parameter DEPTH = 2**PC_WIDTH;

    reg                 i_clk;
    reg                 i_reset;
    reg                 i_write_enable;
    reg  [PC_WIDTH-1:0] i_address;
    reg  [NB_WIDTH-1:0] write_register;
    wire [NB_WIDTH-1:0] o_instruction;

    reg [NB_WIDTH-1:0] prev_instruction;

    instruction_memory #(
        .PC_WIDTH(PC_WIDTH),
        .NB_WIDTH(NB_WIDTH)
    ) dut (
        .i_clk(i_clk),
        .i_reset(i_reset),
        .i_write_enable(i_write_enable),
        .i_address(i_address),
        .write_register(write_register),
        .o_instruction(o_instruction)
    );

    always #10 i_clk = ~i_clk;

    initial begin
        i_clk = 0;
        i_address = 0;
        i_write_enable = 0;
        write_register = 0;
        i_reset = 0;

        #100
        
        // Load a few instructions and read them back
        for (integer i = 0; i < 10; i = i + 1) begin
            i_address = $random % DEPTH;
            write_register = $random;
            i_write_enable = 1;
            #20;
            i_write_enable = 0;
            #20;
            $display("Write %h to addr %d, read back: %h | Status: %s", write_register, i_address, o_instruction, (o_instruction === write_register) ? "OK" : "ERR");
        end

        // Test reset with last written address
        i_reset = 1;
        #20;
        i_reset = 0;
        #20;
        $display("After reset at addr %d: %h (expected 0)  | Status: %s", i_address, o_instruction, (o_instruction === 0) ? "OK" : "ERR");

        $finish;
    end

endmodule