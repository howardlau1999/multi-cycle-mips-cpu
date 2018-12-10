`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/06/2018 02:47:57 PM
// Design Name: 
// Module Name: inst_mem
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


module inst_mem # (
    parameter ENTRIES = 128,
	parameter CODE_DATA = "C:/Users/Liuhaohua/Desktop/project_2/test_multi_cycle.txt"
)
(
		input wire 	[31:0] 	addr,
		output reg [31:0] 	data);

	reg [7:0] mem [0:ENTRIES - 1];
	initial begin
		$readmemb(CODE_DATA, mem);
		data = 32'bz;
	end
	always @ (addr) begin
	 data[31:24] <= mem[addr];
	 data[23:16] <= mem[addr + 1];
	 data[15:8]  <= mem[addr + 2];
	 data[7:0]   <= mem[addr + 3];
	end
endmodule
