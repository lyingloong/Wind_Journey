
// `include "MusicDecoder.v"
// `include "Pwm_generator.v"

// 放声模块
// 利用 pwm_gen 模块生成占空比可调的 PWM 信号，实现声音播放
module sound (
    input [11:0] period,  // 周期信号
    input clk,            // 时钟信号
    output pwm            // PWM 输出信号
);
    /*
    A-la-440HZ为准：
    do的频率为261.6HZ，382263clk
    re的频率为293.6HZ，340599clk
    mi的频率为329.6HZ，303398clk
    fa的频率为349.2HZ，286369clk
    sol的频率为392HZ，255102clk
    la的频率为440HZ， 227272clk
    si的频率为493.8HZ,202511clk
    */
    reg [11:0] h_time=1;
    pwm_gen pg1 ( // period 
        /*
        input [11:0] period
        input [11:0] h_time,
        input clk,
        output reg wave,pulse
        */
        .period(period),
        .h_time(h_time),
        .clk(clk),
        .wave(pwm),
        .pulse(pulse)
    );
    reg up=1, down=0;
    always @(posedge clk) begin
        if (pulse) begin
            if (up) begin
                h_time <= h_time+1;
                if (h_time>period) begin
                    up <= 0;
                    down <= 1;
                end
            end else begin
                h_time <= h_time-1;
                if (h_time==1) begin
                    down <= 0;
                    up <= 1;
                end
            end
        end
    end
endmodule

module Music_decoder (
    input [4:0] cin,
    output reg [11:0] cout,
    output reg sd
);
    always @(*) begin
        sd=1;
        case (cin)
            5'b0: sd=0;//stop
            5'b00001:cout=618;//low 1
            5'b00010:cout=583;//2
            5'b00011:cout=550;//3
            5'b00100:cout=535;//4
            5'b00101:cout=505;//5
            5'b00110:cout=476;//6
            5'b00111:cout=450;//7
            5'b01000:cout=437;//mid 1
            5'b01001:cout=412;//2
            5'b01010:cout=389;//3
            5'b01011:cout=378;//4
            5'b01100:cout=357;//5
            5'b01101:cout=337;//6
            5'b01110:cout=327;//7，318
            5'b01111:cout=309;//high 1
            5'b10000:cout=291;//2
            5'b10001:cout=275;//3 
            5'b10010:cout=267;//4
            5'b10011:cout=252;//5
            5'b10100:cout=238;//6
            5'b10101:cout=231;//7,225
            5'b10110:cout=425;//sp1
            5'b10111:cout=277;//sp2
            5'b11000:cout=218;//hh1
            5'b11001:cout=206;
            5'b11010:cout=195;
            5'b11011:cout=189;
            5'b11100:cout=178;
            5'b11101:cout=168;
            5'b11110:cout=159;
            default: cout=618;//low1
        endcase
    end
endmodule

// 音频(主)模块
// 读取音符数据并生成相应的音频信号
// 提供一个 pwm 信号用于播放音频
module audio#(
    parameter speed = 10_000_0000  // 分频速度
)
(
    input clk,             // 主时钟信号
    input rstn,            // 复位信号（低有效）
    input note_en,         // 音符使能信号
    input [3:0] note,      // 音符信号 最高位为1时表示高八度 后三位表示音符
    output reg pwm,        // PWM 信号输出
    output sd              // 音频控制信号
);

    // reg [11:0] addra=0;
    reg [4:0]  douta2;
    wire [4:0] douta;
    // reg [31:0] FRD=0;
    reg higher;
    initial begin
        higher=0;
    end
    assign douta = douta2 +(higher?7:0);
    // // 512 clk~20kHZ~5000clk
    // blk_mem_gen_music music (
    //     .clka(clk),      // 输入时钟
    //     .ena(1),         // 使能信号
    //     .addra(addra),   // 当前读取地址
    //     .douta(douta)    // 音符输出（5 位）
    // );

    wire [11:0] period;
    wire sd1;

    // // 长音乐分频/地址处理
    // always @(posedge clk) begin
    //     if (FRD>speed) FRD <= 0;
    //     else FRD <= FRD+1;
    //     if (!rstn) begin
    //         addra <= 0;
    //     end else if (FRD==0) begin
    //         if (addra >= 2500) addra <= 0;
    //         else begin
    //             addra <= addra+1;
    //         end
    //     end
    // end

    // 音符解码模块
    always @(posedge note_en) begin
        higher<=note[3];
        case (note[2:0]) 
        
            3'b000: douta2 <= 5'b00000;
            3'b001: douta2 <= 5'b01000;
            3'b010: douta2 <= 5'b01001;
            3'b011: douta2 <= 5'b01010;
            3'b100: douta2 <= 5'b01011;
            3'b101: douta2 <= 5'b01100;
            3'b110: douta2 <= 5'b01101;
            3'b111: douta2 <= 5'b01110;
           // default: douta <= 5'b01000;
        endcase // 高八度音符加 7
    end

    // 将音符（5 位）解码为对应的周期值
    Music_decoder md (
        .cin(douta),     // 输入音符（5 位）
        .cout(period),   // 输出周期（12 位）
        .sd(sd1)         // 输出控制信号
    );

    assign sd=sd1;
    wire pwm1;

    sound music1 (
        .period(period),
        .clk(clk),
        .pwm(pwm1)
    );

    always @(*) begin
        pwm = (sd1 & pwm1);  // 按照控制信号 `sd1` 使能 PWM 输出
    end

endmodule


// 部分约束文件

// ## Clock signal
// set_property -dict { PACKAGE_PIN E3    IOSTANDARD LVCMOS33 } [get_ports { clk }]; #IO_L12P_T1_MRCC_35 Sch=clk100mhz
// create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports {clk}];

// ##Buttons
// set_property -dict { PACKAGE_PIN C12   IOSTANDARD LVCMOS33 } [get_ports { rstn }]; #IO_L3P_T0_DQS_AD1P_15 Sch=cpu_resetn
// #set_property -dict { PACKAGE_PIN N17   IOSTANDARD LVCMOS33 } [get_ports { BTNC }]; #IO_L9P_T1_DQS_14 Sch=btnc
// #set_property -dict { PACKAGE_PIN M18   IOSTANDARD LVCMOS33 } [get_ports { BTNU }]; #IO_L4N_T0_D05_14 Sch=btnu
// #set_property -dict { PACKAGE_PIN P17   IOSTANDARD LVCMOS33 } [get_ports { BTNL }]; #IO_L12P_T1_MRCC_14 Sch=btnl
// #set_property -dict { PACKAGE_PIN M17   IOSTANDARD LVCMOS33 } [get_ports { BTNR }]; #IO_L10N_T1_D15_14 Sch=btnr
// #set_property -dict { PACKAGE_PIN P18   IOSTANDARD LVCMOS33 } [get_ports { BTND }]; #IO_L9N_T1_DQS_D13_14 Sch=btnd

// ##PWM Audio Amplifier
// set_property -dict { PACKAGE_PIN A11   IOSTANDARD LVCMOS33 } [get_ports { pwm }]; #IO_L4N_T0_15 Sch=aud_pwm
// set_property -dict { PACKAGE_PIN D12   IOSTANDARD LVCMOS33 } [get_ports { sd }]; #IO_L6P_T0_15 Sch=aud_sd