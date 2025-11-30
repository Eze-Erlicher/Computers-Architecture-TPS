module tx_mod
#(

    parameter NB_DATA = 8,
    parameter STOP_TICKS = 16

)
(

    input wire i_clk,
    input wire i_s_tick,
    input wire i_tx_start,
    input wire [NB_DATA-1:0] i_tx_data,
    input wire i_reset,
 
    output wire o_tx_done_tick,
    output wire o_tx

);

//Estados
localparam TX_IDLE_STATE= 2'b00;
localparam TX_START_STATE= 2'b01;
localparam TX_TRANSMIT_STATE=2'b10;
localparam TX_STOP_STATE=2'b11;


// Registros de estado,contador de data,contador de ticks y data
reg[1:0] tx_state,next_tx_state;
reg[2:0] data_counter,next_data_counter;
reg[3:0] ticks_counter,next_ticks_counter;
reg[NB_DATA-1:0] data,next_data;
reg tx_done;
reg tx_reg , tx_next;

// Actualización de variables
always @(posedge i_clk,posedge i_reset) begin

    if (i_reset) begin
        tx_state <= TX_IDLE_STATE;
        data_counter <= 0;
        ticks_counter <= 0;
        data <= {NB_DATA{1'b0}};
        tx_reg <= 1'b1;
    end
    
    else begin
        tx_state <= next_tx_state;
        data_counter <= next_data_counter;
        ticks_counter <= next_ticks_counter;
        data <= next_data;
        tx_reg <= tx_next;
    end
    
end

//Lógica del siguiente estado
always @(*)begin

    next_tx_state = tx_state;
    next_data_counter = data_counter;
    next_ticks_counter = ticks_counter;
    next_data = data;
    tx_next = tx_reg;
    tx_done = 1'b0;
    
    case(tx_state)
    
        TX_IDLE_STATE:begin
            
            tx_next = 1'b1;
            if(i_tx_start)begin
                next_tx_state = TX_START_STATE;
                next_ticks_counter = 4'b0;
                next_data = i_tx_data;
            end
        end
            
        TX_START_STATE:begin
            
            tx_next = 1'b0;
            if(i_s_tick)begin
            
                if(ticks_counter == 15)begin
                    next_ticks_counter = 4'b0;
                    next_data_counter = 3'b0;
                    next_tx_state = TX_TRANSMIT_STATE;
                end
                
                else begin
                    next_ticks_counter = ticks_counter +1;
                end
            
            end
            
        end
            
        TX_TRANSMIT_STATE:begin
        
            tx_next = data[0];
            
            if(i_s_tick)begin
            
                if(ticks_counter == 15)begin
                    next_ticks_counter = 4'b0;
                    next_data = data >> 1;
                    if(data_counter == (NB_DATA-1))begin
                        next_data_counter = 3'b0;
                        next_tx_state = TX_STOP_STATE;
                    end
                    
                    else begin
                        next_data_counter = data_counter + 1;
                    end
                    
                end
                
                else begin
                    next_ticks_counter = ticks_counter + 1;
                end
            
            end
            
        end
            
        TX_STOP_STATE:begin
        
            tx_next = 1'b1;
            
            if (i_s_tick)begin
            
                if(ticks_counter == (STOP_TICKS-1))begin
                    next_tx_state = TX_IDLE_STATE;
                    tx_done= 1'b1;
                end
                
                else begin
                    next_ticks_counter = ticks_counter + 1;
                end
            
            end
            
        end
        
        default: begin
            next_tx_state = TX_IDLE_STATE;
        end
        
    endcase
    
end

assign o_tx = tx_reg;
assign o_tx_done_tick = tx_done;



endmodule




