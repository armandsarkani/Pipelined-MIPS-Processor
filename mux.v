`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/16/2020 03:56:06 PM
// Design Name: 
// Module Name: mux
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


module mux2 #(parameter mux_width= 32)
(   input [mux_width-1:0] a,b,
    input sel,
    output [mux_width-1:0] y
    );
    
    assign y = sel ? b : a; // if select = 1 pick b, otherwise pick a (a = 0, b = 1)
endmodule
