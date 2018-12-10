`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/05/21 09:37:10
// Design Name: 
// Module Name: DR
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


module DR(
    input clk,
    input [31:0] data_in,
    output reg [31:0] data_out
    );
    
    reg [31:0] data_reg;
    initial begin
    data_out <= 0;
    end
    always @(posedge clk) begin
        // Read at posedge
        data_out <= data_reg;
    end
    
    always @(negedge clk) begin
        // Write at negedge
        data_reg <= data_in;
    end
endmodule
