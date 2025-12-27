
// https://chipdemy.com/verilog-memory/
module instruction_memory #(

// memoria  de 512 slots =512*32bits= 2048bytes
    parameter PC_WIDTH = 9, 
    parameter NB_WIDTH = 32

)
(
    input  wire                i_clk,
    input  wire                i_reset,
    input  wire                i_write_enable,
    input  wire [PC_WIDTH-1:0] i_address,
    input  wire [NB_WIDTH-1:0] write_register,
    output wire [NB_WIDTH-1:0] o_instruction
);

parameter DEPTH = 2**PC_WIDTH;

reg [NB_WIDTH-1:0] out_instruction;
reg [NB_WIDTH-1:0] ram_mem [DEPTH-1:0];


always @(posedge i_clk) begin

    if(i_reset) begin
        ram_mem[i_address] <= {NB_WIDTH {1'b0}};
    end

    else if(i_write_enable) begin
        ram_mem[i_address] <= write_register;   
    end

    else begin
        out_instruction <= ram_mem[i_address];
    end
end

assign o_instruction = out_instruction;

endmodule