`timescale 1ns / 1ps

module data_memory_tb;

    parameter ADDR_WIDTH = 9;
    parameter DATA_WIDTH = 32;
    parameter DEPTH = 2**ADDR_WIDTH;

    reg                   i_clk;
    reg                   i_reset;
    reg                   i_mem_write;
    reg                   i_mem_read;
    reg  [1:0]            i_mem_size;
    reg                   i_unsigned_op;
    reg  [1:0]            i_byte_offset;
    reg  [ADDR_WIDTH-1:0] i_address;
    reg  [DATA_WIDTH-1:0] i_write_data;
    wire [DATA_WIDTH-1:0] o_read_data;

    reg  [DATA_WIDTH-1:0] expected;

    data_memory #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) dut (
        .i_clk(i_clk),
        .i_reset(i_reset),
        .i_mem_write(i_mem_write),
        .i_mem_read(i_mem_read),
        .i_mem_size(i_mem_size),
        .i_unsigned_op(i_unsigned_op),
        .i_byte_offset(i_byte_offset),
        .i_address(i_address),
        .i_write_data(i_write_data),
        .o_read_data(o_read_data)
    );

    always #10 i_clk = ~i_clk;

    initial begin
        i_clk = 0;
        i_reset = 1;
        i_mem_write = 0;
        i_mem_read = 0;
        i_mem_size = 2'b10; // word
        i_unsigned_op = 0;
        i_byte_offset = 2'b00;
        i_address = 0;
        i_write_data = 0;

        #20;
        i_reset = 0;

        // Test word operations
        for (integer i = 0; i < 5; i = i + 1) begin
            i_address = $random % DEPTH;
            i_write_data = $random;
            i_mem_size = 2'b10;
            i_mem_write = 1;
            #20;
            i_mem_write = 0;
            i_mem_read = 1;
            #20;
            expected = i_write_data;
            $display("%s: addr %3d, write %08h, read %08h | Status: %s", "Word test", i_address, i_write_data, o_read_data, (o_read_data === expected) ? "OK" : "ERR");
            i_mem_read = 0;
        end

        // Test byte operations
        for (integer i = 0; i < 5; i = i + 1) begin
            i_address = $random % DEPTH;
            i_byte_offset = $random % 4;
            i_write_data = $random % 256;
            i_mem_size = 2'b00;
            i_mem_write = 1;
            #20;
            i_mem_write = 0;
            // Read signed
            i_unsigned_op = 0;
            i_mem_read = 1;
            #20;
            expected = {{24{i_write_data[7]}}, i_write_data[7:0]};
            $display("%s: addr %3d, offset %d, write %08h, read %08h | Status: %s", "Byte signed test  ", i_address, i_byte_offset, i_write_data[7:0], o_read_data, (o_read_data === expected) ? "OK" : "ERR");
            i_mem_read = 0;
            // Read unsigned
            i_unsigned_op = 1;
            i_mem_read = 1;
            #20;
            expected = {24'b0, i_write_data[7:0]};
            $display("%s: addr %3d, offset %d, write %08h, read %08h | Status: %s", "Byte unsigned test", i_address, i_byte_offset, i_write_data[7:0], o_read_data, (o_read_data === expected) ? "OK" : "ERR");
            i_mem_read = 0;
        end

        // Test halfword operations
        for (integer i = 0; i < 5; i = i + 1) begin
            i_address = $random % DEPTH;
            i_byte_offset = $random % 2 * 2; // 0 or 2
            i_write_data = $random % 65536;
            i_mem_size = 2'b01;
            i_mem_write = 1;
            #20;
            i_mem_write = 0;
            // Read signed
            i_unsigned_op = 0;
            i_mem_read = 1;
            #20;
            expected = {{16{i_write_data[15]}}, i_write_data[15:0]};
            $display("%s: addr %3d, offset %d, write %08h, read %08h | Status: %s", "Half signed test  ", i_address, i_byte_offset, i_write_data[15:0], o_read_data, (o_read_data === expected) ? "OK" : "ERR");
            i_mem_read = 0;
            // Read unsigned
            i_unsigned_op = 1;
            i_mem_read = 1;
            #20;
            expected = {16'b0, i_write_data[15:0]};
            $display("%s: addr %3d, offset %d, write %08h, read %08h | Status: %s", "Half unsigned test", i_address, i_byte_offset, i_write_data[15:0], o_read_data, (o_read_data === expected) ? "OK" : "ERR");
            i_mem_read = 0;
        end

        $finish;
    end

endmodule