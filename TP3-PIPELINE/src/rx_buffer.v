module rx_buffer #(

parameter INSTRUCT_MEM_WIDTH = 32
)

(
//Inputs
input wire i_clk,
input wire i_reset,
input wire i_rx_buffer_start,
input wire i_rx_done,
input wire [INSTRUCT_MEM_WIDTH-1:0]i_pipeline_info,

//Outputs
output wire o_rx_buffer_empty,
output wire o_rx_data
);

reg [INSTRUCT_MEM_WIDTH-1:0]rx_buffer_data;
reg bit_to_send;
reg rx_buffer_empty;
reg [5:0]sent_bits_counter;

always @(posedge i_clk,posedge i_reset)begin

    if (i_reset)begin
        rx_buffer_data <= 0;
        bit_to_send <= 1'b0;
        rx_buffer_empty <= 1'b1;
        sent_bits_counter <= 0;    
    end
    
    else if(i_rx_buffer_start) begin
        rx_buffer_empty <= 1'b0;
        rx_buffer_data <= i_pipeline_info;
        bit_to_send <= i_pipeline_info[0]; 
        sent_bits_counter <= 6'b000001;              
    end
    
    else begin
        if(i_rx_done)begin
            if(sent_bits_counter == INSTRUCT_MEM_WIDTH) begin
                rx_buffer_data <= 0;
                rx_buffer_empty <= 1'b1;
                sent_bits_counter <= 6'b000000;
                bit_to_send <= 1'b0;  
            end
            
            else begin
                bit_to_send <= rx_buffer_data[sent_bits_counter]; 
                sent_bits_counter <= sent_bits_counter + 1; 
            end
        end
    end  
end

assign o_rx_buffer_empty = rx_buffer_empty;
assign o_rx_data = bit_to_send;

endmodule