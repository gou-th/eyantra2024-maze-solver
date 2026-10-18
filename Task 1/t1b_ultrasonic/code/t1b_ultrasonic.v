/*
# Team ID:          eYRC#1529
# Theme:            MazeSolver Bot
# Author List:      Hari Krishna 
# Filename:         t1b_ultrasonic.v
# File Description: HC-SR04 ultrasonic Sensor interface
# Global variables: None
*/

/*
Module HC_SR04 Ultrasonic Sensor

This module will detect objects present in front of the range, and give the distance in mm.

Input:  clk_50M - 50 MHz clock
        reset   - reset input signal (Use negative reset)
        echo_rx - receive echo from the sensor

Output: trig    - trigger sensor for the sensor
        op     -  output signal to indicate object is present.
        distance_out - distance in mm, if object is present.
*/

// module Declaration
module t1b_ultrasonic(
    input clk_50M, reset, echo_rx,
    output reg trig,
    output op,
    output wire [15:0] distance_out
);

initial begin
    trig = 0;
end
//////////////////DO NOT MAKE ANY CHANGES ABOVE THIS LINE //////////////////

reg internal_op;  //reg for op

reg [15:0] internal_distance_out;   //reg for distance_out

assign op=internal_op;
assign distance_out=internal_distance_out;


localparam IDLE=3'd0;  
localparam INITIAL_DELAY=3'd1;
localparam SEND_TRIG=3'd2;
localparam WAIT_ECHO_HIGH=3'd3;
localparam MEASURE_ECHO=3'd4;
localparam CALCULATE_DIST=3'd5;
localparam WAIT_12MS=3'd6;

reg [2:0] state, next_state;
reg echo_prev;  //prev echo signal 

//counters
reg [19:0] init_counter;
reg [19:0] trig_counter;
reg [19:0] wait12ms_counter;
reg [19:0] echo_counter;

reg wait12ms_active;

localparam COUNT_1US=20'd48;
localparam COUNT_10US=20'd499;
localparam COUNT_12MS=20'd600053;


wire echo_fall=(echo_prev==1'b1 && echo_rx==1'b0);  //edge detection of echo

initial begin
    init_counter=0;
    trig_counter=0;
    wait12ms_counter=0;
    echo_counter=0;
    echo_prev=0;
    wait12ms_active=0;
    internal_op=1;
    internal_distance_out=0;
end


always @(posedge clk_50M or negedge reset) begin  //used for changing state transitions and store echo prev 
    if(!reset) begin
        state<=IDLE;
        echo_prev<=1'b0;
    end else begin
        state<=next_state;
        echo_prev<=echo_rx;
    end
end

always @(*) begin  //FSM transitions based on state and ip
    next_state=state;
    if(echo_fall) begin
        next_state=CALCULATE_DIST;
    end else begin
        case(state)
            IDLE: next_state=INITIAL_DELAY;
            INITIAL_DELAY: if(init_counter>=COUNT_1US) next_state=SEND_TRIG;
            SEND_TRIG: if(trig_counter>=COUNT_10US) next_state=WAIT_ECHO_HIGH;
            WAIT_ECHO_HIGH: if(echo_rx==1'b1) next_state=MEASURE_ECHO;
            MEASURE_ECHO: if(echo_rx==1'b0) next_state=CALCULATE_DIST;
            CALCULATE_DIST: next_state=WAIT_12MS;
            WAIT_12MS: if(wait12ms_counter>=COUNT_12MS) next_state=SEND_TRIG;
            default: next_state=IDLE;
        endcase
    end
end

always @(posedge clk_50M or negedge reset) begin  //controls the different counters based on FSM
    if(!reset) begin
        init_counter<=0;
        trig_counter<=0;
        wait12ms_counter<=0;
        echo_counter<=0;
        wait12ms_active<=1'b0;
    end else begin
//initial delay counter
        if(state==INITIAL_DELAY)
            init_counter<=init_counter+1'b1;
        else
            init_counter<=0;
//trig counter				
        if(state==SEND_TRIG)
            trig_counter<=trig_counter+1'b1;
        else
            trig_counter<=0;

//12ms counter
        if(!wait12ms_active && (state==SEND_TRIG) && (trig_counter>=COUNT_10US))
            wait12ms_active<=1'b1;
        else if(wait12ms_counter>=COUNT_12MS)
            wait12ms_active<=1'b0;

        if(wait12ms_active)
            wait12ms_counter<=wait12ms_counter+1'b1;
        else
            wait12ms_counter<=0;

//echo counter
        if(state==MEASURE_ECHO)
            echo_counter<=echo_counter+1'b1;
        else if(next_state==CALCULATE_DIST)
            echo_counter<=echo_counter; // hold for calculation
        else
            echo_counter<=0;
    end
end

always @(posedge clk_50M or negedge reset) begin   //controls output signal and trig

    if(!reset) begin
        trig<=1'b0;
    end else begin
        if(state==SEND_TRIG)
            trig<=1'b1;
        else
            trig<=1'b0;
    end
end


always @(posedge clk_50M or negedge reset) begin  //calculates op distace and op(obstacle) based on its condition 

    if(!reset) begin
        internal_distance_out<=0;
        internal_op<=0;
    end
    else begin
//calculate distance_out
        if(next_state==CALCULATE_DIST) begin
            internal_distance_out[15:0]=((echo_counter*34)+5000)/10000-1;
            internal_op<=(internal_distance_out<16'd70);     
        end
    end
end

//////////////////DO NOT MAKE ANY CHANGES BELOW THIS LINE //////////////////

endmodule
