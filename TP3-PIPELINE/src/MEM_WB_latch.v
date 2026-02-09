module MEM_WB_latch #(

parameter NB_INSTRUCT = 32,
parameter NB_PC = 6,
parameter MEM_WB_SIZE = 71
)
(
//Inputs
input wire i_clk,
input wire i_reset,
input wire i_WB,
input wire [NB_INSTRUCT-1:0] i_read_data,
input wire [NB_INSTRUCT-1:0] i_alu_result,
input wire [4:0] i_instruct_11_7,
input wire i_EOF_flag,
input wire [1:0] i_pipeline_mode, // 0: stepwise , 1: continuos
input wire i_run_clockcycle,

//Outputs
output wire o_WB,
output wire [NB_INSTRUCT-1:0] o_read_data,
output wire [NB_INSTRUCT-1:0] o_alu_result,
output wire [4:0] o_instruct_11_7,
output wire o_EOF_flag,
output wire [MEM_WB_SIZE-1:0] o_MEM_WB_data

);

//localparam
localparam CONT_MOD = 2'b01;
localparam STEP_MOD = 2'b11;

//Auxiliar variables;
reg WB;
reg [NB_INSTRUCT-1:0] read_data;
reg [NB_INSTRUCT-1:0] alu_result;
reg [4:0] instruct_11_7;
reg EOF_flag;
reg [MEM_WB_SIZE-1:0]MEM_WB_data; 


always@(posedge i_clk,posedge i_reset)begin
    if(i_reset)begin
        WB <= 0;
        read_data <= 0;
        alu_result <= 0;
        instruct_11_7 <= 0;
        EOF_flag <= 0;
        MEM_WB_data <= 0;
    end
    
    else if(i_pipeline_mode == CONT_MOD || (i_pipeline_mode == STEP_MOD && i_run_clockcycle))begin
        MEM_WB_data[0] <= i_WB;
        MEM_WB_data[32:1] <= i_read_data;
        MEM_WB_data[64:33] <= i_alu_result;
        MEM_WB_data[69:65] <= i_instruct_11_7;
        MEM_WB_data[70] <= i_EOF_flag;
        
        WB <= i_WB;
        read_data <= i_read_data;
        alu_result <= i_alu_result; 
        instruct_11_7 <= i_instruct_11_7;
        EOF_flag <= i_EOF_flag; 
    end
end

assign o_WB = WB;
assign o_read_data = read_data;
assign o_alu_result = alu_result; 
assign o_instruct_11_7 = instruct_11_7;
assign o_EOF_flag = EOF_flag;
assign o_MEM_WB_data = MEM_WB_data;

endmodule