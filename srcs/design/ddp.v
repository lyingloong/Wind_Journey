//实现DDP功能，将画布与显示屏适配，从而产生色彩信息。
//DDP和DST共同称为DU即显示单元
module DDP#(
    parameter DW = 15,
    parameter H_LEN = 200,
    parameter V_LEN = 150
)(
input               hen,
input  [1:0]        mode,
input               ven,
input               rstn,
input               pclk,
input  [11:0]       rdata,
output reg [11:0]   rgb,
output reg [DW-1:0] raddr
);

reg [1:0] sx;       //放大四倍
reg [1:0] sy;
reg [1:0] nsx;
reg [1:0] nsy;


always @(*) begin
    sx=nsx;
    sy=nsy;
end
initial begin
    raddr=0;
    sx=0;sy=0;nsx=0;nsy=0;
end
wire p;
reg deal;
reg [11:0] last;
wire [4:0] red,green,blue;
assign red=(rdata[11:8]+last[11:8]);
assign green=(rdata[7:4]+last[7:4]);
assign blue=(rdata[3:0]+last[3:0]);
wire [11:0] mix={red[4:1],green[4:1],blue[4:1]};
wire [3:0] red2,green2,blue2;
assign red2=(rdata[11:8]+last[11:8])>>>1;
assign green2=(rdata[7:4]+last[7:4])>>>1;
assign blue2=(rdata[3:0]+last[3:0])>>>1;
wire [11:0] mix2={red[1:0],green[4:0],blue[4:0]};
wire [11:0] mix3={red2,green2,blue2};

always @(posedge pclk) begin           //可能慢一个周期，改hen,ven即可
    if(!rstn) begin
        nsx<=0; nsy<=3;
        rgb<=0;
        raddr<=0;
    end
    else if(hen&&ven) begin
        case(mode)
            0:rgb<=rdata;    
            1:begin rgb<=mix;last<=mix;end
            2:begin rgb<=mix2;last<=mix2;end
            3:begin rgb<=mix3;last<=mix3;end
        endcase
        deal<=1;
        if(sx==2'b11) begin
            raddr<=raddr+1;
        end
        nsx<=sx+1;
    end                                      //无效区域
    else if(deal) begin                        //ven下降沿
        rgb<=0;
        deal<=0;
        last<=0;
        if(sy!=2'b11) begin
            raddr<=raddr-H_LEN;
        end
        else if(raddr==H_LEN*V_LEN) begin
            raddr<=0;
        end
        nsy<=sy+1;
    end
    else rgb<=0;
end
endmodule