module PS#(
        parameter  WIDTH = 1
)
(
        input             s,
        input             clk,
        output            p
);
reg put;
assign p=put;

reg last;
initial begin
    put=0;last=0;
end
always @(posedge clk)begin
    if(last!=s)begin
        last<=s;
        put<=last;
    end else put<=0;
end
//TODO

endmodule