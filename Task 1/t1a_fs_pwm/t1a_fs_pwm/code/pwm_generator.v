/*
# Team ID:           eYRC#1529
# Theme:             MazeSolver Bot
# Author List:       Goutham, Madhu Visagan
# Filename:          pwm_generator.v
# File Description:  This file describes the pwm generator block which scales 3125KHz down to 195KHz and generated pwm signal of it
# Global variables:  None
*/

module pwm_generator(
    input clk_3125KHz,
    input [3:0] duty_cycle,
    output reg clk_195KHz, pwm_signal
);

initial begin
    clk_195KHz = 0; pwm_signal = 1;
end
//////////////////DO NOT MAKE ANY CHANGES ABOVE THIS LINE //////////////////

reg [2:0] counter=0;    //counts the cycles depending on which the output signal toggles
reg [3:0] pwm_counter=0; // counts the cycles of the 3125KHz cycle for comparing with duty cycle

initial begin
        clk_195KHz = 0; pwm_signal = 1;
end

always @(posedge clk_3125KHz) begin
    if (!counter) clk_195KHz=~clk_195KHz;
    counter=counter+1'b1;
    if (pwm_counter<duty_cycle)
        pwm_signal=1;
    else
        pwm_signal=0;
    pwm_counter=pwm_counter+1'b1;
end
//////////////////DO NOT MAKE ANY CHANGES BELOW THIS LINE //////////////////

endmodule
