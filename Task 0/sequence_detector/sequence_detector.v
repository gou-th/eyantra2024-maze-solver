// Verilog code for Sequence Detector
    // Define Sequence Detector module
    module sequence_detector (
        input clock,
        input [3:0] number, // Define input ports clock, number
        output reg pattern // Define output port patter
    );


	 //////////////////////////////////////////////
    // Define your State Machine Parameters Here
    parameter ST_ONE = 0,ST_ZERO=1,ST_NINE=2,ST_FOUR=3;
	 //////////////////////////////////////////////

    // defining 2-bit register
    reg [1:0] state = ST_ONE;

    initial begin // define initial state output register
        pattern = 0;
    end

    always @(posedge clock) begin
        pattern = 0;
        case (state)
			   ///////////////////////////////////////
				// Do not modify above part of the code
            // Write your state machine here
				ST_ONE: begin
					// you can read input inside always block like this
					 if (number == 1) state=ST_ZERO;
					 else state=ST_ONE;
					end
				ST_ZERO:begin
				if (number==0) state=ST_NINE;
				else state=ST_ONE;
				end
				ST_NINE:begin
				if (number==9) state=ST_FOUR;
				else state=ST_ONE;
				end
				ST_FOUR:begin
				if (number==4) begin  
				state=ST_ONE;
					pattern = 1;// you can assign output values for a register like this.
					 end
					 else
			       state = ST_ONE; // write your own logic here
					 // Do not modify below part of the code
					 ///////////////////////////////////////
				end
				default:state=ST_ONE;
        endcase
    end

    endmodule