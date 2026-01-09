module tx_buffer #(

parameter INSTRUCT_MEM_WIDTH = 32,
parameter TX_WIDTH = 8
)

(
//Inputs
input wire i_clk,
input wire i_reset,
input wire i_tx_start,
input wire i_tx_done,
input wire [INSTRUCT_MEM_WIDTH-1:0]i_pipeline_info,

//Outputs
output wire o_tx_buffer_empty,
output wire [INSTRUCT_MEM_WIDTH-1:0]o_tx_data,
output wire [TX_WIDTH-1:0] o_tx_data_byte
);

reg [INSTRUCT_MEM_WIDTH-1:0]tx_data;
reg [TX_WIDTH-1:0] tx_data_byte;
reg tx_buffer_empty;
reg [5:0]sent_bits_counter;


always @(posedge i_clk,posedge i_reset)begin

    if (i_reset)begin 
        tx_data_byte <=0;
        tx_data_byte <= 0;
        tx_buffer_empty <= 1'b1;
        sent_bits_counter <= 0;    
    end
    
    else if(i_tx_start) begin
        tx_buffer_empty <= 1'b0;
        tx_data <= i_pipeline_info;
        sent_bits_counter <= 6'b0;               
    end

    else if(sent_bits_counter == 32) begin
          tx_data <= 0;
          tx_buffer_empty <= 1'b1;
    end
    
    else begin
        if(i_tx_done)begin
            tx_data_byte <= tx_data[sent_bits_counter +: 8]; 
            sent_bits_counter <= sent_bits_counter + 8; 
        end    
    end
    
end

assign o_tx_buffer_empty = tx_buffer_empty;
assign o_tx_data = tx_data;
assign o_tx_data_byte = tx_data_byte;

endmodule