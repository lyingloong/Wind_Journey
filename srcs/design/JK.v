module JK(
    input J,K,clk,
    output out
);
reg e;
assign out=e;
always @(posedge clk)begin
    if(J)e<=1;
    else if(K)e<=0;
end
endmodule