`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/16/2020 02:10:56 PM
// Design Name: 
// Module Name: mips_32
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

module mips_32(
    input clk, reset,  
    output[31:0] result
    );
    wire IF_Flush;
    wire Data_Hazard, mem_to_reg, mem_read, mem_write, alu_src, reg_write;
    wire id_ex_mem_to_reg, id_ex_mem_read, id_ex_mem_write, id_ex_alu_src, id_ex_reg_write;
    wire mem_wb_mem_to_reg, mem_wb_reg_write;
    wire ex_mem_mem_to_reg, ex_mem_mem_read, ex_mem_mem_write, ex_mem_reg_write;
    wire [1:0] alu_op, id_ex_alu_op, Forward_A, Forward_B;
    wire [31:0] reg1, reg2, imm_value, id_ex_reg1, id_ex_reg2, id_ex_imm_value;
    wire [9:0] branch_address, jump_address;
    wire [4:0] destination_reg, id_ex_destination_reg, ex_mem_destination_reg, mem_wb_destination_reg;
    wire [31:0] alu_in2_out, alu_result, ex_mem_alu_in2_out, ex_mem_alu_result;
    wire [31:0] write_back_data, mem_read_data, mem_wb_mem_read_data, mem_wb_alu_result;
    wire branch_taken, jump;
    wire [9:0] pc_plus4, if_id_pc_plus4;
    wire [31:0] instr, if_id_instr, id_ex_instr, ex_mem_instr;
    wire [41:0] if_id_reg_input, if_id_reg_output;
    wire [139:0] id_ex_reg_input, id_ex_reg_output;
    wire [104:0] ex_mem_reg_input, ex_mem_reg_output;
    wire [70:0] mem_wb_reg_input, mem_wb_reg_output;
    IF_pipe_stage IF
    (
        .clk(clk),
        .reset(reset),
        .en(Data_Hazard),
        .branch_address(branch_address),
        .jump_address(jump_address),
        .branch_taken(branch_taken),
        .jump(jump),
        .pc_plus4(pc_plus4),
        .instr(instr));
     assign if_id_reg_input = {pc_plus4, instr};
     pipe_reg_en #(.WIDTH(42)) IF_ID_reg
     (
        .clk(clk),
        .reset(reset),
        .en(Data_Hazard),
        .flush(IF_Flush),
        .d(if_id_reg_input),
        .q(if_id_reg_output));
     assign if_id_pc_plus4 = if_id_reg_output[41:32];
     assign if_id_instr = if_id_reg_output[31:0];
     ID_pipe_stage ID
     (
        .clk(clk),
        .reset(reset),
        .pc_plus4(if_id_pc_plus4),
        .instr(if_id_instr),
        .mem_wb_reg_write(mem_wb_reg_write),
        .mem_wb_write_reg_addr(mem_wb_destination_reg),
        .mem_wb_write_back_data(write_back_data),
        .Data_Hazard(Data_Hazard),
        .Control_Hazard(IF_Flush),
        .reg1(reg1),
        .reg2(reg2),
        .imm_value(imm_value),
        .branch_address(branch_address),
        .jump_address(jump_address),
        .branch_taken(branch_taken),
        .destination_reg(destination_reg),
        .mem_to_reg(mem_to_reg),
        .alu_op(alu_op),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .alu_src(alu_src),
        .reg_write(reg_write),
        .jump(jump));
     assign id_ex_reg_input = {if_id_instr, reg1, reg2, imm_value, destination_reg, mem_to_reg, alu_op, mem_read, mem_write, alu_src, reg_write};
     pipe_reg #(.WIDTH(140)) ID_EX_reg
     (
        .clk(clk),
        .reset(reset),
        .d(id_ex_reg_input),
        .q(id_ex_reg_output));
     assign id_ex_instr = id_ex_reg_output[139:108];
     assign id_ex_reg1 = id_ex_reg_output[107:76];
     assign id_ex_reg2 = id_ex_reg_output[75:44];
     assign id_ex_imm_value = id_ex_reg_output[43:12];
     assign id_ex_destination_reg = id_ex_reg_output[11:7];
     assign id_ex_mem_to_reg= id_ex_reg_output[6];
     assign id_ex_alu_op = id_ex_reg_output[5:4];
     assign id_ex_mem_read = id_ex_reg_output[3];
     assign id_ex_mem_write = id_ex_reg_output[2];
     assign id_ex_alu_src = id_ex_reg_output[1];
     assign id_ex_reg_write = id_ex_reg_output[0];
     Hazard_detection HDU
     (
        .id_ex_mem_read(id_ex_mem_read),
        .id_ex_destination_reg(id_ex_destination_reg),
        .if_id_rs(if_id_instr[25:21]),
        .if_id_rt(if_id_instr[20:16]),
        .branch_taken(branch_taken),
        .jump(jump),
        .Data_Hazard(Data_Hazard),
        .IF_Flush(IF_Flush));
     EX_pipe_stage EX
     (
        .id_ex_instr(id_ex_instr),
        .reg1(id_ex_reg1),
        .reg2(id_ex_reg2),
        .id_ex_imm_value(id_ex_imm_value),
        .ex_mem_alu_result(ex_mem_alu_result),
        .mem_wb_write_back_result(write_back_data),
        .id_ex_alu_src(id_ex_alu_src),
        .id_ex_alu_op(id_ex_alu_op),
        .Forward_A(Forward_A),
        .Forward_B(Forward_B),
        .alu_in2_out(alu_in2_out),
        .alu_result(alu_result));
     Forwarding_unit FWU
     (
        .ex_mem_reg_write(ex_mem_reg_write),
        .ex_mem_write_reg_addr(ex_mem_destination_reg),
        .id_ex_instr_rs(id_ex_instr[25:21]),
        .id_ex_instr_rt(id_ex_instr[20:16]),
        .mem_wb_reg_write(mem_wb_reg_write),
        .mem_wb_write_reg_addr(mem_wb_destination_reg),
        .Forward_A(Forward_A),
        .Forward_B(Forward_B));
     assign ex_mem_reg_input = {id_ex_instr, id_ex_destination_reg, alu_result, alu_in2_out, id_ex_mem_to_reg, id_ex_mem_read, id_ex_mem_write, id_ex_reg_write};
     pipe_reg #(.WIDTH(105)) EX_MEM_reg
     (
        .clk(clk),
        .reset(reset),
        .d(ex_mem_reg_input),
        .q(ex_mem_reg_output));
     assign ex_mem_instr = ex_mem_reg_output[104:73];
     assign ex_mem_destination_reg = ex_mem_reg_output[72:68];
     assign ex_mem_alu_result = ex_mem_reg_output[67:36];
     assign ex_mem_alu_in2_out = ex_mem_reg_output[35:4];
     assign ex_mem_mem_to_reg = ex_mem_reg_output[3];
     assign ex_mem_mem_read = ex_mem_reg_output[2];
     assign ex_mem_mem_write = ex_mem_reg_output[1];
     assign ex_mem_reg_write = ex_mem_reg_output[0];
     data_memory data_mem
     (
        .clk(clk),
        .mem_access_addr(ex_mem_alu_result),
        .mem_write_data(ex_mem_alu_in2_out),
        .mem_write_en(ex_mem_mem_write),
        .mem_read_en(ex_mem_mem_read),
        .mem_read_data(mem_read_data));
     assign mem_wb_reg_input = {ex_mem_alu_result, mem_read_data, ex_mem_mem_to_reg, ex_mem_reg_write, ex_mem_destination_reg};
     pipe_reg #(.WIDTH(71)) MEM_WB_reg
     (
        .clk(clk),
        .reset(reset),
        .d(mem_wb_reg_input),
        .q(mem_wb_reg_output)); 
     assign mem_wb_alu_result = mem_wb_reg_output[70:39];
     assign mem_wb_mem_read_data = mem_wb_reg_output[38:7];
     assign mem_wb_mem_to_reg = mem_wb_reg_output[6];
     assign mem_wb_reg_write = mem_wb_reg_output[5];
     assign mem_wb_destination_reg = mem_wb_reg_output[4:0];
     mux2 #(.mux_width(32)) WB 
     (     
        .a(mem_wb_alu_result), 
        .b(mem_wb_mem_read_data), 
        .sel(mem_wb_mem_to_reg),
        .y(write_back_data)); 
     assign result = write_back_data;
     
endmodule
