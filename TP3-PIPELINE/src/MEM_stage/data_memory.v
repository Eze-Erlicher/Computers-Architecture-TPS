module data_memory #(
    parameter ADDR_WIDTH = 9,  // Address width (word-aligned)
    parameter DATA_WIDTH = 32  // Data width
)
(
    input  wire                  i_clk,
    input  wire                  i_reset,  // Note: Reset not used; memory initializes to X in simulation
    input  wire                  i_mem_write,
    input  wire                  i_mem_read,
    input  wire [1:0]            i_mem_size,    // 00: byte, 01: halfword, 10: word
    input  wire                  i_unsigned_op, // zero-extend for loads when set
    input  wire [1:0]            i_byte_offset, // selects byte/half inside the word; for halfword, i_byte_offset[0] must be 0 (aligned)
    input  wire [ADDR_WIDTH-1:0] i_address,
    input  wire [DATA_WIDTH-1:0] i_write_data,
    output wire [DATA_WIDTH-1:0] o_read_data
);

parameter DEPTH = 2**ADDR_WIDTH;

localparam MEM_BYTE = 2'b00;
localparam MEM_HALF = 2'b01;
localparam MEM_WORD = 2'b10;

// Memory declaration
reg [DATA_WIDTH-1:0] ram_mem [DEPTH-1:0];

// Registered read data (synchronous read)
reg  [DATA_WIDTH-1:0] out_data;

// Combinational signals for data extraction
wire [DATA_WIDTH-1:0] current_word;
wire [15:0]           half_word;
wire [7:0]            byte_word;

// Combinational logic for reading and data selection/extension
assign current_word = ram_mem[i_address];

assign byte_word = (i_byte_offset == 2'b00) ? current_word[7:0] :
                   (i_byte_offset == 2'b01) ? current_word[15:8] :
                   (i_byte_offset == 2'b10) ? current_word[23:16] :
                   current_word[31:24];

assign half_word = i_byte_offset[1] ? current_word[31:16] : current_word[15:0];

// Clocked block for state updates (writes only)
always @(posedge i_clk) begin
    if (i_reset) begin
        out_data <= {DATA_WIDTH{1'b0}};
    end else begin
        // Synchronous write
        if (i_mem_write) begin
            case (i_mem_size)
                MEM_WORD: ram_mem[i_address] <= i_write_data;  // Word write
                MEM_HALF: begin  // Halfword write; assumes i_byte_offset[0] == 0
                    if (i_byte_offset[1]) begin
                        ram_mem[i_address] <= {i_write_data[15:0], current_word[15:0]};
                    end else begin
                        ram_mem[i_address] <= {current_word[31:16], i_write_data[15:0]};
                    end
                end
                MEM_BYTE: begin  // Byte write
                    case (i_byte_offset)
                        2'b00: ram_mem[i_address] <= {current_word[31:8],  i_write_data[7:0]};
                        2'b01: ram_mem[i_address] <= {current_word[31:16], i_write_data[7:0], current_word[7:0]};
                        2'b10: ram_mem[i_address] <= {current_word[31:24], i_write_data[7:0], current_word[15:0]};
                        default: ram_mem[i_address] <= {i_write_data[7:0],  current_word[23:0]};
                    endcase
                end
                default: ;  // No operation for invalid size
            endcase
        end

        // Synchronous read
        if (i_mem_read) begin
            if (i_mem_size == MEM_WORD) begin
                out_data <= current_word;
            end else if (i_mem_size == MEM_HALF) begin
                out_data <= i_unsigned_op ? {16'b0, half_word}
                                          : {{16{half_word[15]}}, half_word};
            end else begin // MEM_BYTE or default
                out_data <= i_unsigned_op ? {24'b0, byte_word}
                                          : {{24{byte_word[7]}}, byte_word};
            end
        end
    end
end

assign o_read_data = out_data;

endmodule