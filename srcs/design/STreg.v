
module STreg(
    input clk,
    input rst,
    input we,
    input [15:0]data,
    output [15:0]out
);
reg [15:0] re;
reg modi;
always @(posedge clk)begin
    if(we)begin
        if(rst)re<=0;
        if(modi)begin
            re<=data;
            modi<=0;
        end
    end else begin
        if(rst)re<=0;
        modi<=1;
    end
end
assign out=re;
endmodule
