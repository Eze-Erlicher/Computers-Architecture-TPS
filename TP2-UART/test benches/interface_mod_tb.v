`timescale 1ns/1ps

module interface_mod_tb;

    // Parameters
    localparam NB_DATA = 8;

    // DUT Inputs
    reg                  i_clk;
    reg                  i_reset;
    reg                  i_rx_done;
    reg  [NB_DATA-1:0]   i_rx_data;
    reg  [NB_DATA-1:0]   i_alu_res;

    // DUT Outputs
    wire [NB_DATA-1:0]   o_tx_data;
    wire                 o_tx_start;
    wire [NB_DATA-1:0]   o_alu_A;
    wire [NB_DATA-1:0]   o_alu_B;
    wire [NB_DATA-1:0]   o_alu_OP;

    // Instantiate DUT
    interface #(
        .NB_DATA(NB_DATA)
    ) uut (
        .i_clk(i_clk),
        .i_reset(i_reset),
        .i_rx_done(i_rx_done),
        .i_rx_data(i_rx_data),
        .i_alu_res(i_alu_res),
        .o_tx_data(o_tx_data),
        .o_tx_start(o_tx_start),
        .o_alu_A(o_alu_A),
        .o_alu_B(o_alu_B),
        .o_alu_OP(o_alu_OP)
    );

    // Clock generation
    initial begin
        i_clk = 0;
        forever #10 i_clk = ~i_clk; // 50 MHz clock
    end

    // Reset sequence
    initial begin
        i_reset = 1;
        i_rx_done = 0;
        i_rx_data = 0;
        i_alu_res = 8'h17; // Suppose ALU result is 0x17 (A=0x12 + B=0x05)
        #20 i_reset = 0;
    end

    // Stimulus
    initial begin
        // Wait for reset release
        #30;

        // Command 0x01: Set A
        send_byte(8'b00000001);
        send_byte(8'h12); // A = 0x12

        // Command 0x02: Set B                                                
        send_byte(8'b00000010);
        send_byte(8'h05); // B = 0x05

        // Command 0x03: Set operation
        send_byte(8'b00000011);
        send_byte(8'h01); // OP = 1 (ADD)

        // Command 0x00: Request result transmission
        send_byte(8'h00);

        // Wait to observe TX
        #100;

        $display("Test finished.");
        $finish;
    end

    // Task to simulate RX byte reception
    task send_byte(input [7:0] data);
        begin
            @(negedge i_clk);
            i_rx_data = data;
            i_rx_done = 1;
            @(negedge i_clk);
            i_rx_done = 0;
            #20;
        end
    endtask

    // Monitor
    initial begin
        $monitor("[%0t] RX_DATA=%h, RX_DONE=%b | A=%h, B=%h, OP=%h | TX_START=%b TX_DATA=%h",
                 $time, i_rx_data, i_rx_done, o_alu_A, o_alu_B, o_alu_OP, o_tx_start, o_tx_data);
    end


endmodule
