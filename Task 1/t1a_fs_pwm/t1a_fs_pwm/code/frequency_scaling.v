/*
# Team ID:           eYRC#1529
# Theme:             MazeSolver Bot 
# Author List:       Goutham, Madhu Visagan
# Filename:          frequency_scaling.v
# File Description:  This file describes the frequency scaling block which scales 50MHz down to 3125KHz
# Global variables:  None
*/

module frequency_scaling (
    input clk_50M,
    output reg clk_3125KHz
);

initial begin
    clk_3125KHz = 0;
end
//////////////////DO NOT MAKE ANY CHANGES ABOVE THIS LINE //////////////////

reg [2:0] counter=0;  //counts the cycles depending on which the output signal toggles

always @(posedge clk_50M) begin  // Check if the counter has reached its final value so that it resets on the 8th cycle and toggles the output signal
    if (!counter)clk_3125KHz=~clk_3125KHz; 
    counter=counter+1'b1;
end

//////////////////DO NOT MAKE ANY CHANGES BELOW THIS LINE //////////////////

endmodule
