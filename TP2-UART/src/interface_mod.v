module interface
#(

    parameter NB_DATA    = 8,
    parameter NB_ALU_OP  = 6,
    parameter NB_INTF_OP = 8
)
(
    input wire                  i_clk,
    input wire                  i_reset,
    input wire  [NB_DATA-1:0]   i_rx_data,
    input wire                  i_rx_done,

    input wire  [NB_DATA-1:0]   i_alu_res,

    output wire                 o_tx_start,
    output wire [NB_DATA-1:0]   o_tx_data,

    output wire [NB_ALU_OP-1:0] o_alu_OP,
    output wire [NB_DATA-1:0]   o_alu_A,
    output wire [NB_DATA-1:0]   o_alu_B
);

// 3 possible states:
// 00 - Idle
// 01 - Send
// 10 - Receive

localparam INTF_IDLE_STATE    = 2'b00;
localparam INTF_SEND_STATE    = 2'b01;
localparam INTF_RECEIVE_STATE = 2'b10;

// Receive operation codes for interface
// 1) Set A
// 2) Set B
// 3) Set ALU OP
// 4) Get ALU result

// Operations 1-3 change state from IDLE to SEND
// Operation 4 change state from IDLE to RECEIVE

localparam ALU_OP_GET_RES = 8'b00000000;
localparam ALU_OP_SET_A   = 8'b00000001;
localparam ALU_OP_SET_B   = 8'b00000010;
localparam ALU_OP_SET_OP  = 8'b00000011;

reg [1:0]           intf_state,  next_intf_state;
reg [NB_DATA-1:0]   intf_opcode, next_intf_opcode;

reg [NB_DATA-1:0]   alu_data_A,  next_alu_data_A,
                    alu_data_B,  next_alu_data_B;
reg [NB_ALU_OP-1:0] alu_opcode,  next_alu_opcode;

reg                 tx_start,    next_tx_start;
reg [NB_DATA-1:0]   tx_data,     next_tx_data;



always @(posedge i_clk) begin

    if(i_reset) begin
        intf_state   <= INTF_IDLE_STATE;
        intf_opcode  <= 8'b0;

        alu_data_A   <= {NB_DATA{1'b0}};
        alu_data_B   <= {NB_DATA{1'b0}};
        alu_opcode   <= {NB_ALU_OP{1'b0}};

        tx_start     <= 1'b0;
        tx_data      <= {NB_DATA{1'b0}};
    end

    else begin

        intf_state   <= next_intf_state;
        intf_opcode  <= next_intf_opcode;

        alu_data_A   <= next_alu_data_A;
        alu_data_B   <= next_alu_data_B;
        alu_opcode   <= next_alu_opcode;

        tx_start     <= next_tx_start;
        tx_data      <= next_tx_data;
    end

end

always @(*) begin
    
    next_intf_state  = intf_state;
    next_intf_opcode = intf_opcode;
    next_alu_data_A  = alu_data_A;
    next_alu_data_B  = alu_data_B;
    next_alu_opcode  = alu_opcode;
    next_tx_data     = tx_data;
    next_tx_start    = 1'b0;

    case(intf_state)

        INTF_IDLE_STATE: begin
            
            if(i_rx_done) begin
                next_intf_opcode = i_rx_data;
                
                case(i_rx_data)
                    ALU_OP_SET_A: begin
                        next_intf_state = INTF_RECEIVE_STATE;
                    end

                    ALU_OP_SET_B: begin
                        next_intf_state = INTF_RECEIVE_STATE;
                    end

                    ALU_OP_SET_OP: begin
                        next_intf_state = INTF_RECEIVE_STATE;
                    end

                    ALU_OP_GET_RES: begin
                        next_intf_state = INTF_SEND_STATE;
                    end

                    default: begin
                        next_intf_state = INTF_IDLE_STATE;
                    end
                endcase
            end
        end

        INTF_SEND_STATE: begin
            
            next_tx_data = i_alu_res;
            next_tx_start = 1'b1;
            next_intf_state = INTF_IDLE_STATE;

        end

        INTF_RECEIVE_STATE: begin

            if(i_rx_done) begin

                case(intf_opcode)

                    ALU_OP_SET_A: begin
                        next_alu_data_A = i_rx_data;
                    end

                    ALU_OP_SET_B: begin
                        next_alu_data_B = i_rx_data;
                    end

                    ALU_OP_SET_OP: begin
                        next_alu_opcode = i_rx_data[NB_ALU_OP-1:0];
                    end

                    default: begin
                        // Do nothing
                    end

                endcase

                next_intf_state = INTF_IDLE_STATE;
            end

        end
    endcase
end

assign o_tx_start  = tx_start;
assign o_tx_data   = tx_data;

assign o_alu_OP    = alu_opcode;
assign o_alu_A     = alu_data_A;
assign o_alu_B     = alu_data_B;

endmodule
