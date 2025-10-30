// 8 of these exist, they are used to output sprites.
module Sprite(input clk, input ce,
              input enable,
              input [3:0] load, 
              input [26:0] load_in,
              output [26:0] load_out,
              output [4:0] bits); // Low 4 bits = pixel, high bit = prio
    reg [1:0] upper_color; // Upper 2 bits of color
    reg [7:0] x_coord;     // X coordinate where we want things
    reg [7:0] pix1, pix2;  // Shift registers, output when x_coord == 0
    reg aprio;             // Current prio
    wire active = (x_coord == 0);
    always @(posedge clk) if (ce) begin
        if (enable) begin
            if (!active) begin
                // Decrease until x_coord is zero.
                x_coord <= x_coord - 8'h01;
            end else begin
                pix1 <= pix1 >> 1;
                pix2 <= pix2 >> 1;
            end
        end
        if (load[3]) pix1 <= load_in[26:19];
        if (load[2]) pix2 <= load_in[18:11];
        if (load[1]) x_coord <= load_in[10:3];
        if (load[0]) {upper_color, aprio} <= load_in[2:0];
    end
        assign bits = {aprio, upper_color, active && pix2[0], active && pix1[0]};
        assign load_out = {pix1, pix2, x_coord, upper_color, aprio};
endmodule  // SpriteGen

// This contains all 8 sprites. Will return the pixel value of the highest prioritized sprite.
// When load is set, and clocked, load_in is loaded into sprite 7 and all others are shifted down.
// Sprite 0 has highest prio.
// 226 LUTs, 68 Slices
module SpriteSet(input clk, input ce,   // Input clock
                 input enable,          // Enable pixel generation
                 input [3:0] load,      // Which parts of the state to load/shift.
                 input [26:0] load_in,  // State to load with 
                 output [4:0] bits,     // Output bits
                 output is_sprite0);    // Set to true if sprite #0 was output

    wire [26:0] load_out7, load_out6, load_out5, load_out4, load_out3, load_out2, load_out1, load_out0; 
    wire [4:0] bits7, bits6, bits5, bits4, bits3, bits2, bits1, bits0;
    Sprite sprite7(clk, ce, enable, load, load_in,   load_out7, bits7);
    Sprite sprite6(clk, ce, enable, load, load_out7, load_out6, bits6);
    Sprite sprite5(clk, ce, enable, load, load_out6, load_out5, bits5);
    Sprite sprite4(clk, ce, enable, load, load_out5, load_out4, bits4);
    Sprite sprite3(clk, ce, enable, load, load_out4, load_out3, bits3);
    Sprite sprite2(clk, ce, enable, load, load_out3, load_out2, bits2);
    Sprite sprite1(clk, ce, enable, load, load_out2, load_out1, bits1);
    Sprite sprite0(clk, ce, enable, load, load_out1, load_out0, bits0);          
    // Determine which sprite is visible on this pixel.
    assign bits = bits0[1:0] != 0 ? bits0 : 
                  bits1[1:0] != 0 ? bits1 : 
                  bits2[1:0] != 0 ? bits2 : 
                  bits3[1:0] != 0 ? bits3 : 
                  bits4[1:0] != 0 ? bits4 : 
                  bits5[1:0] != 0 ? bits5 : 
                  bits6[1:0] != 0 ? bits6 : 
                                    bits7;
    assign is_sprite0 = bits0[1:0] != 0;
endmodule  // SpriteSet





// core module
module ppu (
    input clk,
    input i_rst,
    input i_rd,
    input i_newline,
    input i_newframe,
    output [23:0] o_pixel,
    output o_rst
);
    // Controll Reg 1
    reg obj_patt;
    reg bg_patt;
    reg obj_size;
    reg vbl_enable;

    // Controll Reg 2
    reg grayscale;
    reg playfield_clip;
    reg object_clip;
    reg enble_playfield;
    reg enable_objects;
    reg [2:0] color_intensity;


    initial begin
        obj_patt = 0;
        bg_patt = 0;
        obj_size = 0;
        vbl_enable = 0;
        grayscale = 0;
        playfield_clip = 0;
        object_clip = 0;
        enable_playfield = 0;
        enable_objects = 0;
        color_intensity = 0;
    end



    // test output
    reg [23:0] pixel;
    assign o_pixel = pixel;

    always @(posedge clk) begin
        if (i_rd) pixel <= 24'h716AB8;
        else pixel <= 24'h000000;
    end

    reg[2:0] rst_cnt = 0;
    assign o_rst = ~rst_cnt[2];

    always @(posedge clk) begin
        if (o_rst) begin
            rst_cnt <= rst_cnt + 1;
        end
    end

endmodule