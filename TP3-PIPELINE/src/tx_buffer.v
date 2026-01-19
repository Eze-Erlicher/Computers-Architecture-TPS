module tx_buffer #(
parameter INSTRUCT_MEM_WIDTH = 32
)
(
//Inputs
input wire i_clk,
input wire i_reset,
input wire i_tx_done,
input wire i_tx_data,

//Outputs
output [INSTRUCT_MEM_WIDTH-1:0]o_instruct_or_command,
output o_tx_buffer_done
);

reg [5:0]received_bits_counter;
reg [INSTRUCT_MEM_WIDTH-1:0] instruct_or_command;
reg tx_buffer_done;

always @(posedge i_clk, posedge i_reset)begin
    
    if(i_reset)begin
        received_bits_counter <= 0;
        instruct_or_command <= 0; 
        tx_buffer_done <= 1'b0;
    end

    else begin
        tx_buffer_done <= 1'b0;
              
        if(i_tx_done)begin
            if(received_bits_counter == INSTRUCT_MEM_WIDTH-1)begin
                instruct_or_command[received_bits_counter] <= i_tx_data;
                received_bits_counter <= 0;
                tx_buffer_done <= 1'b1;
            end
            
            else begin
                instruct_or_command[received_bits_counter] <= i_tx_data;
                received_bits_counter <= received_bits_counter + 1;
            end
        end
    end
end

assign o_tx_buffer_done = tx_buffer_done;
assign o_instruct_or_command = instruct_or_command;

endmodule