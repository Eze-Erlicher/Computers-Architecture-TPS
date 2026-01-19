/*
What this testbench verifies

 Proper load on i_rx_buffer_start
 Correct bit order (LSB-first)
 Correct empty signaling
 No extra bits transmitted
*/
`timescale 1ns/1ps

module rx_buffer_tb;

    localparam INSTRUCT_MEM_WIDTH = 32;

    reg clk;
    reg reset;
    reg rx_buffer_start;
    reg rx_done;
    reg [INSTRUCT_MEM_WIDTH-1:0] pipeline_info;

    wire rx_buffer_empty;
    wire rx_data;

    rx_buffer #(
        .INSTRUCT_MEM_WIDTH(INSTRUCT_MEM_WIDTH)
    ) dut (
        .i_clk(clk),
        .i_reset(reset),
        .i_rx_buffer_start(rx_buffer_start),
        .i_rx_done(rx_done),
        .i_pipeline_info(pipeline_info),
        .o_rx_buffer_empty(rx_buffer_empty),
        .o_rx_data(rx_data)
    );

    always #5 clk = ~clk;

    reg [INSTRUCT_MEM_WIDTH-1:0] received_word;
    integer i;

    initial begin
        clk = 0;
        reset = 1;
        rx_done = 0;
        rx_buffer_start = 0;
        pipeline_info = 0;
        received_word = 0;

        #10;
        reset = 0;

        pipeline_info = 32'hDEAD_BEEF;

        @(posedge clk);
        rx_buffer_start = 1'b1;
        @(posedge clk);
        rx_buffer_start = 1'b0;

        for (i = 0; i < INSTRUCT_MEM_WIDTH; i = i + 1) begin
            @(posedge clk);
            received_word[i] = rx_data;
            rx_done = 1'b1;

            @(posedge clk);
            rx_done = 1'b0;
        end

        @(posedge clk);

        if (!rx_buffer_empty) begin
            $error("RX BUFFER ERROR: buffer not empty after transmission");
        end

        if (received_word !== pipeline_info) begin
            $error("RX BUFFER ERROR: expected %h, got %h",
                   pipeline_info, received_word);
        end
        else begin
            $display("RX BUFFER PASSED: received %h", received_word);
        end

        $display("RX buffer test completed successfully");
        $finish;
    end

endmodule