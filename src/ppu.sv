module SpriteList(
    input clk,
    input [15:0] pix,
    input [7:0] sdf,
);
endmodule;

// core module
module ppu (
        input clk,
        input i_rst,
        input i_rd,
        input i_newline,
        input i_newframe,
        output [23:0] o_pixel,
        output o_rst);

    reg [9:0] c_pos_x;
    reg [9:0] c_pos_y;
    wire boundery;
    assign boundery = (c_pos_x[9] != 1'b0 || c_pos_y > 479);

    // test output
    assign o_pixel = boundery ? 24'h000000 :
                     out == 2'b01 ? 24'hFF0000 : 
                     out == 2'b10 ? 24'hFFFF00 :
                     out == 2'b11 ? 24'hFFFFFF : 24'h716AB8;

    // position to render sprite
    wire[9:0] pos_x;
    assign pos_x = 9'h084;
    wire[9:0] pos_y;
    assign pos_y = 10'h0a8;

    wire check;
    assign check = c_pos_y >= pos_y && c_pos_y <= pos_y + 9'd15;
    wire [9:0] offset;
    assign offset = c_pos_y - pos_y;


    // sprite
    reg [15:0] sprite_image [7:0];
    initial begin
        $readmemb("test_sprite_8x8.txt", sprite_image);
    end

    reg [15:0] value;

    // handle sprite
    always @(posedge clk) begin
        //load = 1'b0000;
        if (i_newframe) begin
            c_pos_y <= 9'b0;
            c_pos_x <= 9'b0;
        end
        else if (i_newline) begin
            c_pos_y <= c_pos_y + 1;
            c_pos_x <= 9'b0;
        end
        else if (i_rd) c_pos_x <= c_pos_x + 1;
    end
    

    // reset
    reg[2:0] rst_cnt = 0;
    assign o_rst = ~rst_cnt[2];

    always @(posedge clk) begin
        if (o_rst) begin
            rst_cnt <= rst_cnt + 1;
        end
    end

    wire [1:0] result [0:7];
    assign result [0] = {value[7], value[15]};
    assign result [1] = {value[6], value[14]};
    assign result [2] = {value[5], value[13]};
    assign result [3] = {value[4], value[12]};
    assign result [4] = {value[3], value[11]};
    assign result [5] = {value[2], value[10]};
    assign result [6] = {value[1], value[ 9]};
    assign result [7] = {value[0], value[ 8]};

    reg [1:0] out;

    reg [9:0] count;

    // FSM
    typedef enum {START, IDLE, PREP, RENDER} states;
    reg [1:0] cur_state, next_state;

    always @(posedge clk) begin
        if (~rst_cnt[2]) cur_state <= START;4
        else cur_state <= next_state;
    end

    always @(posedge clk) begin
        next_state = cur_state;
        case (cur_state)
            START: next_state = check ? PREP : IDLE;
            IDLE: if (i_newline || i_newframe) next_state = RENDER;
            PREP: if (~boundery) next_state = RENDER;
            RENDER: if (boundery) next_state = PREP;
            default:
                next_state = START;
        endcase
    end

    always @(posedge clk) begin
        case (cur_state)
            PREP: begin // SET UP SPRITE FOR NEXT LINE
                if (~c_pos_y[0])
                    value <= sprite_image[offset[3:1]];
                count <= 9'h000;
                out = 2'h0;
            end
            RENDER: begin // SET SPRITE TO ENABLED
                if (c_pos_x[7:0] >= pos_x && c_pos_x <= pos_x + 9'd15 && check) begin
                    out <= result[count[7:0]];
                    //enable <= offset2[count[7:0]];
                    count <= count + 9'h001;
                end
                else out <= 2'h0;
            end
            default: begin
            end

        endcase
    end
endmodule