module Segger(
    input                       clk,
    input                       rst,
    input       [31:0]          output_data,
    input       [ 7:0]          output_valid,

    output reg  [ 3:0]          seg_data,
    output reg  [ 2:0]          seg_an
);
reg [31:0] counter;
always @(posedge clk) begin
    if (rst)
        counter <= 0;
    else begin
        if (counter >= 32'd249999)
            counter <= 0;
        else
            counter <= counter + 32'b1;
    end
end
reg [2:0] seg_pid;
reg [2:0] seg_id;
initial begin
    counter = 0;
    seg_pid=0;
end
always @(posedge clk) begin
    if(counter >= 32'd249999)begin
        if(seg_pid==32'd7)seg_pid <= 0;
        else seg_pid <= seg_pid + 32'b1;
    end
end
always @(posedge clk) begin
    seg_id<=output_valid[seg_pid]?seg_pid:0;
end
always @(*) begin
    seg_data = 0;
    seg_an = seg_id;  
        case (seg_id)
            3'd0:seg_data=output_data[3:0];
            3'd1:seg_data=output_data[7:4];
            3'd2:seg_data=output_data[11:8];
            3'd3:seg_data=output_data[15:12];
            3'd4:seg_data=output_data[19:16];
            3'd5:seg_data=output_data[23:20];
            3'd6:seg_data=output_data[27:24];
            3'd7:seg_data=output_data[31:28];
            default:;
        endcase
end
endmodule