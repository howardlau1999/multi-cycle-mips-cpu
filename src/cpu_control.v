`timescale 1ns / 1ps
module cpu_control(
        input  wire         clk, rst,
        input  wire [5:0]	opcode,
		output reg			branch_eq, branch_ne, branch_ltz, halt,
		output reg [1:0]	aluop,
		output reg			memread, memwrite, memtoreg, irwrite,
		output reg			regdst, regwrite, alusrc_a, alusrc_b, extsel,
		output reg			jump, jump_link, jump_register
    );
    wire [2:0] next_state;
    reg  [2:0] state;
    state_control state_ctrl(.state(state), .opcode(opcode), .next_state(next_state));
    always @ (posedge clk) begin
        if (rst) state <= 3'b000;
        else state <= next_state;
    end
	always @ (*) begin
		aluop[1:0]	<= 2'b10;
		alusrc_a		<= 1'b0;
		alusrc_b		<= 1'b0;
		branch_eq	<= 1'b0;
		branch_ne	<= 1'b0;
		branch_ltz  <= 1'b0;
		memread		<= 1'b0;
		memtoreg	<= 1'b0;
		memwrite	<= 1'b0;
		regdst		<= 1'b1;
		regwrite	<= (state == 3'b111 || state == 3'b100) ? 1'b1 : 1'b0;
		jump		<= 1'b0;
        jump_link   <= 1'b0;
        jump_register <= 1'b0;
		halt        <= next_state != 3'b000;
        extsel      <= 1'b1;
        irwrite     <= state == 3'b000;
		case (opcode)
		    6'b010001: begin      /* andi */
		        extsel <= 0;
		        regdst   <= 1'b0;
		        alusrc_b   <= 1'b1;
		    end
            6'b010011: begin      /* xori */
                extsel <= 0;
                regdst   <= 1'b0;
                alusrc_b   <= 1'b1;
            end
            6'b010010: begin    /* ori */
                extsel <= 0;  
                regdst   <= 1'b0; 
                alusrc_b   <= 1'b1;
            end
			6'b110001: begin	/* lw */
				memread  <= 1'b1;
				regdst   <= 1'b0;
				memtoreg <= 1'b1;
				aluop[1] <= 1'b0;
				alusrc_b   <= 1'b1;
			end
            6'b110000: begin  /* sw */
                memwrite <= state == 3'b011;
                aluop[1] <= 1'b0;
                alusrc_b   <= 1'b1;
            end
			6'b000010: begin	/* addiu */
				regdst   <= 1'b0;
				aluop[1] <= 1'b0;
				alusrc_b   <= 1'b1;
			end
			6'b011000: begin	/* sll */
                alusrc_a   <= 1'b1;
            end
			6'b110100: begin	/* beq */
				aluop[0]  <= 1'b1;
				aluop[1]  <= 1'b0;
				branch_eq <= 1'b1;
			end
			6'b110101: begin	/* bne */
				aluop[0]  <= 1'b1;
				aluop[1]  <= 1'b0;
				branch_ne <= 1'b1;
			end
			6'b110110: begin	/* bltz */
                branch_ltz <= 1'b1;
            end
            6'b100110: begin	/* slti */
                alusrc_b   <= 1'b1;
                regdst  <= 1'b0;
            end
			6'b111000: begin	/* j */
				jump <= 1'b1;
			end
            6'b111001: begin    /* jr */
                jump <= 1'b1;
                jump_register <= 1'b1;
            end
            6'b111010: begin    /* jal */
                jump <= 1'b1;
                jump_link <= 1'b1;
                regwrite <= state == 3'b001;
            end
			6'b111111: begin	/* halt */
                halt <= 1'b1;
            end
		endcase
	end
endmodule
