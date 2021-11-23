`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/18/2020 11:05:13 AM
// Design Name: 
// Module Name: mux4
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


module mux4 #(parameter mux_width= 32)
(   input [mux_width-1:0] a,b,c,d,
    input [1:0] sel,
    output [mux_width-1:0] y
    );
    assign y = sel[1] ? (sel[0] ? d : c) : (sel[0] ? b : a);  // 11 = d, 10 = c, 01 = b, 00 = a
endmodule
