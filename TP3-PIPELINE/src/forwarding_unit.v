module forwarding_unit(
input wire i_reset,
input wire i_EX_MEM_WB,
input wire i_MEM_WB_WB,
input wire [4:0]i_ID_EX_rs1,
input wire [4:0]i_ID_EX_rs2,
input wire [4:0] i_EX_MEM_rd,
input wire [4:0] i_MEM_WB_rd,

output wire [1:0]o_forward_A,
output wire [1:0]o_forward_B

);

reg [1:0]forward_A;
reg [1:0]forward_B;

always @(*)begin
    forward_A = 2'b00;
    forward_B = 2'b00;
    
    if(i_reset)begin
        forward_A = 0;
        forward_B = 0;
    end
    
    //EX hazard
    if( (i_EX_MEM_WB) && (i_EX_MEM_rd!=0) )begin
        
        if(i_EX_MEM_rd == i_ID_EX_rs1)begin
            forward_A =2'b10;   
        end
        
        if (i_EX_MEM_rd == i_ID_EX_rs2)begin
            forward_B =2'b10;
        end
    end
    
    // MEM hazard
    else if( (i_MEM_WB_WB) && (i_MEM_WB_rd!=0) ) begin
        
        if(~(i_EX_MEM_WB && (i_EX_MEM_rd!=0) && (i_EX_MEM_rd == i_ID_EX_rs1)) && i_MEM_WB_rd == i_ID_EX_rs1)begin
            forward_A = 2'b01;
        end
        
        if(~(i_EX_MEM_WB && (i_EX_MEM_rd!=0) && (i_EX_MEM_rd == i_ID_EX_rs2)) && i_MEM_WB_rd == i_ID_EX_rs2)begin
            forward_B = 2'b01;
        end
    end

end

assign o_forward_A = forward_A;
assign o_forward_B = forward_B;

endmodule