module baud_gen 
  #( 
        parameter  BAUD_RATE  = 19200,
        parameter  CLOCK_FREQ = 50_000_000,
        parameter  NB_COUNTER = 16
    )
    ( 
        input  wire    i_clk,
        input  wire    i_reset,
        output wire    o_tick
    ); 

    localparam integer MOD = (CLOCK_FREQ + (BAUD_RATE * 16) - 1) / (BAUD_RATE * 16);

    reg  [NB_COUNTER-1:0]  r_counter;
    wire [NB_COUNTER-1:0]  r_next;

  always @ (posedge i_clk)begin
    if (i_reset)
            r_counter <= 0; 
        else 
            r_counter <= r_next;
    end

    // Alcanzó el valor máximo del contador?
    wire last_value = (r_counter == MOD-1);
    // Siguiente valor del contador
    assign r_next = last_value ? 0 : r_counter + 1; 
    // Tick pulse
    assign o_tick = last_value ? 1'b1 : 1'b0; 

endmodule 
