`timescale 1ns / 1ps
module state_control(
input wire [2:0] state,
input wire [5:0] opcode,
output reg [2:0] next_state
    );
    always @ * begin
            if (state == 3'b000) begin
                assign next_state = 3'b001;
            end
        
            if (state == 3'b001) begin
                // beq, bne, bltz
                if (opcode == 6'b110100 || opcode == 6'b110101 || opcode == 6'b110110) assign next_state = 3'b101;
                // sw, lw
                else if (opcode == 6'b110000 || opcode == 6'b110001) assign next_state = 3'b010;
                // j, jal, jr, halt
                else if (opcode == 6'b111000 || opcode == 6'b111010 || opcode == 6'b111001 || opcode == 6'b111111) assign next_state = 3'b000;
                else assign next_state = 3'b110;
            end
            
            if (state == 3'b110) assign next_state = 3'b111;
            if (state == 3'b101) assign next_state = 3'b000;
            if (state == 3'b010) assign next_state = 3'b011;
            if (state == 3'b011) begin
                if (opcode == 6'b110000) assign next_state = 3'b000;
                else assign next_state = 3'b100;
            end
            
            if (state == 3'b100) assign next_state = 3'b000;
            if (state == 3'b111) assign next_state = 3'b000;
        end
    
endmodule
