<h2 align="center">Lab8_Report</h2>

<h6 align="center">Author： 高华成，王昊</h6>

<h6 align="center">Date：24/12/29</h6>

### 1. Description

我们利用 *Nexys A7* 教学用开发板开发了一款音游，外设有 *PS2* 机械键盘和 *VGA* 显示屏。

### 2. Code

#### 2.1. Modules

主要模块功能说明。

##### 2.1.1. 顶层模块

```verilog
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
```

##### 2.1.2. 主逻辑模块

```verilog
module Solve#(
    parameter Y=150,
    parameter X=200
)(
    input clk,
    input halt,
    input prepare,
    input start,
    input next,
    input switcher,
    input sw2,
    input auto,
    input keep,
    input [15:0] length,
    input [15:0] now,
    input [4:0] debug,
    output [15:0] dataput,//接LED
    output [31:0] dataput2,//接数码管
    output wrong,
    output solved,
    output fakeclick,
    output [31:0] score,
    output signed [15:0] wmodi, 
    output ready,
    output wfresh,
    output [11:0] wcolorp,
    output [17:0] wBLOn,
    output nnote0,
    output [15:0] wnotex,wnotey,
    output [15:0] wperc,
    output endpass
);
```

**功能**: 游戏主逻辑模块。根据当前状态进行游戏中的判定、分数计算、颜色设置等功能。

**输入**

- `clk`: 时钟信号。
- `prepare` 和 `start`: 游戏是否准备好以及是否开始。
- `keep` 和 `auto`: 游戏模式状态。
- `now`: 当前位置信息。

**输出**

- `score`: 分数。
- `colorp`: 当前颜色配置。
- `endpass`: 游戏是否结束。

**作用**: 控制游戏的主要流程和规则。

##### 2.1.3. 显示模块

**显示控制模块**

```verilog
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
```

**功能**: 显示控制模块，用于控制 VGA 显示输出。

**输入**

- `mode`: 显示模式。
- `inrgb`: 输入的 RGB 信号。

**输出**

- `rgb`: 输出到显示设备的 RGB 信号。
- `VGA_HS` 和 `VGA_VS`: VGA 的行同步和场同步信号。

**作用**: 显示系统核心模块。

**刷新模块**

```verilog
module Fresh#(
    parameter Y=150,
    parameter X=200
)(
    input clk,
    input fresh,
    input [15:0] perc,
    input auto,keep,
    input [15:0] notex,
    input signed [15:0] wmodi,
    input [15:0] notey,
    input [31:0] score,
    input [17:0] BLOn,
    input [11:0] colorp,
    input notecolor,
    input wastate,
    input [7:0] speed,
    output [14:0] madd,
    output vwe,
    output [11:0] prgb
);
```

**功能**: 用于刷新显示内容，包括颜色、位置等信息。

**输入**

- `fresh`: 刷新信号。
- `notex` 和 `notey`: 音符或其他对象的位置。
- `speed`: 速度信息。

**输出**

- `vrgb`: VGA 显示的颜色数据。
- `vwe`: 写使能信号。
- `BLOn`: 用于背景灯或其他显示设备的控制。

**作用**: 负责游戏图像或数据的更新。

##### 2.1.4 设备输入模块

```verilog
module getclicked(
    input clk,
    input PS2_CLK,
    input PS2_DATA,
    input btn,
    input auto,
    output wauto,
    output wstrong,
    output [1:0] wspeed,
    output [31:0] debuger,
    output clear    
);
```

**功能**: 用于检测按键或其他输入设备的动作。接收来自 `PS2` 接口的时钟和数据，解析用户操作，同时支持按钮输入。

**输入**

- `clk`: 时钟信号。
- `PS2_CLK` 和 `PS2_DATA`: PS/2 接口的时钟和数据。
- `btn`: 按钮信号。

**输出**

- `wauto`: 自动模式信号。
- `wspeed`: 调速模式。
- `wstrong`: 是否进入“无敌”模式。
- `debuger`: 用于调试的输出信号。

**作用**: 用户输入逻辑和状态切换的核心模块。

##### 2.1.5 音频模块

**音频控制模块**

```verilog
module Music(
    input [31:0]WIDTH,
    input clk,
    input startmusic,
    input rst,
    input endmusic,
    input wrongmusic,
    output pwm,
    output sd,
    output [31:0] debuger
);
```

**功能**: 音效模块，控制音乐播放，包括游戏开始、结束或错误音效。

**输入**

- `WIDTH`: 播放频率。
- `startmusic`: 开始音乐的信号。

**输出**

- `pwm`: 音频输出。

**作用**: 负责生成游戏的背景音乐或提示音。

**音频输出模块**

```verilog
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
```

**功能**: 控制另一种音频输出方式，支持 PWM 和音频存储设备。

**输入**

- `note_en`: 音符使能信号。
- `note`: 音符数据。

**输出**

- `pwm`: 音频 PWM 信号。

**作用**: 生成音频信号。

#### 2.2. Constraints

项目约束文件。

```verilog
set_property -dict {PACKAGE_PIN V18 IOSTANDARD LVCMOS33} [get_ports clk]
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} -add [get_ports clk]

## LEDs
set_property -dict {PACKAGE_PIN B15 IOSTANDARD LVCMOS33} [get_ports {led[0]}]
set_property -dict {PACKAGE_PIN B16 IOSTANDARD LVCMOS33} [get_ports {led[1]}]
set_property -dict {PACKAGE_PIN C13 IOSTANDARD LVCMOS33} [get_ports {led[2]}]
set_property -dict {PACKAGE_PIN B13 IOSTANDARD LVCMOS33} [get_ports {led[3]}]
set_property -dict { PACKAGE_PIN A15   IOSTANDARD LVCMOS33 } [get_ports {led[4]}]
set_property -dict { PACKAGE_PIN A16   IOSTANDARD LVCMOS33 } [get_ports {led[5]}]
set_property -dict { PACKAGE_PIN A13   IOSTANDARD LVCMOS33 } [get_ports {led[6]}]
set_property -dict { PACKAGE_PIN A14   IOSTANDARD LVCMOS33 } [get_ports {led[7]}]

## sw
set_property -dict { PACKAGE_PIN B17   IOSTANDARD LVCMOS33 } [get_ports {sw[0]}]
set_property -dict { PACKAGE_PIN B18   IOSTANDARD LVCMOS33 } [get_ports {sw[1]}]
set_property -dict { PACKAGE_PIN D17   IOSTANDARD LVCMOS33 } [get_ports {sw[2]}]
set_property -dict { PACKAGE_PIN C17   IOSTANDARD LVCMOS33 } [get_ports {sw[3]}]
set_property -dict { PACKAGE_PIN C18   IOSTANDARD LVCMOS33 } [get_ports {sw[4]}]
set_property -dict { PACKAGE_PIN C19   IOSTANDARD LVCMOS33 } [get_ports {sw[5]}]
set_property -dict { PACKAGE_PIN E19   IOSTANDARD LVCMOS33 } [get_ports {sw[6]}]
set_property -dict { PACKAGE_PIN D19   IOSTANDARD LVCMOS33 } [get_ports {sw[7]}]

## btn
set_property -dict {PACKAGE_PIN F20 IOSTANDARD LVCMOS33} [get_ports {btn}]

## UART
set_property -dict {PACKAGE_PIN F13 IOSTANDARD LVCMOS33} [get_ports txd]
set_property -dict {PACKAGE_PIN F15 IOSTANDARD LVCMOS33} [get_ports rxd]

## framebuffer
set_property -dict {PACKAGE_PIN E17 IOSTANDARD LVCMOS33} [get_ports {sck}]
set_property -dict {PACKAGE_PIN C14 IOSTANDARD LVCMOS33} [get_ports {mosi}]
set_property -dict {PACKAGE_PIN C15 IOSTANDARD LVCMOS33} [get_ports {miso}]

## seg
set_property -dict { PACKAGE_PIN F18   IOSTANDARD LVCMOS33 } [get_ports {d[0]}]
set_property -dict { PACKAGE_PIN E18   IOSTANDARD LVCMOS33 } [get_ports {d[1]}]
set_property -dict { PACKAGE_PIN B20   IOSTANDARD LVCMOS33 } [get_ports {d[2]}]
set_property -dict { PACKAGE_PIN A20   IOSTANDARD LVCMOS33 } [get_ports {d[3]}]

set_property -dict { PACKAGE_PIN A18   IOSTANDARD LVCMOS33 } [get_ports {an[0]}]
set_property -dict { PACKAGE_PIN A19   IOSTANDARD LVCMOS33 } [get_ports {an[1]}]
set_property -dict { PACKAGE_PIN F19   IOSTANDARD LVCMOS33 } [get_ports {an[2]}]
```

### 3. Demo

实机演示。

<img src= "./figs/d1.jpg" width=500>

<img src= "./figs/d2.jpg" width=500>

<img src= "./figs/d3.jpg" width=500>

<img src= "./figs/d4.jpg" width=500>
