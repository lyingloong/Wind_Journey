
// 键盘数据接受模块

// PS/2键盘数据格式： 每次键盘按下一个按键，会发送一个字节的扫描码；如果按住某个键，还会发送重复码；松开时会发送一个释放码（通常是F0后跟按键扫描码）

// PS/2 数据帧的结构
// 一个 PS/2 数据帧包含以下部分，总共 11 位（从低位到高位依次传输）：

// 位号	名称	作用
// 0	开始位（Start Bit）	恒为 0，用于标志一帧数据的开始。
// 1~8	数据位（Data Bits）	包含实际传输的数据（8位，低位在前，高位在后）。
// 9	奇偶校验位（Parity）	用于检查数据传输的正确性（偶校验）。
// 10	停止位（Stop Bit）	恒为 1，标志一帧数据的结束。


module PS2Receiver(
    input clk,
    input kclk,
    input kdata,
    output [31:0] keycodeout,
    output [0:0] flagout
    );
    
wire kclkf, kdataf;
reg [7:0] datacur;
reg [3:0] cnt;
reg [31:0] keycode;

    
initial begin
    keycode[31:0]<=32'h00000000;
    cnt<=4'b0000;
end
//    assign kclkf=kclk;
 //   assign kdataf=kdata;
debouncer debounce(
    .clk(clk),
    .I0(kclk),
    .I1(kdata),
    .O0(kclkf),
    .O1(kdataf)
);
    reg save;
// 使用状态计数器 cnt 接收PS/2数据帧：
// cnt = 0：开始位。
// cnt = 1~8：接收8位数据。
// cnt = 9：奇偶校验位（忽略）。
// cnt = 10：停止位。
reg flag2;

reg can;
always@(posedge clk) begin
    if(kclkf)begin
        save<=1;
    end else if(save)begin
        save<=0;
        case(cnt)
            0:;//Start bit
            1:datacur[0]<=kdataf;
            2:datacur[1]<=kdataf;
            3:datacur[2]<=kdataf;
            4:datacur[3]<=kdataf;
            5:datacur[4]<=kdataf;
            6:datacur[5]<=kdataf;
            7:datacur[6]<=kdataf;
            8:datacur[7]<=kdataf;
            9:begin
                keycode[31:24]<=keycode[23:16];
                keycode[23:16]<=keycode[15:8];
                keycode[15:8]<=keycode[7:0];
                keycode[7:0]<=datacur;
                if(datacur==8'hf0)begin
                    can<=1;
                end else if(can)begin
                    can<=0;
                end else begin
                    flag2<=~flag2;
                end
            end
            10:;
        endcase
        if (cnt<=9) cnt<=cnt+1;
        else if (cnt==10) cnt<=0;    
    end 
end

initial begin
    flag2=0;
    keycode<=0;
end
assign flagout=flag2;
// keycodeout 输出最近四次扫描码，每八位为一组
assign keycodeout = keycode;
    
endmodule
