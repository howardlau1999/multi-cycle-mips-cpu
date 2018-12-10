`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/05/21 09:26:45
// Design Name: 
// Module Name: IR
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


module IR(
    input clk, irwrite,
    input [31:0] inst,
    output reg [31:0] inst_out
    );
    
    //reg [31:0] InsReg;
    initial begin
    inst_out <= 0;
    end
    // ÒªÇóÉÏÉýÑØ£¿£¿£¿
    always @(posedge clk) begin
        if (irwrite) begin
            inst_out <= inst;
        end
    end

endmodule
