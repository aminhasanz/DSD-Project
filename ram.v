`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/11/2021 10:39:34 AM
// Design Name: 
// Module Name: ram
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ram #(parameter s = 12) (
    input rst,
    input clk,
    input [s - 1:0] address,
    input write,
    input [31:0] dataIn,
    output reg [31:0] dataOut
    );
    
    reg [31:0] ram [(2 ** s) - 1:0];
    integer i;
    
    always @ (posedge clk, negedge rst) begin
        if (~rst) begin
            for (i = 0; i < 2 ** s; i = i + 1)
                ram[i] <= 0;
        end else begin
            dataOut <= ram[address];
            if(write)
                ram[address] <= dataIn;
        end
    end
endmodule
