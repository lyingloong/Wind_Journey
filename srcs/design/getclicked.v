module getclicked(
    input clk,
    input PS2_CLK,
    input PS2_DATA,
    input btn,
    input auto,
    output wauto,
    output wstrong,
    output [1:0] wspeed,
    output wchange,
    output [31:0] debuger,
    output clear    
);
wire [31:0] keycode32;
wire [7:0]data=keycode32[7:0];
keyboard_top key(
    .CLK100MHZ(clk),
    .PS2_CLK(PS2_CLK),
    .PS2_DATA(PS2_DATA),
    .keycode(keycode32),
    .dee(dee)
);
reg change;
assign wchange=change;
localparam KEY1 = 8'h16;
localparam KEY2 = 8'h1e;
localparam KEY4 = 8'h25;
localparam KEY5 = 8'h2e;
localparam KEY6 = 8'h36;
localparam KEY9 = 8'h46;
reg save;
reg tap;
reg autor,strongr;
reg [1:0] speed;
initial begin
    autor=0;
    save=0;
    speed=0;
    strongr=0;
end
assign wspeed=speed;
assign wauto=autor;
assign wstrong=strongr;
always @(posedge clk)begin
    if(save)begin
        if(!dee)begin
            save<=dee;
            case(data)
                KEY1: autor<=~autor;
                KEY2: strongr<=~strongr;
                KEY4: speed<=1;
                KEY5: speed<=2;
                KEY6: speed<=3;
                KEY9: change<=1;
                default:tap<=1;
            endcase
        end else begin
            speed<=0;
            change<=0;
            tap<=0;
        end
    end else begin
        if(dee)begin
            save<=dee;
            case(data)
                KEY1: autor<=~autor;
                KEY2: strongr<=~strongr;
                KEY4: speed<=1;
                KEY5: speed<=2;
                KEY6: speed<=3;
                KEY9: change<=1;
                default:tap<=1;
            endcase
        end else begin
            speed<=0;
            change<=0;
            tap<=0;
        end
    end
end
reg clearr;
reg btn_prev; 
initial begin
    save=0;
    tap=0;
    clearr=0;
    btn_prev=0;
end 
always @(posedge clk) begin
    if(btn)begin
        if(btn_prev)begin
            clearr<=0;
        end else begin
            btn_prev<=1;
            clearr<=1;
        end
    end else btn_prev<=0;
end
assign clear=(tap|clearr)&(!auto);
assign debuger=keycode32;
endmodule