`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/11/2021 10:22:32 AM
// Design Name: 
// Module Name: matrix_multiplier
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


module matrix_multiplier #(parameter n = 5, s = (2 * n) + 2, r = 3 * (2 ** (2 * n))) (
    input clk,
    input rst,
    input [31:0] ramOut,
    output reg [s - 1:0] ramAddress,
    output reg [31:0] ramIn,
    output reg ramWrite
    );
    
    reg [31:0] conf;
    reg [31:0] status;
    reg [2:0] state;
    reg [31:0] matrix1 [2 ** n - 1 : 0][2 ** n - 1 : 0];
    reg [31:0] matrix2 [2 ** n - 1 : 0][2 ** n - 1 : 0];
    reg [31:0] matrixRes [2 ** n - 1 : 0][2 ** n - 1 : 0];
    reg statusUpdate;
    reg [n - 1:0] counterr;
    reg [n - 1:0] counterc;
    integer i; 
    integer j;
    integer k; 
    reg [n - 1:0] counter1;
    reg [n - 1:0] counter2;
    reg [n - 1:0] counter3;
    reg outmul;
    
    reg regadder01;
    reg regadder11;
    reg regadder21;
    reg regadder31;
    reg adderack0;
    reg adderack1;
    reg adderack2;
    reg adderack3;
    
    reg adderLoad0;
    reg adderLoad1;
    reg adderLoad2;
    reg adderLoad3;
    
    reg regadder02;
    reg regadder12;
    reg regadder22;
    reg regadder32;
    reg regadder0Out;
    reg regadder1Out;
    reg regadder2Out;
    reg regadder3Out;
    
    reg adderfinish0;
    reg adderfinish1;
    reg adderfinish2;
    reg adderfinish3;
    
    reg bmmIn1_0;
    reg bmmIn1_1;
    reg bmmIn1_2;
    reg bmmIn1_3;
    reg bmmIn2_0;
    reg bmmIn2_1;
    reg bmmIn2_2;
    reg bmmIn2_3;
    
    wire bmmOut0;
    wire bmmOut1;
    wire bmmOut2;
    wire bmmOut3;

    reg bmmStart;
    reg bmmAck;
    wire bmmFinished;
    
    base_matrix_multiplier BMM(clk, rst, bmmStart, bmmAck, bmmIn1_0, bmmIn1_1, bmmIn1_2, bmmIn1_3, bmmIn2_0, bmmIn2_1, bmmIn2_2, bmmIn2_3,
                                bmmOut0, bmmOut1, bmmOut2, bmmOut3, bmmFinished);
    adder Add1(clk, rst, adderLoad0, regadder01, regadder02, adderack0, regadder0Out, adderfinish0);
    adder Add2(clk, rst, adderLoad1, regadder11, regadder12, adderack1, regadder1Out, adderfinish1);
    adder Add3(clk, rst, adderLoad2, regadder21, regadder22, adderack2, regadder2Out, adderfinish2);
    adder Add4(clk, rst, adderLoad3, regadder31, regadder32, adderack3, regadder3Out, adderfinish3);
    
    wire bound1;
    wire bound2;
    wire bound3;
    
    assign bound1 = (conf[22]) ? (conf[31:22] + 1) : conf[31:22];
    assign bound2 = (conf[2]) ? (conf[11:2] + 1) : conf[11:2];
    assign bound3 = (conf[12]) ? (conf[21:12] + 1) : conf[21:12];
   
    reg [s - 1 :0] lastAddress;
    
    reg calculating1;
    reg calculating2;    
    always @ (posedge clk, negedge rst) begin
        if (~rst) begin
            statusUpdate <= 0;
            status <= 0;
            ramAddress <= 0;
            calculating1 <= 0;
            calculating2 <= 0;
            adderack0 <= 0;
            adderack1 <= 0;
            adderack2 <= 0;
            adderack3 <= 0;
            bmmAck <= 0;
        end
        case (state)
            0: begin     
                if(!statusUpdate) begin                 // waiting
                    state <= 0;
                    if (ramOut[31]) begin
                        statusUpdate <= 1;
                        ramAddress <= 1;
                        status <= ramOut; 
                        status[5] <= 1;
                    end else begin
                        ramAddress <= 1;
                    end
                end else begin                          // update status
                    state <= 1;
                    ramIn <= status;
                    ramWrite <= 1;
                    ramAddress <= 1;
                    statusUpdate <= 0;
                end
            end
            
            1: begin                                    // get conf
                if(!statusUpdate) begin
                    state <= 1;
                    ramAddress <= 0;
                    statusUpdate <= 1;
                    status[4] <= 1;
                    ramWrite <= 0;
                end else begin
                    conf <= ramOut;
                    state <= 2;
                    ramIn <= status;
                    ramWrite <= 1;
                    ramAddress <= 1;
                    statusUpdate <= 0;
                end
                for (i = 0; i < n; i = i + 1) begin
                    for (j = 0; j < n; j = j + 1) begin
                        matrixRes[i][j] <= 0;
                    end
                end
            end
            
            2:begin                                    // get first matrix
                if(!statusUpdate) begin
                    state <= 2;
                    ramAddress <= 2;
                    statusUpdate <= 1;
                    status[3] <= 1;
                    ramWrite <= 0;
                    counterr <= 0;
                    counterc <= 0;
                end else begin
                    ramAddress <= ramAddress + 1;
                    if(counterr != conf[31 : 22])begin
                        if(counterc != conf[21 : 12])begin
                            matrix1[counterr][counterc] <= ramOut;      
                            counterc <= counterc + 1;
                            if (counterc == conf[21 : 12] - 1) begin
                                counterc <= 0;
                                counterr <= counterr + 1;
                            end
                        end
                    end else begin
                        state <= 3;
                        ramIn <= status;
                        ramWrite <= 1;
                        ramAddress <= 1;
                        lastAddress <= ramAddress;
                        statusUpdate <= 0;
                    end
                end
            end
            
            3:begin
                if(!statusUpdate) begin
                    state <= 3;
                    statusUpdate <= 1;
                    ramAddress <= lastAddress;
                    status[2] <= 1;
                    ramWrite <= 0;
                    counterr <= 0;
                    counterc <= 0;
                end else begin
                ramAddress <= ramAddress + 1;
                    if(counterr != conf[21 : 12])begin 
                        if(counterc != conf[11 : 2])begin
                            matrix2[counterr][counterc] <= ramOut;      
                            counterc <= counterc + 1;
                            if (counterc == conf[11 : 2] - 1) begin
                                counterc <= 0;
                                counterr <= counterr + 1;
                            end
                        end
                    end else begin
                        state <= 4;
                        ramIn <= status;
                        ramWrite <= 1;
                        ramAddress <= 1;
                        statusUpdate <= 0;
                        counter1 <= 0;
                        counter2 <= 0;
                        counter3 <= 0;
                    end
                end
            end
            
            4: begin
                ramWrite <= 0;
                state <= 4;
                if (~statusUpdate) begin
                    if (~calculating1 & ~calculating2) begin
                        if(bmmAck == 0 | adderack0 == 0 | adderack1 == 0 | adderack2 == 0 | adderack3 == 0) begin
                        
                        bmmAck <= 1;
                        adderack0 <= 1;
                        adderack1 <= 1;
                        adderack2 <= 1;
                        adderack3 <= 1;
                        
                        end else begin
                            if(counter1 != bound1) begin 
                                if(counter2 != bound2) begin 
                                    counter3 <= counter3 + 2;
                                    if(counter3 < bound3) begin
                                        bmmIn1_0 <= matrix1[counter1][counter3];
                                        bmmIn1_1 <= matrix1[counter1][counter3 + 1];
                                        bmmIn1_2 <= matrix1[counter1 + 1][counter3];
                                        bmmIn1_3 <= matrix1[counter1 + 1][counter3 + 1];
                                        bmmIn2_0 <= matrix1[counter3][counter2];
                                        bmmIn2_1 <= matrix1[counter3][counter2 + 1];
                                        bmmIn2_2 <= matrix1[counter3 + 1][counter2];
                                        bmmIn2_3 <= matrix1[counter3 + 1][counter2 + 1];
                                        
                                        bmmAck <= 0;
                                        bmmStart <= 1;
                                        
                                        calculating1 <= 1;
                                    end
                                    if ((counter3 > 0) & (counter3 < bound3 + 2)) begin
                                        regadder01 <= bmmOut0;
                                        regadder11 <= bmmOut1;
                                        regadder21 <= bmmOut2;
                                        regadder31 <= bmmOut3;
                                        
                                        regadder02 <= matrixRes[counter1][counter2];
                                        regadder12 <= matrixRes[counter1][counter2 + 1];
                                        regadder22 <= matrixRes[counter1 + 1][counter2];
                                        regadder32 <= matrixRes[counter1 + 1][counter2 + 1];
                                        
                                        adderLoad0 <= 1;
                                        adderLoad1 <= 1;
                                        adderLoad2 <= 1;
                                        adderLoad3 <= 1;
                                        
                                        adderack0 <= 0;
                                        adderack1 <= 0;
                                        adderack2 <= 0;
                                        adderack3 <= 0;
                                        
                                        calculating2 <= 1;
                                    end
                                    if ((counter3 > 2) & (counter3 < bound3 + 4)) begin
                                        matrixRes[counter1][counter2] <= regadder0Out;
                                        matrixRes[counter1][counter2 + 1] <= regadder1Out;
                                        matrixRes[counter1 + 1][counter2] <= regadder2Out;
                                        matrixRes[counter1 + 1][counter2 + 1] <= regadder3Out;
                                    end                                    
                                    if (counter3 == bound3 + 4) begin
                                        counter3 <= 0;
                                        counter2 <= counter2 + 2;
                                    end
                                end
                                if (counter2 == bound2 - 2) begin
                                    counter2 <= 0;
                                    counter1 <= counter1 + 2;
                                end
                            end
                        end
                    end else begin
                        if (calculating1) begin
                            if (bmmFinished) begin
                                calculating1 <= 0;
                            end
                        end
                        if (calculating2) begin
                            if(adderfinish0 & adderfinish1 & adderfinish2 & adderfinish3)begin
                                calculating2 <= 0;
                            end
                        end
                    end
                    if (counter1 == bound1) begin
                        state <= 4;
                        statusUpdate <= 1;
                        status[1] <= 1;
                        ramWrite <= 0;
                    end
                end else begin
                    state <= 5;
                    ramIn <= status;
                    ramWrite <= 1;
                    ramAddress <= 1;
                    statusUpdate <= 0;
                end
            end
            
            5: begin
                if(!statusUpdate) begin
                    state <= 5;
                    statusUpdate <= 1;
                    ramAddress <= r - 1;
                    status[0] <= 1;
                    ramWrite <= 0;
                    counterr <= 0;
                    counterc <= 0;
                end else begin
                ramAddress <= ramAddress + 1;
                ramWrite <= 1;
                    if(counterr != conf[31 : 22])begin 
                        if(counterc != conf[11 : 2])begin
                            ramIn <= matrixRes[counterr][counterc];      
                            counterc <= counterc + 1;
                            if (counterc == conf[11 : 2] - 1) begin
                                counterc <= 0;
                                counterr <= counterr + 1;
                            end
                        end
                    end else begin
                        state <= 6;
                        ramIn <= status;
                        ramWrite <= 1;
                        ramAddress <= 1;
                        statusUpdate <= 0;
                        counter1 <= 0;
                        counter2 <= 0;
                    end
                end
            end
        endcase
    end
    
endmodule
