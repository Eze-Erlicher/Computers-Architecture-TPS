module rx_mod 
#(

    parameter NB_DATA=8,
    parameter STOP_TICKS = 16
)
(
    input wire i_clk,
    input wire i_s_tick,
    input wire i_rx,
    input wire i_reset,
    
    output wire [NB_DATA-1:0] o_rx_data,
    output wire o_rx_done_tick
);


// Estados
localparam RX_IDLE_STATE= 2'b00;
localparam RX_START_STATE= 2'b01;
localparam RX_DATA_STATE=2'b10;
localparam RX_STOP_STATE=2'b11;



// Registros de estado,contador de data,contador de ticks y data
reg[1:0] rx_state,next_rx_state;
reg[2:0] data_counter,next_data_counter;
reg[3:0] ticks_counter,next_ticks_counter;
reg[NB_DATA-1:0] data,next_data;
reg rx_done;

// Actualización de variables
always @(posedge i_clk,posedge i_reset) begin

    if (i_reset) begin
        rx_state <= RX_IDLE_STATE;
        data_counter <= 0;
        ticks_counter <= 0;
        data <= {NB_DATA{1'b0}};
    end
    
    else begin
        rx_state <= next_rx_state;
        data_counter <= next_data_counter;
        ticks_counter <= next_ticks_counter;
        data <= next_data;
    end
    
end


//Lógica del siguiente estado
always @(*)begin
    
    next_rx_state = rx_state;
    next_data_counter = data_counter;
    next_ticks_counter = ticks_counter;
    next_data = data;
    rx_done = 1'b0;
    
    case(rx_state)
    
        RX_IDLE_STATE:begin
          
            if(~i_rx) begin
                next_rx_state = RX_START_STATE;
                next_ticks_counter = 4'b0;
            end
            
        end
            
        RX_START_STATE:begin
        
            if(i_s_tick) begin
                
                if(ticks_counter == 7)begin
                    next_rx_state = RX_DATA_STATE;
                    next_ticks_counter = 4'b0;
                    next_data_counter = 3'b0;
                    next_data={NB_DATA{1'b0}};
                    
                end
            
                else begin
                    next_ticks_counter = ticks_counter+1;
                end
           end
           
        end
        
            
        
        RX_DATA_STATE:begin
        
            if(i_s_tick) begin
                
                if(ticks_counter == 15)begin
                
                    next_ticks_counter=4'b0;
                    next_data={i_rx,data[NB_DATA-1:1]};
                    
                    if(data_counter == NB_DATA-1) begin
                        next_rx_state = RX_STOP_STATE;
                        next_data_counter = 3'b0;
                    end
                    
                    else begin
                        next_data_counter = data_counter + 1;
                    end
                    
                end
                
                else begin
                     next_ticks_counter = ticks_counter+1;
                end          
            
            end
        
        end
        
        
        RX_STOP_STATE:begin
        
            if(i_s_tick) begin
            
                if (ticks_counter == (STOP_TICKS-1))begin
                    next_ticks_counter = 4'b0;        
                    next_rx_state = RX_IDLE_STATE;
                    rx_done = 1'b1;
                end
              
                else begin
                    next_ticks_counter = ticks_counter + 1;       
                end
                            
            end
           
        end
       

        default:begin
            next_rx_state=RX_IDLE_STATE;
        end

    endcase

end

assign o_rx_data = data;
assign o_rx_done_tick = rx_done;

endmodule

