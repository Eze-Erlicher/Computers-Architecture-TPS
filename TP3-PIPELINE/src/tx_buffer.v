module tx_buffer #(

parameter INSTRUCT_MEM_WIDTH = 32
)

(
//Inputs
input wire i_clk,
input wire i_reset,
input wire i_tx_start,
input wire i_rx_done,
input wire [INSTRUCT_MEM_WIDTH-1:0]i_pipeline_info,

//Outputs
output wire o_tx_buffer_empty,
output wire o_rx_data
);

reg [INSTRUCT_MEM_WIDTH-1:0]rx_data;
reg bit_to_send;
reg tx_buffer_empty;
reg [5:0]sent_bits_counter;

always @(posedge i_clk,posedge i_reset)begin

    if (i_reset)begin
        rx_data <= 0;
        bit_to_send <= 1'b0;
        tx_buffer_empty <= 1'b1;
        sent_bits_counter <= 0;    
    end
    
    else if(i_tx_start) begin
        tx_buffer_empty <= 1'b0;
        rx_data <= i_pipeline_info;
        bit_to_send <= i_pipeline_info[0]; 
        sent_bits_counter <= 6'b000001;              
    end
    
    else begin
        if(i_rx_done)begin
            if(sent_bits_counter == INSTRUCT_MEM_WIDTH) begin
                rx_data <= 0;
                tx_buffer_empty <= 1'b1;
                sent_bits_counter <= 6'b000000;  
            end
            
            else begin
                bit_to_send <= rx_data[sent_bits_counter]; 
                sent_bits_counter <= sent_bits_counter + 1; 
            end
        end
    end  
end

assign o_tx_buffer_empty = tx_buffer_empty;
assign o_rx_data = bit_to_send;

endmodule