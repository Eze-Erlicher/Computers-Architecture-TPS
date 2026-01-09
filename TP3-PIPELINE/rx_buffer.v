module rx_buffer #(

parameter INSTRUCT_MEM_WIDTH = 32,
parameter RX_WIDTH = 8

)
(
//Inputs
input wire i_clk,
input wire i_reset,
input wire i_rx_done_tick,
input wire [RX_WIDTH-1:0]i_rx_data,

//Outputs
output [INSTRUCT_MEM_WIDTH-1:0]o_instruct_or_command,
output o_receive_done
);

reg [5:0]received_bits_counter;
reg [INSTRUCT_MEM_WIDTH-1:0] instruct_or_command;
reg receive_done;

always @(posedge i_clk, posedge i_reset)begin
    receive_done <= 1'b0;
    
    if(i_reset)begin
        received_bits_counter <= 0;
        instruct_or_command <= 0; 
        receive_done <= 1'b0;
    end

    if(received_bits_counter == 32)begin
        received_bits_counter <= 0;
        receive_done <= 1'b1;
    end
    else begin
        if(i_rx_done_tick)begin
            instruct_or_command[received_bits_counter +: 8] <= i_rx_data;
            received_bits_counter <= received_bits_counter + 8;
        end
    end
end

assign o_receive_done = receive_done;
assign o_instruct_or_command = instruct_or_command;

endmodule