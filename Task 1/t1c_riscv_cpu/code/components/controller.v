/*
# Team ID:          eYRC#1529
# Theme:            MazeSolver Bot
# Author List:      Jeevith, Goutham
# Filename:         controller.v
# File Description: Main controll connecting decoders and cpu
# Global variables: None
*/
// controller.v - controller for RISC-V CPU

module controller (
    input [6:0]  op,
    input [2:0]  funct3,
    input        funct7b5,
    input        Zero, ALUR31,
    input        unsigned_less_than,
    output       [1:0] ResultSrc,
    output       MemWrite,
    output       PCSrc, ALUSrc,
    output       RegWrite, Jump, Jalr,
    output [1:0] ImmSrc,
    output [3:0] ALUControl
);

wire [1:0] ALUOp;
wire       Branch;

main_decoder    md (op, funct3, Zero, ALUR31,unsigned_less_than, ResultSrc, MemWrite, Branch,
                    ALUSrc, RegWrite, Jump, Jalr, ImmSrc, ALUOp);

alu_decoder     ad (op[5], funct3, funct7b5, ALUOp, ALUControl);

assign PCSrc = Branch| Jump;

endmodule

