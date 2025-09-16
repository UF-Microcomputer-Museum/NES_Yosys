module ppu_to_llhdmi(input clk,
                     output reg vga_h, output reg vga_v,
                     output reg [3:0] vga_r, output reg[3:0] vga_g, output reg[3:0] vga_b,
                     output [9:0] vga_hcounter,
                     output [9:0] vga_vcounter,
                     output [9:0] next_pixel_x, // The pixel we need NEXT cycle.
                     input [14:0] pixel,        // Pixel for current cycle.
                     input sync,
                     input border);



endmodule