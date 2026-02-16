//Pending: modify SEND DATA MEM state to only send those values != 0

module uart_pipeline_interface #(

parameter REG_BANK_WIDTH = 32,
parameter REG_BANK_ADDR_BITS = 5, // Tamaño por defecto del banco de registros = 32
parameter DATA_MEM_WIDTH = 32,
parameter DATA_MEM_ADDR_BITS = 8 ,// Tamaño por defecto de la memoria de datos = 256
parameter INSTRUCT_MEM_WIDTH = 32,
parameter INSTRUCT_MEM_ADDR_BITS = 6, // Tamaño por defecto de la memoria de instrucciones = 64
parameter IF_ID_SIZE = 40, // 6+32+2+8
parameter ID_EX_SIZE = 152, // 9+6+32+32+64+4+5
parameter EX_MEM_SIZE = 81, // 5+32+32+6+1+5
parameter MEM_WB_SIZE = 72 // 2+32+32+5+1


)
(
//Inputs
input wire i_clk,
input wire i_reset,
input wire [REG_BANK_WIDTH-1:0]i_register_value,
input wire [DATA_MEM_WIDTH-1:0]i_memory_value,
input wire [INSTRUCT_MEM_WIDTH-1:0]i_instruct_or_command,
input wire i_tx_buffer_done, 
input wire i_rx_buffer_empty,
input wire i_program_finished,
input wire [IF_ID_SIZE-1:0]i_IF_ID_content,
input wire [ID_EX_SIZE-1:0]i_ID_EX_content,
input wire [EX_MEM_SIZE-1:0]i_EX_MEM_content,
input wire [MEM_WB_SIZE-1:0]i_MEM_WB_content,

//Outputs
output wire [REG_BANK_ADDR_BITS-1:0]o_register_address,
output wire [DATA_MEM_ADDR_BITS-1:0]o_memory_address,
output wire [INSTRUCT_MEM_WIDTH-1:0]o_instruct_to_write,
output wire [INSTRUCT_MEM_ADDR_BITS-1:0]o_instruct_to_write_addr,
output wire [INSTRUCT_MEM_WIDTH-1:0]o_pipeline_info,
output wire o_rx_buffer_start,
output wire [1:0]o_pipeline_exec_mode,
output wire o_execute_instruct
);

//States (one hot encoding)
localparam WAIT_FOR_COMMAND = 9'b000000001;
localparam INTERPRET_COMMAND = 9'b000000010;
localparam RECEIVE_INSTRUCTS = 9'b000000100;
localparam PROGRAM_INSTRUCT_MEM = 9'b000001000;
localparam SEND_REGISTERS = 9'b000010000;
localparam SEND_LATCHES = 9'b000100000;
localparam SEND_DATA_MEM = 9'b001000000;
localparam RUN_CONTINUOS = 9'b010000000;
localparam RUN_STEPWISE = 9'b100000000;

//Commands
localparam [INSTRUCT_MEM_WIDTH-1:0] start_continuos = "cont";
localparam [INSTRUCT_MEM_WIDTH-1:0] start_stepwise = "step";
localparam [INSTRUCT_MEM_WIDTH-1:0] execute_an_instruct = "exin";
localparam [INSTRUCT_MEM_WIDTH-1:0] receive_instructions = "rins";
localparam [INSTRUCT_MEM_WIDTH-1:0] fetch_pipeline_data = "fpip";
localparam [INSTRUCT_MEM_WIDTH-1:0] instructs_eof = "ieof";

// Auxiliar variables
reg [INSTRUCT_MEM_WIDTH-1:0] instructions [2**INSTRUCT_MEM_ADDR_BITS-1:0];
reg [8:0]state;
reg [INSTRUCT_MEM_ADDR_BITS-1:0] inst_counter;
reg [INSTRUCT_MEM_WIDTH-1:0] instruct_to_write;
reg [REG_BANK_ADDR_BITS:0] register_address;
reg [DATA_MEM_ADDR_BITS:0] memory_address;
reg send_mem_index_or_value; // 0: index, 1:value
reg [2:0] latches_sent_counter;
reg [ID_EX_SIZE-1:0] latches_info_array [3:0];
reg [7:0] latch_bits_sent;
reg [31:0] current_latch_size;
reg [INSTRUCT_MEM_WIDTH-1:0] pipeline_info;
reg rx_buffer_start;
reg [1:0] pipeline_exec_mode;
reg execute_instruct;

always @(posedge i_clk,posedge i_reset)begin
    if (i_reset) begin
        state <= WAIT_FOR_COMMAND;
        inst_counter <= 0;
        instruct_to_write <= {INSTRUCT_MEM_WIDTH{1'b0}};
        register_address <= 0;
        memory_address <= 0;
        latches_sent_counter <= 0;
        latch_bits_sent <= 0;
        pipeline_info <= 0;
        rx_buffer_start <= 1'b0;
        pipeline_exec_mode <= 2'b0;
    end
    
    else begin
        rx_buffer_start <= 1'b0;
        
        case(state)
            WAIT_FOR_COMMAND:begin
                if(i_tx_buffer_done == 1'b1)begin
                    instructions[0] <= i_instruct_or_command;
                    state <= INTERPRET_COMMAND;
                end
                
                else begin
                    state <= WAIT_FOR_COMMAND;
                end
            end
            
            INTERPRET_COMMAND:begin
                if (instructions[0] == receive_instructions)begin
                    state <= RECEIVE_INSTRUCTS;
                    inst_counter <= {INSTRUCT_MEM_ADDR_BITS{1'b0}};
                end
                
                else if(instructions[0] == fetch_pipeline_data) begin
                    latches_info_array[0] <= i_IF_ID_content;
                    latches_info_array[1] <= i_ID_EX_content;
                    latches_info_array[2] <= i_EX_MEM_content;
                    latches_info_array[3] <= i_MEM_WB_content;
                    state <= SEND_REGISTERS;
                end
            
                else if (instructions[0] == start_continuos)begin
                    state <= RUN_CONTINUOS;
                end
                
                else if (instructions[0] == start_stepwise)begin
                    state <= RUN_STEPWISE;
                end
                
                else begin
                    state <= WAIT_FOR_COMMAND;
                end
            end
            
            RECEIVE_INSTRUCTS: begin
                if(i_tx_buffer_done)begin
                    instructions[inst_counter] <= i_instruct_or_command;
                    
                    if(i_instruct_or_command == instructs_eof)begin
                        inst_counter <= {INSTRUCT_MEM_ADDR_BITS{1'b0}};
                        state <= PROGRAM_INSTRUCT_MEM;
                    end
                    
                    else begin
                        inst_counter <= inst_counter+1;
                    end
                end  
            end
            
            PROGRAM_INSTRUCT_MEM: begin
                instruct_to_write <= instructions[inst_counter];
            
                if(instructions[inst_counter] == instructs_eof)begin
                    inst_counter <= {INSTRUCT_MEM_ADDR_BITS{1'b0}};
                    state <= WAIT_FOR_COMMAND;
                end
            
                else begin
                    inst_counter <= inst_counter + 1;
                end    
            end
             
            SEND_REGISTERS:begin
                if(register_address == (1 << REG_BANK_ADDR_BITS))begin
                    register_address <= {REG_BANK_ADDR_BITS{1'b0}};
                    state <= SEND_DATA_MEM;
                    memory_address <= {DATA_MEM_ADDR_BITS{1'b0}};
                    send_mem_index_or_value <= 1'b0;
                end
                
                else begin
                    if (i_rx_buffer_empty)begin
                        pipeline_info <= i_register_value;
                        rx_buffer_start <= 1'b1;
                        register_address <= register_address+1;
                    end
                end   
            end
            
            SEND_DATA_MEM:begin
                if (memory_address == (1 << DATA_MEM_ADDR_BITS))begin
                    state <= SEND_LATCHES;
                    memory_address <= {DATA_MEM_ADDR_BITS{1'b0}};
                    send_mem_index_or_value <= 1'b0;
                end
                
                else begin
                    if (i_rx_buffer_empty)begin
                        
                        if(i_memory_value == 0) begin
                            memory_address <= memory_address+1;
                        end
                                              
                        else if(send_mem_index_or_value == 0)begin
                            pipeline_info <= memory_address;
                            send_mem_index_or_value <= 1'b1;
                        end
                        
                        else begin
                            pipeline_info <= i_memory_value;
                            send_mem_index_or_value <= 1'b0;
                            memory_address <= memory_address+1;
                        end
                        
                        rx_buffer_start <= 1'b1;
                    end
                end
            end
            
            SEND_LATCHES:begin
                if(latches_sent_counter == 4)begin
                    state <= WAIT_FOR_COMMAND;
                    latches_sent_counter <= 0;
                    latch_bits_sent <= 0;
                end
                
                else begin
                    if (latch_bits_sent >= current_latch_size)begin
                        latches_sent_counter <= latches_sent_counter+1;
                        latch_bits_sent <= 0;
                    end
                
                    else begin
                        if(i_rx_buffer_empty)begin
                            pipeline_info <= latches_info_array[latches_sent_counter][latch_bits_sent +: 32];
                            rx_buffer_start <= 1'b1;
                            latch_bits_sent <= latch_bits_sent + 32;
                        end  
                    end 
                end
            end
           
            RUN_CONTINUOS:begin
                pipeline_exec_mode <= 2'b01;
               
                if (i_program_finished)begin
                    pipeline_exec_mode <= 2'b00;
                    pipeline_info <= 32'hffffffff;
                    rx_buffer_start <= 1'b1;
                    state <= WAIT_FOR_COMMAND;
                end
            end
            
            RUN_STEPWISE:begin
                pipeline_exec_mode <= 2'b11;
                execute_instruct <= 1'b0;
                
                if(i_tx_buffer_done == 1'b1 && i_instruct_or_command == execute_an_instruct )begin
                     execute_instruct <= 1'b1;                     
                end
                       
                if (i_program_finished)begin
                    pipeline_exec_mode <= 2'b00;
                    pipeline_info <= 32'hffffffff;
                    rx_buffer_start <= 1'b1;
                    execute_instruct <= 1'b0; 
                    state <= WAIT_FOR_COMMAND;
                end
            end
            
            default: state <= WAIT_FOR_COMMAND;
        endcase 
    end
end


always @(*)begin
    case(latches_sent_counter)
            0: current_latch_size = IF_ID_SIZE;
            1: current_latch_size = ID_EX_SIZE;
            2: current_latch_size = EX_MEM_SIZE;
            3: current_latch_size = MEM_WB_SIZE;
            default: current_latch_size = 32'b0;
    endcase
end

assign o_instruct_to_write = instruct_to_write; 
assign o_instruct_to_write_addr = inst_counter;
assign o_register_address = register_address[REG_BANK_ADDR_BITS-1:0];
assign o_memory_address = memory_address[DATA_MEM_ADDR_BITS-1:0];
assign o_pipeline_info = pipeline_info;
assign o_rx_buffer_start = rx_buffer_start;
assign o_pipeline_exec_mode = pipeline_exec_mode;
assign o_execute_instruct = execute_instruct;

endmodule

