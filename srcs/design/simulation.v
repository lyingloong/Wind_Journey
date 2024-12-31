`timescale 10ps / 1ps
module MUL_ttb ();
reg [7:0] sw;
wire [7:0] led;
reg clk;
wire [7:0] an;
wire [7:0] d;
reg btn;
initial begin
    clk = 0;btn=0;
    sw=8'd0;
    forever begin
        #1 clk = ~clk;
    end
end
initial begin
    #10
    btn=1;
    #4;
    btn=0;
    #10
    btn=1;
    #4;
    btn=0;
end
wire dd,ddd;
wire [11:0] rgb;
Main main(
    .clk(clk),
    .led(led),
    .ledsel(an),
    .leddata(d),
    .rgb(rgb),
    .VGA_HS(dd),
    .VGA_VS(ddd),
    .sw(sw),
    .rst(rst),
    .btn(btn)
);
endmodule