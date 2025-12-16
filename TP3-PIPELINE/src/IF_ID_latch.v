module IF_ID_latch #(

parameter NB_INSTRUCT = 32,
parameter NB_PC = 9

)
(
input wire                    i_clk,
input wire                    i_reset,
input wire                    i_IF_flush,
input wire                    i_IF_ID_write,
input wire [NB_INSTRUCT-1:0]  i_instruction,
input wire [NB_PC-1:0]        i_PC,

output wire [NB_INSTRUCT-1:0] o_instruction,
output wire [NB_PC-1:0]       o_PC
);

reg [NB_INSTRUCT-1:0] instruct_buffer;
reg [NB_PC-1:0]       PC_buffer;

always @(posedge i_clk)begin

    if(i_reset)begin
        instruct_buffer <= {NB_INSTRUCT{1'b0}};
        PC_buffer <= 0;        
    end
    
    else if (i_IF_flush) begin
        instruct_buffer <= {NB_INSTRUCT{1'b0}};
    end
    
    else begin
        if (i_IF_ID_write)begin
            instruct_buffer <= i_instruction;  
        end      
    end

end

assign o_instruction = instruct_buffer;
assign o_PC = PC_buffer;

endmodule