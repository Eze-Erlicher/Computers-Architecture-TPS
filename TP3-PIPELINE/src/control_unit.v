module control_unit #(

parameter NB_INSTRUCT = 32
)

(
input wire [NB_INSTRUCT-1:0]i_instruction,

output wire o_ALUSrc,
output wire o_mem_to_reg,
output wire o_reg_write,
output wire o_mem_read,
output wire o_mem_write, 
output wire o_branch,
output wire o_jump,
output wire [1:0]o_ALUOp
);

//SLL, SRL, SRA, SLL, SRL, SRA, ADD, 
//SUB, AND, OR, XOR, NOR, SLT, SLTU 
localparam R_TYPE_OP_CODE = 7'b0110011;

//SB, SH, SW
localparam S_TYPE_OP_CODE = 7'b0100011;

// LB, LH, LW, LWU, LBU, LHU, 
localparam I_TYPE_1_OP_CODE = 7'b0000011;

//ADDI, ANDI, ORI, XORI, SLTI, SLTIU
localparam I_TYPE_2_OP_CODE = 7'b0010011;

//JALR
localparam I_JALR_OP_CODE = 7'b1100111;

// LUI
localparam U_TYPE_OP_CODE = 7'b0110111;

// JAL
localparam UJ_TYPE_OP_CODE = 7'b1101111;

// BEQ,BNE
localparam SB_TYPE_OP_CODE = 7'b1100011;

reg ALUSrc;
reg mem_to_reg;
reg reg_write;
reg mem_read;
reg mem_write; 
reg branch;
reg jump;
reg [1:0] ALUOp;

always @(*) begin
    ALUSrc = 0;
    mem_to_reg = 0;
    reg_write = 0;
    mem_read = 0;
    mem_write = 0; 
    branch = 0;
    jump = 0;
    ALUOp = 0;

    case (i_instruction[6:0])
    
        R_TYPE_OP_CODE:begin
            reg_write = 1'b1;
            ALUOp[1] = 1'b1;
        end
        
        S_TYPE_OP_CODE:begin
            ALUSrc = 1'b1;
            mem_write = 1'b1;
        end
        
        I_TYPE_1_OP_CODE:begin
            ALUSrc = 1'b1;
            mem_to_reg = 1'b1;
            reg_write = 1'b1;
            mem_read = 1'b1;
        end
        
        I_TYPE_2_OP_CODE:begin
            ALUSrc =1'b1;
            reg_write = 1'b1;
            ALUOp = 2'b11;                
        end 
        
        I_JALR_OP_CODE: begin
            ALUSrc  = 1'b1;
            reg_write = 1'b1;
            jump = 1'b1;
        end
        
        U_TYPE_OP_CODE:begin
            reg_write = 1'b1;
        end
        
        UJ_TYPE_OP_CODE:begin
           reg_write =1'b1;
           jump =1'b1; 
        end
        
        SB_TYPE_OP_CODE: begin
            branch = 1'b1;
            ALUOp[0] = 1'b1;   
        end

    endcase

end

assign o_ALUSrc = ALUSrc;
assign o_mem_to_reg = mem_to_reg;
assign o_reg_write = reg_write;
assign o_mem_read = mem_read;
assign o_mem_write = mem_write; 
assign o_branch = branch;
assign o_jump = jump;
assign o_ALUOp = ALUOp;




endmodule