module Getsin(
    input clk,
    input [15:0] now,
    output signed [15:0] dx,dy
);
reg [15:0] set;
wire [31:0] data;
memsin memsin (
  .a(set[8:0]),      // input wire [8 : 0] a
  .spo(data)  // output wire [31 : 0] spo
);
reg [31:0] put;
assign dx=put[31:16];
assign dy=put[15:0];
always @(posedge clk)begin
    if(set!=now)begin
        set<=now;
    end else put<=data;
end
endmodule