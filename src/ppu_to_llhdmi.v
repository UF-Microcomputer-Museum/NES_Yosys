module ppu_to_llhdmi(input clk,
                     output reg ppu_h, output reg ppu_v,
                     output reg [7:0] hdmi_r, output reg[7:0] hdmi_g, output reg[7:0] hdim_b,
                     output [9:0] vga_hcounter,
                     output [9:0] vga_vcounter,
                     output [9:0] next_pixel_x, // The pixel we need NEXT cycle.
                     input [14:0] pixel,        // Pixel for current cycle.
                     input sync,
                     input border);
    // inputs and outputs still need further configurtions


endmodule