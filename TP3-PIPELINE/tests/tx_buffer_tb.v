/*
This testbench Sends a known 32-bit pattern bit by bit and Verifying:
Correct word assembly and Single-cycle o_tx_buffer_done pulse

*/

`timescale 1ns/1ps

module tx_buffer_tb;

    localparam INSTRUCT_MEM_WIDTH = 32;

    reg clk;
    reg reset;
    reg tx_done;
    reg tx_data;

    wire [INSTRUCT_MEM_WIDTH-1:0] instruct;
    wire buffer_done;

    tx_buffer #(
        .INSTRUCT_MEM_WIDTH(INSTRUCT_MEM_WIDTH)
    ) dut (
        .i_clk(clk),
        .i_reset(reset),
        .i_tx_done(tx_done),
        .i_tx_data(tx_data),
        .o_instruct_or_command(instruct),
        .o_tx_buffer_done(buffer_done)
    );

    // Clock generation
    always #5 clk = ~clk;

    reg [INSTRUCT_MEM_WIDTH-1:0] test_word;

    initial begin
        clk     = 0;
        reset   = 1;
        tx_done = 0;
        tx_data = 0;

        test_word = 32'hA5A5_3C3C;

        // Reset
        #10;
        reset = 0;

        // Send bits LSB-first
        for (integer i = 0; i < INSTRUCT_MEM_WIDTH; i = i+1)begin
            @(posedge clk);
            tx_data = test_word[i];
            tx_done = 1'b1;

            @(posedge clk);
            tx_done = 1'b0;
        end
        
        
        if (!buffer_done) begin
            $error("TX BUFFER ERROR: buffer_done not asserted");
        end
        
        // Check result
        if (instruct !== test_word) begin
            $error("TX BUFFER ERROR: Expected %h, got %h", test_word, instruct);
        end else begin
            $display("TX BUFFER PASSED: Received %h", instruct);
        end

        // Ensure pulse is one cycle
        @(posedge clk);
        if (buffer_done) begin
            $error("TX BUFFER ERROR: buffer_done longer than 1 cycle");
        end

        $display("Test completed successfully");
        $finish;
    end

endmodule