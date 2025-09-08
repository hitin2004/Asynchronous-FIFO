`timescale 1ns / 1ps

module fifo (
    input              write_clk,
    input              read_clk,
    input              reset,
    input              write_en,
    input              read_en,
    input      [7:0]   data_in,
    output             mem_full,
    output             mem_empty,
    output reg [7:0]   out
);

    reg [7:0] mem [0:7]; // 8x8 memory

    reg [3:0] write_ptr_bin, read_ptr_bin;               
    reg [3:0] write_ptr_gray, read_ptr_gray;

    reg [3:0] write_ptr_gray_sync1, write_ptr_gray_sync2;
    reg [3:0] read_ptr_gray_sync1, read_ptr_gray_sync2;

    wire [3:0] write_ptr_bin_sync2, read_ptr_bin_sync2; //// 4th bit for know wrapping or not, 

       // B2g function, bin2gray acts a output only
    function [3:0] bin2gray;
        input [3:0] bin;
        bin2gray = bin ^ (bin >> 1);
    endfunction

    // g2b 
    function [3:0] gray2bin;
        input [3:0] gray;
        gray2bin = gray ^ (gray >> 1) ^ (gray >> 2) ^ (gray >> 3);
    endfunction

    
    assign write_ptr_bin_sync2 = gray2bin(write_ptr_gray_sync2);
    assign read_ptr_bin_sync2  = gray2bin(read_ptr_gray_sync2);

   
    assign mem_full  = (write_ptr_bin[2:0] == read_ptr_bin_sync2[2:0]) &&  // using write_ptr_bin instaed of sync is that it is local to the write clk and the sync2 will be delayed by 2 cycles, 
                       (write_ptr_bin[3]   != read_ptr_bin_sync2[3]);   //  write clk is concerned with full condition

    // Empty: both pointers are exactly the same
    assign mem_empty = (write_ptr_bin_sync2 == read_ptr_bin);  // read clk is concerned with empoty condition  so its local read pointer, which read_ptr_bin

    // Write logic
    always @(posedge write_clk or negedge reset) begin
        if (!reset) begin
            write_ptr_bin  <= 4'b0000;
            write_ptr_gray <= 4'b0000;
        end else if (write_en && !mem_full) begin
            mem[write_ptr_bin[2:0]] <= data_in;
            write_ptr_bin  <= write_ptr_bin + 1;
            write_ptr_gray <= bin2gray(write_ptr_bin + 1);
        end
    end

    // Read logic
    always @(posedge read_clk or negedge reset) begin
        if (!reset) begin
            read_ptr_bin  <= 4'b0000;
            read_ptr_gray <= 4'b0000;
            out           <= 8'b0;
        end else if (read_en && !mem_empty) begin
            out           <= mem[read_ptr_bin[2:0]];
            read_ptr_bin  <= read_ptr_bin + 1;
            read_ptr_gray <= bin2gray(read_ptr_bin + 1);
        end
    end

    // Synchronize write_ptr_gray to read clock domain
    always @(posedge read_clk or negedge reset) begin
        if (!reset) begin
            write_ptr_gray_sync1 <= 4'b0000;
            write_ptr_gray_sync2 <= 4'b0000;
        end else begin
            write_ptr_gray_sync1 <= write_ptr_gray;
            write_ptr_gray_sync2 <= write_ptr_gray_sync1;
        end
    end

    // Synchronize read_ptr_gray to write clock domain
    always @(posedge write_clk or negedge reset) begin
        if (!reset) begin
            read_ptr_gray_sync1 <= 4'b0000;
            read_ptr_gray_sync2 <= 4'b0000;
        end else begin
            read_ptr_gray_sync1 <= read_ptr_gray;
            read_ptr_gray_sync2 <= read_ptr_gray_sync1;
        end
    end

endmodule
