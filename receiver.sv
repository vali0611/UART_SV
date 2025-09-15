module receiver(
    input logic rst_n,
    input logic clk,
    input logic rxd,
    input logic tick_baud,
    input logic parity_en,
    input logic parity_type,
    input logic stop_bit,
    input logic read_en,
    output logic [7:0] data_out,
    output logic rx_ready,
    output logic rx_busy,
    output logic parity_error,
    output logic frame_error
);

parameter idle = 3'b001;
parameter start = 3'b010;
parameter data = 3'b011;
parameter parity = 3'b100;
parameter stop = 3'b101;

logic [2:0] state;
logic [2:0] next_state;
logic [7:0] shift_reg;
logic parity_bit;
logic [3:0] bit_count;
logic [1:0] stop_count;

always_ff@(posedge clk or negedge rst_n) begin
    if(!rst_n)
    state <= idle;
    else 
        state <= next_state;
    end

always_comb begin
    case(state)
    idle: begin
        if(rxd == 0)
        next_state = start;
        else 
            next_state = idle;
        end
    start: begin 
        if(tick_baud == 0)
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

always_ff@(posedge clk or negedge rst_n)begin
    if(!rst_n) begin
        rx_busy <=0;
        rx_ready <= 0;
        shift_reg <= 0;
        parity_bit <=0;
        bit_count <=0;
        stop_count <=0;
        parity_error <= 0;
        frame_error <= 0;
    end else begin 
        if(read_en)
        rx_ready <=0;
    end
        case(state)
    idle: begin
            rx_busy <=0;
            bit_count <= 0;
            stop_count <= 0;
            if(rxd == 0) begin
            parity_error <= 0;
            frame_error <= 0;
        end
    end
        start: begin
            rx_busy <= 1;
            if(tick_baud) begin
                if(rxd != 0) begin
                    rx_busy <=0;
                end
            end
        end
        data: begin
            if(tick_baud) begin
                shift_reg[bit_count] <= rxd;
                bit_count <= bit_count +1;
            end
        end
        parity: begin
            if(tick_baud) begin
                parity_bit <=rxd;
                parity_error <=(parity_bit != (parity_type ? ~(^shift_reg) : ^shift_reg));
            end
        end
        stop: begin
            if(tick_baud)begin
                if(rxd != 1)
                frame_error <= 1;
            if(stop_bit && (stop_count ==0)) begin
                stop_count <= 1;
            end else begin
                rx_busy   <= 1'b0;
                        data_out  <= shift_reg;
                        rx_ready  <= 1'b1; 
                        bit_count <= 4'd0;
                        stop_count<= 2'd0;
                    end
                end
            end
     endcase
    end

endmodule