module Getdot(
  input clk,
  input [7:0] x,
  input [3:0] y,
  input [31:0] score,
  output valid
);
wire [11:0] data;
reg mid;
assign valid=(y==0||y==4'd11)?0:mid;
wire val=|data;
wire [9:0] addr;
memscore scorer (
  .a(addr),     
  .spo(data)  
);
wire [7:0] k=x-(x>>3);
reg [3:0] go;
assign addr=y*9-9+go*90+x-k[5:3]*9;
always @(posedge clk)begin
    case(k[5:3])
        3'd0:go<=score[19:16];
        3'd1:go<=score[15:12];
        3'd2:go<=score[11:8];
        3'd3:go<=score[7:4];
        3'd4:go<=score[3:0];
        default;
    endcase
    mid<=val;
end
endmodule