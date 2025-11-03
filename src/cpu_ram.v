`default_nettype none

module cpu_ram (
    input wire clk, // input the clock to read/write the data on the clock edge
    input wire [10:0] address, // 2^11 = 2048 <--- address locations of the bytes
    input wire write_enable, // determine if the ram should be read or written
    input wire [7:0] write_data, // get data to write to the ram
    output wire [7:0] read_data, // use this wire to output the data from the ram
);

    reg [7:0] ram [0:2048]; // Ram of 2k

    always @(posedge clk) begin
        if (write_enable) begin // the write enable allows us to write the data from input into the RAM
            ram [address] <= write_data;
        end
        else begin
            read_data <= ram[address]; // if the write enable is false, read the data from the address into the read_data
        end
    end
endmodule
