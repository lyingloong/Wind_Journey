module Main(
    input clk,
    input [15:0] sw,
    input nrst,
    input btn2,
    input PS2_CLK,
    input PS2_DATA,
    output [15:0] led,
    output [11:0] rgb,
    output pwm,sd,
    output VGA_HS,VGA_VS,
    output [7:0] ledsel,
    output [7:0] leddata
);
wire rst=~nrst;
reg [3:0] state;
reg fakeclick;
wire wfakeclick;
always @(posedge clk)fakeclick<=wfakeclick;
localparam START=0;
localparam WAIT=1;
localparam RUN =2;
localparam STOP=3;
wire [15:0] nowpos;
reg [15:0] nownote;
reg [31:0] cnttt;
reg [31:0]cnttap;
initial begin
    cnttap=0;
end
wire wauto,wstrong;
wire [1:0] wspeed;
/*
占位的标题
1调节自动进行 2调节无敌
4加速  5减速 6恢复原速度
按其他任意键开始/判定
*/
wire [31:0] debuger;
wire wchange;
getclicked gettap(
    .clk(clk),
    .PS2_CLK(PS2_CLK),
    .PS2_DATA(PS2_DATA),
    .btn(btn2),
    .auto(auto&&state==RUN),
    .clear(clear),
    .wspeed(wspeed),
    .wchange(wchange),
    .wauto(wauto),
    .debuger(debuger),
    .wstrong(wstrong)
);
wire clear;
wire [31:0] send;
reg instart,inprepare;
wire WA,okpre;
wire [15:0] readlen;
wire [15:0] nouse2,nouse;
reg tohalt;
wire clearlength;
reg [15:0] sww;
wire solvenote;
wire [14:0]vmadd;
wire [11:0]vrgb,colorp;
wire vwe;
wire nnote0;
wire nnote;
wire [31:0] score;
wire [17:0]BLOn;
wire [15:0] nouu;
wire [15:0] notex,notey;
wire [15:0] mix,lled;
wire [15:0] perc;
wire [7:0] speednote;
wire endpass;
wire signed [15:0] wmodi;
assign mix={colorp,notex[3:0]};
assign lled=sww[15]?mix:nouu;
assign led[15:0]={lled[15:8],sww[14:11],auto,keep,state};
wire auto=sww[6]|wauto;
wire keep=sww[0]|wstrong;
Solve #(.X(16'd200),.Y(16'd150))solver(
    .clk(clk),
    .halt(tohalt),
    .prepare(inprepare),
    .start(instart),
    .next((clear||fakeclick)&&(state==RUN)),
    .keep(keep),
    .switcher(sww[7]),
    .sw2(sww[8]),
    .auto(auto),
    .length(readlen),
    .now(nowpos),
    .debug(sww[14:10]),
    .dataput(nouu),
    .dataput2(send),
    .wrong(WA),
    .solved(solvenote),
    .fakeclick(wfakeclick),
    .ready(okpre),
    .score(score),
    .wfresh(fresh),
    .wnotex(notex),
    .wnotey(notey),
    .nnote0(nnote0),
    .wBLOn   (BLOn),
    .wcolorp(colorp),
    .wperc(perc),
    .wwmodi(wmodi),
    .endpass(endpass)
);
reg [15:0] saveperc;
reg wa;
Fresh #(.X(16'd200),.Y(16'd150))fresher(
    .clk(clk),
    .fresh(fresh||(state==START)||instart),
    .perc(wa?saveperc:perc),
    .notex(notex),
    .notey(notey),
    .score(score),
    .speed(speednote),
    .notecolor(nnote0),
    .BLOn(BLOn),
    .colorp(colorp),
    .madd(vmadd),
    .vwe(vwe),
    .wastate((putgo<32'd2)&&(state==STOP)),
    .auto(auto),
    .keep(keep),
    .wmodi(wmodi),
    .prgb(vrgb)
);
reg [1:0] style;
initial begin
    style=0;wa=0;
end
always @(posedge clk)begin
    if(wchange)style<=style+2'd1;
end
DU show(
    .mode(style),
    .rst(rst),
    .clk(clk),
    .inrgb(vrgb),
    .we(vwe&&(state>=2'd1)),
    .addr(vmadd),
    .rgb(rgb),
    .VGA_HS(VGA_HS),
    .VGA_VS(VGA_VS)
);
parameter SLOW=32'd1;
wire [31:0] cpp;//clk per percent
CounterW #(.MAX(32'd360)) cnter2(
    .WIDTH(cpp),
    .clk(clk),
    .rst(state<RUN),
    .out({nouse,nowpos})
);
CounterW #(.MAX(32'd1000000)) cnter3(
    .WIDTH(cpp),
    .clk(clk),
    .rst((state<RUN)||solvenote),
    .out({nouse2,readlen})
);
speeder speeder(
    .clk(clk),
    .cpp(cpp),
    .wspeed(wspeed),
    .con(sww[5:3]),
    .speednote(speednote)
);
wire [31:0]putgo;
Counter #(.WIDTH(32'd100000000),.MAX(32'd100000)) cnter4(
    .clk(clk),
    .rst(state!=STOP),
    .out(putgo)
);


reg startmusic;
reg endmusic;
reg wrongmusic;
wire [31:0] putmus;
//  wire sd2,pwm2,sd3,pwm3;
//  assign sd=sww[10]?sd3:sd2;
//  assign pwm=sww[10]?pwm3:pwm2;
Music music(
    .WIDTH(cpp),
    .clk(clk),
    .startmusic(startmusic),
    .rst(rst),
    .endmusic(endmusic),
    .wrongmusic(wrongmusic),
    .pwm(pwm),
    .sd(sd),
    .debuger(putmus)
);
// audio#(
//     .speed(32'd10000_0000)  // 分频速度
// )audioer2(
//     .clk(clk),
//     .rstn(~rst),
//     .note_en(sww[15]),
//     .note(sww[14:11]),
//     .pwm(pwm3),
//     .sd(sd3)
// );

reg had;
initial begin
    state = START;instart=0;cnttt=0;sww=0;tohalt=0;had=0;
end
always @(posedge clk)begin
    sww<=sw;
end
always @(posedge clk)begin
    case(state)
        START:begin
            wa<=0;
            wrongmusic=0;
            endmusic<=1;
            if(clear||had)begin
                inprepare<=1;
                instart<=0;
                tohalt<=0;
                state<=WAIT;
                had<=1;
            end
        end
        WAIT:begin
            endmusic<=0;
            if(okpre&&clear)begin
                instart<=1;   
                inprepare<=0;
                startmusic<=1;
                state<=RUN;
            end
        end
        RUN: begin
            instart<=0;
            startmusic<=0;
            if(endpass)begin
                tohalt<=1;
                state<=STOP;
            end else if(sww[2])begin
                state<=START;
                tohalt<=1;
                endmusic<=1;
            end else if(WA)begin
                tohalt<=1;
                wa<=1;
                wrongmusic<=1;
                saveperc<=perc;
                state<=STOP;
                endmusic<=1;
            end
        end
        STOP: begin
            if((putgo>=32'd2)&&clear)begin
                state<=START;
            end
        end
        default:;
    endcase
end
reg [31:0] calcnt;
initial calcnt=0;
always @(posedge clk)begin
    if(clear)calcnt<=calcnt+32'd16;
end
transseg seg(
    .clk(clk),
    .rst(1'd0),
    .output_data(send),
    .output_valid(8'hff),

    .seg_data(leddata),
    .seg_an(ledsel)
);

endmodule

