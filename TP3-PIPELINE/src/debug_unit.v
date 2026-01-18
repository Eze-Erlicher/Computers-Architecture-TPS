module debug_unit #(

parameter REG_BANK_WIDTH = 32,
parameter REG_BANK_ADDR_BITS = 5,// Tamaño por defecto del banco de registros = 32
parameter DATA_MEM_WIDTH = 32,
parameter DATA_MEM_ADDR_BITS = 8 ,// Tamaño por defecto de la memoria de datos = 256
parameter INSTRUCT_MEM_WIDTH = 32,
parameter INSTRUCT_MEM_ADDR_BITS = 6, // Tamaño por defecto de la memoria de instrucciones = 64
parameter IF_ID_SIZE = 42, // 8+32+2 
parameter ID_EX_SIZE = 148, // 3+8+32+32+64+4+5
parameter EX_MEM_SIZE = 80, // 3+8+32+32+5
parameter MEM_WB_SIZE = 46 // 1+32+8+5
)
(
//Inputs
input wire I_clk,
input wire I_reset,
input wire I_tx_data,
input wire I_tx_done,
input wire I_rx_done,
input wire [REG_BANK_WIDTH-1:0]I_register_value,
input wire [DATA_MEM_WIDTH-1:0]I_memory_value,
input wire [IF_ID_SIZE-1:0]I_IF_ID_content,
input wire [ID_EX_SIZE-1:0]I_ID_EX_content,
input wire [EX_MEM_SIZE-1:0]I_EX_MEM_content,
input wire [MEM_WB_SIZE-1:0]I_MEM_WB_content,
input wire I_program_finished,

//outputs
output wire O_rx_data,
output wire [REG_BANK_ADDR_BITS-1:0]O_register_address,
output wire [DATA_MEM_ADDR_BITS-1:0]O_memory_address,
output wire [INSTRUCT_MEM_WIDTH-1:0]O_instruct_to_write,
output wire [INSTRUCT_MEM_ADDR_BITS-1:0] O_instruct_to_write_addr,
output wire O_start_pipeline
);


// TX buffer
wire [INSTRUCT_MEM_WIDTH-1:0]instruct_or_command;
wire tx_buffer_done;

//RX buffer
wire rx_buffer_start;
wire pipeline_info;
wire rx_buffer_empty;

//uart_pipeline_interface


uart_pipeline_interface # (
    .REG_BANK_WIDTH (REG_BANK_WIDTH),
    .REG_BANK_ADDR_BITS (REG_BANK_ADDR_BITS),
    .DATA_MEM_WIDTH (DATA_MEM_WIDTH),
    .DATA_MEM_ADDR_BITS (DATA_MEM_ADDR_BITS),
    .INSTRUCT_MEM_WIDTH (INSTRUCT_MEM_WIDTH),
    .INSTRUCT_MEM_ADDR_BITS(INSTRUCT_MEM_ADDR_BITS),
    .IF_ID_SIZE(IF_ID_SIZE), 
    .ID_EX_SIZE (ID_EX_SIZE), 
    .EX_MEM_SIZE (EX_MEM_SIZE),
    .MEM_WB_SIZE (MEM_WB_SIZE)
)uart_pipeline_interface_block(
    //inputs
    .i_clk(I_clk), 
    .i_reset(I_reset),
    .i_register_value(I_register_value),
    .i_memory_value(I_memory_value),
    .i_instruct_or_command(instruct_or_command),
    .i_tx_buffer_done(tx_buffer_done), 
    .i_rx_buffer_empty(rx_buffer_empty),
    .i_program_finished(I_program_finished),
    .i_IF_ID_content(I_IF_ID_content),
    .i_ID_EX_content(I_ID_EX_content),
    .i_EX_MEM_content(I_EX_MEM_content),
    .i_MEM_WB_content(I_MEM_WB_content),
    
    //Outputs
    .o_register_address(O_register_address),
    .o_memory_address(O_memory_address),
    .o_instruct_to_write(O_instruct_to_write),
    .o_instruct_to_write_addr(O_instruct_to_write_addr),
    .o_pipeline_info(pipeline_info),
    .o_rx_buffer_start(rx_buffer_start),
    .o_start_pipeline(O_start_pipeline)
);

tx_buffer #(
    .INSTRUCT_MEM_WIDTH(INSTRUCT_MEM_WIDTH)
)tx_buffer_block(
    
    //Inputs
    .i_clk(I_clk),
    .i_reset(I_reset),
    .i_tx_done(I_tx_done),
    .i_tx_data(I_tx_data),
 
    //Outputs
    .o_instruct_or_command(instruct_or_command),
    .o_tx_buffer_done(tx_buffer_done)
);

rx_buffer #(
    .INSTRUCT_MEM_WIDTH(INSTRUCT_MEM_WIDTH)
)rx_buffer_block(

    //inputs
    .i_clk (I_clk),
    .i_reset(I_reset),
    .i_rx_buffer_start(rx_buffer_start),
    .i_rx_done(I_rx_done),
    .i_pipeline_info(pipeline_info),
    
    //outputs
    .o_rx_buffer_empty(rx_buffer_empty),
    .o_rx_data(O_rx_data)
);


// I've implemented the verilog module of  the debug unit that is shown on that image. 
// I'm gonna provide the code so that you can tell me which errors can you find 
endmodule