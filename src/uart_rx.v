module uart_rx #(
  parameter CLK_FREQ  = 100_000_000,
  parameter BAUD_RATE = 9600
)(
  input  wire       clk, rst,
  input  wire       rx,
  output reg  [7:0] data_out,
  output reg        data_valid
);
  localparam CLKS_PER_BIT  = CLK_FREQ / BAUD_RATE;
  localparam HALF_BIT      = CLKS_PER_BIT / 2;
  reg [15:0] clk_count;
  reg [3:0]  bit_index;
  reg [7:0]  rx_shift;
  localparam IDLE=0, START=1, DATA=2, STOP=3;
  reg [1:0] state;

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      state<=IDLE; data_valid<=0; clk_count<=0; bit_index<=0;
    end else begin
      data_valid<=0;
      case (state)
        IDLE: if (!rx) begin state<=START; clk_count<=0; end
        START: begin
          if (clk_count==HALF_BIT-1) begin
            clk_count<=0; bit_index<=0; state<=DATA;
          end else clk_count<=clk_count+1;
        end
        DATA: begin
          if (clk_count==CLKS_PER_BIT-1) begin
            clk_count<=0;
            rx_shift<={rx, rx_shift[7:1]};
            if (bit_index==7) state<=STOP;
            else bit_index<=bit_index+1;
          end else clk_count<=clk_count+1;
        end
        STOP: begin
          if (clk_count==CLKS_PER_BIT-1) begin
            data_out<=rx_shift; data_valid<=1; state<=IDLE; clk_count<=0;
          end else clk_count<=clk_count+1;
        end
      endcase
    end
  end
endmodule
