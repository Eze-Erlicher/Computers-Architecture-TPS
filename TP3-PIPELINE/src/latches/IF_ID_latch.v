module IF_ID_latch #(

parameter NB_INSTRUCT = 32,
parameter NB_PC = 6,
parameter IF_ID_SIZE = 40

)
(
input wire i_clk,
input wire i_reset,
input wire i_IF_flush,
input wire i_IF_ID_write,
input wire [NB_INSTRUCT-1:0] i_instruction,
input wire [NB_PC-1:0]i_PC,
input wire [1:0] i_pipeline_mode, // 0: stepwise , 1: continuos
input wire i_run_clockcycle,

output wire [NB_INSTRUCT-1:0] o_instruction ,
output wire [NB_PC-1:0] o_PC,
output wire o_EOF_flag,
output wire [IF_ID_SIZE-1:0] o_IF_ID_data 
);

//localparam
localparam [NB_INSTRUCT-1:0] instructs_eof = "ieof";
localparam CONT_MOD = 2'b01;
localparam STEP_MOD = 2'b11; 

//Auxiliar varibales
reg [NB_INSTRUCT-1:0] instruction;
reg [NB_PC-1:0] PC;
reg EOF_flag;
reg [IF_ID_SIZE-1:0] IF_ID_data ;

always @(posedge i_clk)begin
    
    if(i_reset || i_IF_flush)begin
        instruction <= {NB_INSTRUCT{1'b0}};
        PC <= 0;
        EOF_flag <= 0;
        IF_ID_data <= 0;
    end
    
    else begin
        
        if (i_IF_ID_write && (i_pipeline_mode == CONT_MOD || (i_pipeline_mode == STEP_MOD && i_run_clockcycle)) )begin
            IF_ID_data[0] <= i_IF_flush;
            IF_ID_data[1] <= i_IF_ID_write;
            IF_ID_data[2 +:NB_PC] <= i_PC;
            IF_ID_data[8 +: NB_INSTRUCT] <= i_instruction;
            
            instruction <= i_instruction;
            EOF_flag <= (i_instruction == instructs_eof);
            PC <= i_PC;  
        end
             
    end

end

assign o_instruction = instruction;
assign o_PC = PC;
assign o_EOF_flag = EOF_flag;
assign o_IF_ID_data = IF_ID_data;

endmodule