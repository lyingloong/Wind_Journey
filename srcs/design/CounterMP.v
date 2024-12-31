module CounterMP #(
    parameter   MAX_VALUE=32'd100,
    parameter   PUT_VALUE=32'd100
)(
    input                   clk,
    input                   rst,
    output                  out
);

reg [31:0] counter;
initial begin
    counter=0;
end
always @(posedge clk) begin
    if (rst)
        counter <= 0;
    else begin
        if (counter >= MAX_VALUE-1)
            counter <= 0;
        else
            counter <= counter + 32'b1;
    end
end

assign out = (counter >= PUT_VALUE);
endmodule