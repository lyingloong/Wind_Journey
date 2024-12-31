module dealtap(
    input clk,
    input tap,
    output tapped
);
assign tapped=tap;
// reg out;
// reg stop;
// reg dealing;
// reg [1:0] po;
// assign tapped=out;
// wire [31:0] put;
// Counter #(.WIDTH(32'h10000),.MAX(32'd10)) cnter5(
//     .clk(clk),
//     .rst(stop),
//     .out(put)
// );
// always @(posedge clk) begin
//     if(tap)begin
//         if(dealing==0)out<=1;else out<=0;
//         dealing<=1;
//         stop<=1;
//         po<=0;
//     end else begin
//         out<=0;
//         stop<=0;
//         if(po==2'd3&&put==32'd8)begin
//             dealing<=0;
//         end else po<=po+2'd1;
//     end
// end
endmodule

