module EX_MEM_latch #(

parameter NB_INSTRUCT = 32,
parameter NB_PC = 6,
parameter EX_MEM_SIZE = 79
)
(
//Inputs
input wire i_clk,
input wire i_reset,
input wire i_WB,
input wire i_M,
input wire i_zero,
input wire [NB_PC-1:0] i_sum,
input wire [NB_INSTRUCT-1:0] i_alu_result,
input wire [NB_INSTRUCT-1:0] i_read_data2,
input wire [4:0] i_instruct_11_7,
input wire i_EOF_flag,
input wire [1:0] i_pipeline_mode, // 0: stepwise , 1: continuos
input wire i_run_clockcycle,

//Outputs
output wire o_WB,
output wire o_M,
output wire o_zero,
output wire [NB_PC-1:0] o_sum,
output wire [NB_INSTRUCT-1:0] o_alu_result,
output wire [NB_INSTRUCT-1:0] o_read_data2,
output wire [4:0] o_instruct_11_7,
output wire o_EOF_flag,
output wire [EX_MEM_SIZE-1:0] o_EX_MEM_data 

);

//localparam
localparam CONT_MOD = 2'b01;
localparam STEP_MOD = 2'b11; 

//Auxiliar variables;
reg WB;
reg M;
reg zero;
reg [NB_PC-1:0] sum;
reg [NB_INSTRUCT-1:0] alu_result;
reg [NB_INSTRUCT-1:0] read_data2;
reg [4:0] instruct_11_7;
reg EOF_flag;
reg [EX_MEM_SIZE-1:0]EX_MEM_data; 


always@(posedge i_clk,posedge i_reset)begin
    if(i_reset)begin
        WB <= 0;
        M <= 0; 
        zero <= 0;
        sum <= 0;
        alu_result <= 0;
        read_data2 <= 0;
        instruct_11_7 <= 0;
        EOF_flag <= 0;
        EX_MEM_data <=0;
    end
    
    else if (i_pipeline_mode == CONT_MOD || (i_pipeline_mode == STEP_MOD && i_run_clockcycle)) begin
        EX_MEM_data[0] <= i_WB;
        EX_MEM_data[1] <= i_M;
        EX_MEM_data[2] <= i_zero;
        EX_MEM_data[8:3] <= i_sum;
        EX_MEM_data[40:9] <= i_alu_result;
        EX_MEM_data[72:41] <= i_read_data2;
        EX_MEM_data[77:73] <= i_instruct_11_7; 
        EX_MEM_data[78] <= i_EOF_flag;
        
        WB <= i_WB;
        M <= i_M;
        zero <= i_zero;
        sum <= i_sum;
        alu_result <= i_alu_result; 
        read_data2 <= i_read_data2;
        instruct_11_7 <= i_instruct_11_7;
        EOF_flag <= i_EOF_flag; 
    end
end

assign o_WB = WB;
assign o_M = M;
assign o_zero = zero;
assign o_sum = sum;
assign o_alu_result = alu_result; 
assign o_read_data2 = read_data2;
assign o_instruct_11_7 = instruct_11_7;
assign o_EOF_flag = EOF_flag;
assign o_EX_MEM_data = EX_MEM_data;

endmodule