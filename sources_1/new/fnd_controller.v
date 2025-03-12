`timescale 1ns / 1ps

module fnd_controller (
    input clk,
    input reset,
    input sw_mode,
    input [6:0] msec,
    input [6:0] sec,
    input [6:0] min,
    input [6:0] hour,
    output [7:0] fnd_font,
    output [3:0] fnd_comm
);

    wire [3:0]  w_bcd, w_bcd1, w_bcd2,
                w_digit_msec_1, w_digit_msec_10, 
                w_digit_sec_1, w_digit_sec_10,
                w_digit_min_1, w_digit_min_10,
                w_digit_hour_1, w_digit_hour_10;

    wire [2:0] w_seg_sel;
    wire w_clk_100hz;
    clk_divider U_Clk_Divider (
        .clk  (clk),
        .reset(reset),
        .o_clk(w_clk_100hz)
    );
    counter_8 U_Counter_8 (
        .clk  (w_clk_100hz),
        .reset(reset),
        .o_sel(w_seg_sel)
    );
    decoder_3x8 U_decoder_3x8 (
        .seg_sel (w_seg_sel),
        .seg_comm(fnd_comm)
    );
    digit_splitter U_Msec_ds (
        .bcd(msec),
        .digit_1(w_digit_msec_1),
        .digit_10(w_digit_msec_10)
    );
    digit_splitter U_sec_ds (
        .bcd(sec),
        .digit_1(w_digit_sec_1),
        .digit_10(w_digit_sec_10)
    );
    digit_splitter U_min_ds (
        .bcd(min),
        .digit_1(w_digit_min_1),
        .digit_10(w_digit_min_10)
    );
    digit_splitter U_hour_ds (
        .bcd(hour),
        .digit_1(w_digit_hour_1),
        .digit_10(w_digit_hour_10)
    );
    /*
    mux_8x1 U_Mux_8x1 (
        .sel({1'b0, w_seg_sel}),
        .x_0(w_digit_msec_1),
        .x_1(w_digit_msec_10),
        .x_2(w_digit_sec_1),
        .x_3(w_digit_sec_10),
        .x_4(w_digit_min_1),
        .x_5(w_digit_min_10),
        .x_6(w_digit_hour_1),
        .x_7(w_digit_hour_10),
        .y  (w_bcd)
    );
*/

    mux_8x1 U_Mux_8x1_msec_sec (
        .sel(w_seg_sel),
        .x_0(w_digit_msec_1),
        .x_1(w_digit_msec_10),
        .x_2(w_digit_sec_1),
        .x_3(w_digit_sec_10),
        .x_4(4'ha),
        .x_5(4'ha),
        .x_6((w_digit_msec_10 > 4) ? 4'hf : 4'ha),
        .x_7(4'ha),
        .y  (w_bcd1)
    );

    mux_8x1 U_Mux_8x1_min_hour (
        .sel(w_seg_sel),
        .x_0(w_digit_min_1),
        .x_1(w_digit_min_10),
        .x_2(w_digit_hour_1),
        .x_3(w_digit_hour_10),
        .x_4(4'ha),
        .x_5(4'ha),
        .x_6((w_digit_msec_10 > 4) ? 4'hf : 4'ha),
        .x_7(4'ha),
        .y  (w_bcd2)
    );

    mux_2x1 U_mux_2x1(
        .sel(sw_mode),
        .x_0(w_bcd1),
        .x_1(w_bcd2),
        .y(w_bcd)
    );

    bcdtoseg U_bcdtoseg (
        .bcd(w_bcd),    // [3:0] sum 값 
        .seg(fnd_font)
    );

endmodule

module clk_divider (
    input  clk,
    input  reset,
    output o_clk
);
    parameter FCOUNT = 10_000;  // 이름을 상수화하여 사용.
    // $clog2 : 수를 나타내는데 필요한 비트수 계산
    reg [$clog2(FCOUNT)-1:0] r_counter;
    reg r_clk;
    assign o_clk = r_clk;

    always @(posedge clk, posedge reset) begin
        if (reset) begin  // 
            r_counter <= 0;  // 리셋상태
            r_clk <= 1'b0;
        end else begin
            // clock divide 계산, 100Mhz -> 200hz
            if (r_counter == FCOUNT - 1) begin
                r_counter <= 0;
                r_clk <= 1'b1;  // r_clk : 0->1
            end else begin
                r_counter <= r_counter + 1;
                r_clk <= 1'b0;  // r_clk : 0으로 유지.;
            end
        end
    end
endmodule

module counter_8 (
    input        clk,
    input        reset,
    output [3:0] o_sel
);

    reg [3:0] r_counter;
    assign o_sel = r_counter;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            r_counter <= 0;
        end else begin
            r_counter <= r_counter + 1;
        end
    end
endmodule

module digit_splitter (
    input  [6:0] bcd,
    output [3:0] digit_1,
    output [3:0] digit_10
);
    assign digit_1  = bcd % 10;  // 10의 1의 자리
    assign digit_10 = bcd / 10 % 10;  // 10의 10의 자리
endmodule

module decoder_3x8 (
    input [2:0] seg_sel,
    output reg [3:0] seg_comm
);

    // 2x4 decoder
    always @(seg_sel) begin
        case (seg_sel)
            3'b000:   seg_comm = 4'b1110;
            3'b001:   seg_comm = 4'b1101;
            3'b010:   seg_comm = 4'b1011;
            3'b011:   seg_comm = 4'b0111;
            3'b100:   seg_comm = 4'b1110;
            3'b101:   seg_comm = 4'b1101;
            3'b110:   seg_comm = 4'b1011;
            3'b111:   seg_comm = 4'b0111;
            default: seg_comm = 4'b1110;
        endcase
    end
endmodule

/*
module decoder_2x4 (
    input [1:0] seg_sel,
    output reg [3:0] seg_comm
);

    // 2x4 decoder
    always @(seg_sel) begin
        case (seg_sel)
            2'b00:   seg_comm = 4'b1110;
            2'b01:   seg_comm = 4'b1101;
            2'b10:   seg_comm = 4'b1011;
            2'b11:   seg_comm = 4'b0111;
            default: seg_comm = 4'b1110;
        endcase
    end
endmodule

module digit_splitter (
    input  [6:0] bcd,
    output [3:0] digit_1,
    output [3:0] digit_10
);
    assign digit_1  = bcd % 10;  // 10의 1의 자리
    assign digit_10 = bcd / 10 % 10;  // 10의 10의 자리
endmodule
module mux_4x1 (
    input  [1:0] sel,
    input  [3:0] digit_1,
    input  [3:0] digit_10,
    input  [3:0] digit_100,
    input  [3:0] digit_1000,
    output [3:0] bcd
);
    reg [3:0] r_bcd;
    assign bcd = r_bcd;

    always @(sel, digit_1, digit_10, digit_100, digit_1000) begin
        case (sel)
            2'b00:   r_bcd = digit_1;
            2'b01:   r_bcd = digit_10;
            2'b10:   r_bcd = digit_100;
            2'b11:   r_bcd = digit_1000;
            default: r_bcd = 4'bx;
        endcase
    end
endmodule
*/

module mux_8x1 (
    input [2:0] sel,
    input [3:0] x_0,
    input [3:0] x_1,
    input [3:0] x_2,
    input [3:0] x_3,
    input [3:0] x_4,
    input [3:0] x_5,
    input [3:0] x_6,
    input [3:0] x_7,
    output reg [3:0] y
);
    always @(*) begin
        case (sel)
            3'b000:  y = x_0;
            3'b001:  y = x_1;
            3'b010:  y = x_2;
            3'b011:  y = x_3;
            3'b100:  y = x_4;
            3'b101:  y = x_5;
            3'b110:  y = x_6;
            3'b111:  y = x_7;
            default: y = 4'bx;
        endcase
    end
endmodule

module mux_2x1 (
    input sel,
    input [3:0] x_0,
    input [3:0] x_1,
    output reg [3:0] y
);
    always @(*) begin
        case (sel)
            1'b0:  y = x_0;
            1'b1:  y = x_1;
            default: y = 4'bx;
        endcase
    end
endmodule

module bcdtoseg (
    input [3:0] bcd,  // [3:0] sum 값 
    output reg [7:0] seg
);
    // always 구문 출력으로 reg type을 가져야 한다.
    always @(bcd) begin

        case (bcd)
            4'h0: seg = 8'hc0;
            4'h1: seg = 8'hF9;
            4'h2: seg = 8'hA4;
            4'h3: seg = 8'hB0;
            4'h4: seg = 8'h99;
            4'h5: seg = 8'h92;
            4'h6: seg = 8'h82;
            4'h7: seg = 8'hf8;
            4'h8: seg = 8'h80;
            4'h9: seg = 8'h90;
            4'hf: seg = 8'h7f;
            default: seg = 8'hff;
        endcase
    end
endmodule
