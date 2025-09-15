module baud_rate#(
    parameter WIDTH =16
  )
  (
    input logic clk,
    input logic rst_n,
    input logic[WIDTH-1:0] divizor,
    output logic tick_baud
  );
  logic [WIDTH-1:0] counter;
  always_ff@(posedge clk or negedge rst_n)
  begin
    if(!rst_n)
    begin
      counter <= '0;
      tick_baud <= 1'b0;
    end
    else
    if(counter == divizor-1)
    begin
      counter <= '0;
      tick_baud <=1'b1;
    end
    else
    begin
      counter <= counter+1;
      tick_baud <= 1'b0;
    end
  end
endmodule
