module DU(
    input rst,
    input clk,
    input [1:0] mode,
    input [11:0]inrgb,
    input we,
    input [14:0]addr,
    output [11:0] rgb,
    output VGA_HS,VGA_VS
);
wire hen,ven;
reg pclk;
initial begin
    pclk=0;
end
always @(posedge clk)begin
    pclk<=~pclk;
end
DST DST(
    .rstn(~rst),
    .pclk(pclk),
    .hen(hen),
    .ven(ven),
    .vs(VGA_VS),
    .hs(VGA_HS)
);
wire [11:0] rdata;
wire [14:0] raddr;
DDP #(.DW(32'd15),.H_LEN(32'd200),.V_LEN(32'd150)) ddp(
    .hen(hen),
    .ven(ven),
    .rstn(~rst),
    .pclk(pclk),
    
    .mode(mode),
    .rdata(rdata),

    .raddr(raddr),
    .rgb(rgb)
);

memvmap mem (
  .a(addr),        // input wire [14 : 0] a
  .d(inrgb),        // input wire [11 : 0] d
  .dpra(raddr),  // input wire [14 : 0] dpra
  .clk(clk),    // input wire clk
  .we(we),      // input wire we
  .dpo(rdata)    // output wire [11 : 0] dpo
);
endmodule