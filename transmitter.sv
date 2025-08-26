module transmitter(
    input logic clk,
    input logic rst_n,
    input logic tick_baud,
    input logic[7:0] data_in,
    input logic write_en,
    input logic parity_en,
    input logic parity_type,
    input logic stop_bit,
    output logic txd,
    output logic tx_empty,
    output logic tx_busy
);
parameter idle = 3'b001;
parameter start = 3'b010;
parameter data = 3'b011;
parameter parity = 3'b100;
parameter stop = 3'b101;
logic [2:0] state;
logic [2:0]next_state;
logic [7:0] shift_reg;
logic [3:0] bit_count;
logic parity_bit;
logic [1:0]stop_count;

always_ff@(posedge clk or negedge rst_n) begin
    if(!rst_n)
    state<= idle;
    else 
        state<= next_state;
    end 

    always_comb begin
        case(state)
        idle: begin
            if(write_en == 1'b1)
                next_state = start;
            else
                next_state = idle;
            end
        start: begin 
            if(tick_baud == 1'b0)
                next_state = start;
            else
                next_state = data;
            end
        data: begin
            if(tick_baud == 1'b1 && bit_count != 3'b111)
                next_state = data;
        else if(tick_baud == 1'b1 && bit_count==3'b111 && parity_en == 1'b0)
                next_state = stop;
            else if(tick_baud == 1'b1 && bit_count == 3'b111 && parity_en == 1'b1)
                next_state = parity;
            else if(tick_baud == 1'b0)
                next_state = data;
            end
        parity: begin
            if(tick_baud == 0)
                next_state = parity;
            else
                next_state = stop;
            end
        stop: begin
            if(tick_baud == 1)
                if(stop_count == 0 && stop_bit == 1'b1)
                    next_state = stop;
                else
                    next_state = idle;
            end
        endcase
        end

    always_ff@(posedge clk or negedge rst_n) begin 
        if(!rst_n) begin
        txd<=1;
        tx_busy <= 1'b0;
        tx_empty <= 1'b1;
        shift_reg <= 8'b0;
        bit_count <= 3'b0;
        parity_bit <= 1'b0;
    end
    else begin
        case(state)
        idle: begin
            stop_count <= 0;
            txd <=1;
            tx_busy <= 0;
            tx_empty <= 1;
            if(write_en == 1) begin
                tx_empty <= 0;
                tx_busy <= 1;
                shift_reg <= data_in;
                parity_bit <= parity_type ? ~(^data_in) : ^data_in;
                bit_count <= 0;
            end
        end
        start: begin
            txd <= 0;
        end
        data: begin
            txd<= shift_reg[0];
            shift_reg <= {1'b0, shift_reg[7:1]};
            bit_count <= bit_count + 1;
        end
        parity: begin
            txd<= parity_bit;
        end
        stop: begin 
            stop_count <= stop_count + 1;
            txd <= 1;
            tx_busy <= 0;
            tx_empty <= 1;
            if(stop_count == 0 && stop_bit == 1'b0 || stop_count == 1) begin
                tx_busy <= 0;
                tx_empty <= 1;
                bit_count <= 0;
        end
    end
        endcase

    end
    end
endmodule 