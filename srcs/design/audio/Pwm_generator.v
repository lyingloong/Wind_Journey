`timescale 1ns / 1ps

// 占空比h_time/period, 调频模块
module pwm_gen (
    input [11:0] period,  // PWM 信号周期
    input [11:0] h_time,  // PWM 信号的高电平时间
    input clk,            // 时钟信号
    output reg wave,      // PWM 波形输出
    output reg pulse      // 用于计数完成时产生的脉冲信号
);
    reg [11:0] cnt=0;
    always @(posedge clk) begin
        cnt <= cnt+1;
        pulse <= 0;
        if(cnt>period) begin
            cnt <= 0;
            pulse <= 1;
        end else if(cnt<{h_time>>2}) begin // 减3/4音量
            wave <= 1;
        end else begin
            wave <= 0;
        end
    end
endmodule