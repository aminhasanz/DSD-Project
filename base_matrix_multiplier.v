`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/11/2021 10:14:24 AM
// Design Name: 
// Module Name: base_matrix_multiplyer
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


module base_matrix_multiplier(
        input clk, rst, start, out_ack,
        input [31:0] matrix1_0,
        input [31:0] matrix1_1,
        input [31:0] matrix1_2,
        input [31:0] matrix1_3,
        input [31:0] matrix2_0,
        input [31:0] matrix2_1,
        input [31:0] matrix2_2,
        input [31:0] matrix2_3,
        output reg [31:0] outMatrix0,
        output reg [31:0] outMatrix1,
        output reg [31:0] outMatrix2,
        output reg [31:0] outMatrix3,
        output reg out_ready
    );
    
    reg [31:0] a1;
    reg [31:0] a2;
    reg [31:0] a3;
    reg [31:0] a4;
    reg [31:0] b1;
    reg [31:0] b2;
    reg [31:0] b3;
    reg [31:0] b4;
    
    reg ready;
    
    reg mul1_ack;
    reg mul2_ack;
    reg mul3_ack;
    reg mul4_ack;
    reg mul5_ack;
    reg mul6_ack;
    reg mul7_ack;
    reg mul8_ack;
    
    wire [31:0] mul1_out;
    wire [31:0] mul2_out;
    wire [31:0] mul3_out;
    wire [31:0] mul4_out;
    wire [31:0] mul5_out;
    wire [31:0] mul6_out;
    wire [31:0] mul7_out;
    wire [31:0] mul8_out;
    
    wire mul1_stb;
    wire mul2_stb;
    wire mul3_stb;
    wire mul4_stb;
    wire mul5_stb;
    wire mul6_stb;
    wire mul7_stb;
    wire mul8_stb;
    
    wire mul1_0ack;
    wire mul1_1ack;
    wire mul2_0ack;
    wire mul2_1ack;
    wire mul3_0ack;
    wire mul3_1ack;
    wire mul4_0ack;
    wire mul4_1ack;
    wire mul5_0ack;
    wire mul5_1ack;
    wire mul6_0ack;
    wire mul6_1ack;
    wire mul7_0ack;
    wire mul7_1ack;
    wire mul8_0ack;
    wire mul8_1ack;
    
    single_multiplier sm1 (a1, b1, ready, ready, mul1_ack, clk, rst, mul1_out, mul1_stb, mul1_0ack, mul1_1ack);
    single_multiplier sm2 (a2, b3, ready, ready, mul2_ack, clk, rst, mul2_out, mul2_stb, mul2_0ack, mul2_1ack);
    single_multiplier sm3 (a1, b2, ready, ready, mul3_ack, clk, rst, mul3_out, mul3_stb, mul3_0ack, mul3_1ack);
    single_multiplier sm4 (a2, b4, ready, ready, mul4_ack, clk, rst, mul4_out, mul4_stb, mul4_0ack, mul4_1ack);
    single_multiplier sm5 (a3, b1, ready, ready, mul5_ack, clk, rst, mul5_out, mul5_stb, mul5_0ack, mul5_1ack);
    single_multiplier sm6 (a4, b3, ready, ready, mul6_ack, clk, rst, mul6_out, mul6_stb, mul6_0ack, mul6_1ack);
    single_multiplier sm7 (a3, b2, ready, ready, mul7_ack, clk, rst, mul7_out, mul7_stb, mul7_0ack, mul7_1ack);
    single_multiplier sm8 (a4, b4, ready, ready, mul8_ack, clk, rst, mul8_out, mul8_stb, mul8_0ack, mul8_1ack);
    
    reg addLoad1;
    reg addLoad2;
    reg addLoad3;
    reg addLoad4;
    
    reg addRes_ack1;
    reg addRes_ack2;
    reg addRes_ack3;
    reg addRes_ack4;
    
    wire [31:0] addOut1;
    wire [31:0] addOut2;
    wire [31:0] addOut3;
    wire [31:0] addOut4;
    
    wire addResReady1;
    wire addResReady2;
    wire addResReady3;
    wire addResReady4;
    
    adder add1 (clk, rst, addLoad1, mul1_out, mul2_out, addRes_ack1, addOut1, addResReady1);
    adder add2 (clk, rst, addLoad2, mul3_out, mul4_out, addRes_ack2, addOut2, addResReady2);
    adder add3 (clk, rst, addLoad3, mul5_out, mul6_out, addRes_ack3, addOut3, addResReady3);
    adder add4 (clk, rst, addLoad4, mul7_out, mul8_out, addRes_ack4, addOut4, addResReady4);
    
    reg calculating;
    
    always @ (posedge clk, negedge rst) begin
        if (~rst) begin
        
        end else begin
            if (start & ~calculating) begin
                calculating <= 1;
                
                a1 <= matrix1_0;
                a2 <= matrix1_1;
                a3 <= matrix1_2;
                a4 <= matrix1_3;
                b1 <= matrix2_0;
                b2 <= matrix2_1;
                b3 <= matrix2_2;
                b4 <= matrix2_3;
                
                ready <= 1;
            end
            if (out_ack & out_ready)
                calculating <= 0;
        end
    end
    
    always @ * begin
        addLoad1 = mul1_stb & mul2_stb;
        mul1_ack =addLoad1;
        mul2_ack =addLoad1;
        addLoad2 = mul3_stb & mul4_stb;
        mul3_ack =addLoad2;
        mul4_ack =addLoad2;
        addLoad3 = mul5_stb & mul6_stb;
        mul5_ack =addLoad3;
        mul6_ack =addLoad3;
        addLoad4 = mul7_stb & mul8_stb;
        mul7_ack =addLoad4;
        mul8_ack =addLoad4;
        
        outMatrix0 = addOut1;
        outMatrix1 = addOut2;
        outMatrix2 = addOut3;
        outMatrix3 = addOut4;
        
        out_ready = addResReady1 & addResReady2 & addResReady3 & addResReady4;
        
        addRes_ack1 = out_ack;
        addRes_ack2 = out_ack;
        addRes_ack3 = out_ack;
        addRes_ack4 = out_ack;
    end
    
endmodule
