module Adder8421(
    input clk,start,rst,
    input [31:0] a,b,
    output [31:0] c,
    output ready
);
reg [3:0] state;
reg [31:0] deal;
reg [31:0] modi;
assign c=deal;
localparam IDLE=9;
localparam OK=8;
initial begin
    state=IDLE;
end
assign ready=(state==OK);
wire [4:0] pos=(state&3'd7)<<2;
always @(posedge clk)begin
    if(rst)begin
        state<=IDLE;
    end else if(state==IDLE)begin
        if(start)begin
            state<=0;
            modi<=6;
            deal<=a;
        end
    end else if(state==OK)begin
        state<=IDLE;
    end else begin
        if(b[pos+:4]+deal[pos+:4]>=4'd10)begin
            deal<=deal+(b[pos+:4]<<pos)+modi;
        end else begin
            deal<=deal+(b[pos+:4]<<pos);
        end
        modi<=modi<<4;
        state<=state+1;
    end
end
endmodule