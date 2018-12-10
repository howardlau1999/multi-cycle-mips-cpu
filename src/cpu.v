`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/06/2018 02:42:16 PM
// Design Name: 
// Module Name: cpu
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


module cpu(
    input wire clk, rst,
    output wire bg_wrt,
    output wire [12:0] bam_addr,
    output wire [7:0] bam_write_data,
    input  wire dbg_clk,
    
    output reg  [31:0] pc, next_pc, 
    input  wire [31:0] led_read,
    output wire [31:0] led_reg_data, led_rs, led_rt, led_alurslt, led_db
    );
    wire  [31:0] pc4;
    wire [31:0] inst, mem_inst;
    reg         pcsrc;
    wire [31:0] baddr, jaddr;
    wire        irwrite;
    wire        jump, jump_link, jump_register;
    
    wire [5:0]  opcode;
    wire [4:0]  rs;
    wire [4:0]  rt;
    wire [4:0]  rd;
    wire [5:0]  funct;
    wire [15:0] imm;
    wire [4:0]  shamt;
    wire [31:0] seimm, zeimm, alimm;  // sign extended immediate
    
    wire [31:0] rs_data, rt_data;
    wire        regdst;
    wire        branch_eq;
    wire        branch_ne;
    wire        branch_ltz;
    wire        halt;
    wire        memread;
    wire        memwrite;
    wire        memtoreg;
    wire [1:0]  aluop;
    wire        regwrite;
    wire        alusrc_a, alusrc_b, extsel;
    wire [4:0]  wrreg;
    wire [31:0] wrdata;
    
    wire [4:0]  dbg_reg;
    wire [31:0] dbg_reg_data;
    
    wire [31:0]  dbg_ram_addr;
    wire [31:0] dbg_ram_data;
    
    wire pcwre;
    assign pcwre = !halt;
    initial begin
        pc = 0;
    end
    assign pc4 = pc + 4;
    always @ * begin
        if (halt) assign next_pc = pc; 
        else if (jump && jump_register) assign next_pc = rs_data;
        else if (jump) assign next_pc = jaddr;
        else if (pcsrc) assign next_pc = baddr;
        else assign next_pc = pc4;
    end
    always @ (posedge clk) begin
        if (rst) begin
            pc <= 0;   
        end 
        else if (pcwre) begin
            pc <= next_pc;
        end
        else begin
            pc <= pc;
        end
    end
    // Buffers
    IR ir(.clk(clk), .irwrite(irwrite), .inst(mem_inst), .inst_out(inst));
   
   // IF
    inst_mem im(pc, mem_inst);
   // ID
    assign opcode   = inst[31:26];
    assign rs       = inst[25:21];
    assign rt       = inst[20:16];
    assign rd       = inst[15:11];
    assign imm      = inst[15:0];
    assign shamt    = inst[10:6];
    assign funct    = inst[5:0];
    assign jaddr    = {pc[31:28], inst[25:0], {2{1'b0}}};
    assign seimm    = {{16{inst[15]}}, inst[15:0]};
    assign zeimm    = {16'd0, inst[15:0]};
    // branch address
    assign baddr = pc4 + (seimm << 2);
  
    reg_file regs(.clk(clk), .rst(rst),
                  .read1(rs), .read2(rt), .data1(rs_data), .data2(rt_data), 
                  .dbg_read(dbg_reg), .dbg_data(dbg_reg_data), .led_read(led_read), .led_data(led_reg_data),
                  .regwrite(regwrite), .wrreg(wrreg), .wrdata(wrdata));
                  
    cpu_control control(.clk(clk), .rst(rst), .opcode(opcode), .regdst(regdst),
                .branch_eq(branch_eq), .branch_ne(branch_ne), .branch_ltz(branch_ltz),
                .halt(halt),.memread(memread),.memtoreg(memtoreg), .irwrite(irwrite), .aluop(aluop), .extsel(extsel),
                .memwrite(memwrite), .alusrc_a(alusrc_a), .alusrc_b(alusrc_b),
                .regwrite(regwrite), .jump(jump), .jump_link(jump_link), .jump_register(jump_register));
    // EX
    wire [31:0] alu_data1, alu_data2, data1, data2;
    assign alu_data1 = (alusrc_a) ? shamt : rs_data;
    assign alimm = (extsel ? seimm : imm);
    assign alu_data2 = (alusrc_b) ?  alimm : rt_data;
    // Buffers
    DR adr(.clk(clk), .data_in(alu_data1), .data_out(data1));
    DR bdr(.clk(clk), .data_in(alu_data2), .data_out(data2));
    // ALU control
    wire [3:0] aluctl;
    ALU_control alu_ctl(.opcode(opcode), .funct(funct), .aluop(aluop), .aluctl(aluctl));
    // ALU
    wire [31:0]    alurslt;
    wire           zero;
    ALU alu(.control(aluctl), .a(data1), .b(data2), .rslt(alurslt), .zero(zero));
   
    // MEM
    wire [5:0] wrreg_sel;
    assign wrreg_sel = (regdst) ? rd : rt;
    assign wrreg = jump_link ? 5'd31 : wrreg_sel;
    wire [31:0] rdata;
    data_mem dm(.clk(clk), .rst(rst), .addr(alurslt), .rd(memread), .wr(memwrite),
            .wdata(rt_data), .rdata(rdata), .dbg_ram_addr(dbg_ram_addr), .dbg_ram_data(dbg_ram_data));
            
    always @(*) begin
        pcsrc = (branch_eq & zero) | (branch_ne & ~zero) | (branch_ltz & ~zero);
    end
    
    // WB
    wire [31:0] wrdata_buf, wrdata_sel;
    assign wrdata_sel = memtoreg ? rdata : alurslt;
    DR dbdr(.clk(clk), .data_in(wrdata_sel), .data_out(wrdata_buf));
    assign wrdata = jump_link ? pc4 : wrdata_buf;
    // debug
    
    assign led_rs = rs;
    assign led_rt = rt;
    assign led_alurslt = alurslt;
    assign led_db = wrdata;
    debug_screen debug_screen(.clk(dbg_clk), .pc(pc), .reg_data(dbg_reg_data), .reg_addr(dbg_reg), .ram_data(dbg_ram_data), .ram_addr(dbg_ram_addr),
            .inst(inst), .rs(rs), .rt(rt), .rd(rd), .imm(imm), .shamt(shamt), .funct(funct), .alurslt(alurslt),
            .bg_wrt(bg_wrt), .bam_addr(bam_addr), .bam_write_data(bam_write_data));    
endmodule
