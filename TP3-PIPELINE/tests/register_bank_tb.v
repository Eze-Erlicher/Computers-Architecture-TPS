`timescale 1ns / 1ps

module register_bank_tb;

    parameter NB_DATA = 32;
    parameter NB_REG  = 5;

    reg                  i_clk;
    reg                  i_reset;
    reg                  i_write_enable;
    reg  [NB_REG-1:0]    i_write_reg;
    reg  [NB_DATA-1:0]   i_write_data;
    reg  [NB_REG-1:0]    i_read_reg1;
    reg  [NB_REG-1:0]    i_read_reg2;
    wire [NB_DATA-1:0]   o_register1;
    wire [NB_DATA-1:0]   o_register2;

    reg  [NB_DATA-1:0]   exp1;
    reg  [NB_DATA-1:0]   exp2;
    reg  [NB_REG-1:0]    reg1, reg2;

    register_bank #(
        .NB_DATA(NB_DATA),
        .NB_REG (NB_REG)
    ) dut (
        .i_clk(i_clk),
        .i_reset(i_reset),
        .i_read_reg1(i_read_reg1),
        .i_read_reg2(i_read_reg2),
        .i_write_reg(i_write_reg),
        .i_write_data(i_write_data),
        .i_write_enable(i_write_enable),
        .o_register1(o_register1),
        .o_register2(o_register2)
    );

    always #5 i_clk = ~i_clk;

    initial begin

        i_clk = 0; i_reset = 1;
        i_write_enable = 0;
        i_write_reg = 0; i_write_data = 0;
        i_read_reg1 = 0; i_read_reg2 = 0;

        #10;
        i_reset = 0;

        for (integer i = 0; i < (2**NB_REG)/2; i = i + 1) begin

            reg1 = $random % (2**NB_REG);
            reg2 = $random % (2**NB_REG);

            // Ensure the two registers are different
            while (reg1 == reg2) begin
                reg2 = $random % (2**NB_REG);
            end

            exp1 = $random & 32'hFFFFFFFF;
            i_write_reg = reg1;
            i_write_data = exp1;
            i_write_enable = 1;

            #10;
            i_write_enable = 0; #10;
            i_read_reg1 = reg1; #10;
            $display("[WRITE] reg%3d = %10d -> [READ] reg%3d = %10d | Status: %s", reg1, exp1, reg1, o_register1, (o_register1 === exp1) ? "OK" : "ERR");

            exp2 = $random & 32'hFFFFFFFF;
            i_write_reg = reg2; 
            i_write_data = exp2;
            i_write_enable = 1;

            #10;
            i_write_enable = 0; #10;
            i_read_reg1 = reg2; #10;

            $display("[WRITE] reg%3d = %10d -> [READ] reg%3d = %10d | Status: %s", reg2, exp2, reg2, o_register1, (o_register1 === exp2) ? "OK" : "ERR");

            i_read_reg1 = reg1; i_read_reg2 = reg2; #10;
            $display("[DOUBLE READ] reg%3d = %10d (Expected: %10d)  | Status: %s", reg1, o_register1, exp1, (o_register1 === exp1) ? "OK" : "ERR");
            $display("[DOUBLE READ] reg%3d = %10d (Expected: %10d)  | Status: %s\n", reg2, o_register2, exp2, (o_register2 === exp2) ? "OK" : "ERR");

            #10;
        end
        
        $finish;
    end

endmodule