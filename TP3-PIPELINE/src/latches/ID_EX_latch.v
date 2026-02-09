module ID_EX_latch #(

parameter NB_INSTRUCT = 32,
parameter NB_PC = 6,
parameter ID_EX_SIZE = 147
)
(
//Inputs
input wire i_clk,
input wire i_reset,
input wire i_EOF_flag,
input wire [4:0] i_instruct_11_7, 
input wire [3:0] i_instruct_30_14_12,
input wire [63:0] i_imm_gen,
input wire [NB_INSTRUCT-1:0]i_read_data1,i_read_data2,
input wire [NB_PC-1:0]i_PC,
input wire i_EX,
input wire i_M,
input wire i_WB,
input wire [1:0] i_pipeline_mode, // 0: stepwise , 1: continuos
input wire i_run_clockcycle,

//Outputs
output wire o_EOF_flag,
output wire [4:0] o_instruct_11_7, 
output wire [3:0] o_instruct_30_14_12,
output wire [63:0] o_imm_gen,
output wire [NB_INSTRUCT-1:0] o_read_data2,
output wire [NB_INSTRUCT-1:0] o_read_data1,
output wire [NB_PC-1:0] o_PC,
output wire o_EX,
output wire o_M,
output wire o_WB,
output wire [ID_EX_SIZE-1:0] o_ID_EX_data 

);

//localparam
localparam CONT_MOD = 2'b01;
localparam STEP_MOD = 2'b11; 

//Auxiliar variables;
reg EOF_flag;
reg [3:0] instruct_30_14_12;
reg [4:0] instruct_11_7; 
reg [63:0]imm_gen;
reg [NB_INSTRUCT-1:0]read_data2,read_data1;
reg [NB_PC-1:0] PC;
reg EX;
reg M;
reg WB;
reg [ID_EX_SIZE-1:0] ID_EX_data; 

always@(posedge i_clk,posedge i_reset)begin
    
    if(i_reset)begin
        EOF_flag <= 0;
        instruct_11_7 <= 0; 
        instruct_30_14_12 <= 0;
        imm_gen <= 0;
        read_data2 <= 0;
        read_data1 <= 0;
        PC <= 0;
        EX <= 0;
        M <= 0;
        WB <= 0; 
        ID_EX_data <= 0;
    end
    
    else if(i_pipeline_mode == CONT_MOD || (i_pipeline_mode == STEP_MOD && i_run_clockcycle) ) begin
        ID_EX_data[0] <= i_WB;
        ID_EX_data[1] <= i_M;
        ID_EX_data[2] <= i_EX;
        ID_EX_data[8:3] <= i_PC;
        ID_EX_data[40:9] <= i_read_data1;
        ID_EX_data[72:41] <= i_read_data2;
        ID_EX_data[136:73] <= i_imm_gen;
        ID_EX_data[140:137] <= i_instruct_30_14_12;
        ID_EX_data[145:141] <= i_instruct_11_7;
        ID_EX_data[146] <= i_EOF_flag;
    
        WB <= i_WB;
        M <= i_M;
        EX <= i_EX;
        PC <= i_PC;
        read_data1 <= i_read_data1;
        read_data2 <= i_read_data2;
        imm_gen <= i_imm_gen;
        instruct_30_14_12 <= i_instruct_30_14_12;
        instruct_11_7 <= i_instruct_11_7; 
        EOF_flag <= i_EOF_flag;
    end
end


assign o_WB = WB;
assign o_M = M;
assign o_EX = EX;
assign o_PC = PC;
assign o_read_data1 = read_data1;
assign o_read_data2 = read_data2;
assign o_imm_Gen = imm_gen;
assign o_instruct_30_14_12 = instruct_30_14_12;
assign o_instruct_11_7 = instruct_11_7; 
assign o_EOF_flag = EOF_flag;
assign o_ID_EX_data = ID_EX_data;

endmodule