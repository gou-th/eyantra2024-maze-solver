// Task 2C - MazeSolver Bot

module t2c_maze_explorer (
    input clk,
    input rst_n,
    input left, mid, right, // 0 - no wall, 1 - wall
    output reg [2:0] move
);

/*

| cmd | move  | meaning   |
|-----|-------|-----------|
| 000 | 0     | STOP      |
| 001 | 1     | FORWARD   |
| 010 | 2     | LEFT      |
| 011 | 3     | RIGHT     | 
| 100 | 4     | U_TURN    |

START POS   : 4,0
EXIT POS    : 4,8
DEADENDS    : 9

*/
//////////////////DO NOT MAKE ANY CHANGES ABOVE THIS LINE //////////////////
//========================================================
// Parameters
//========================================================
localparam NROWS=9, NCOLS=9;
localparam N_H=72, N_V=72;

localparam DIR_N=2'b00,
           DIR_E=2'b01,
           DIR_S=2'b10,
           DIR_W=2'b11;

localparam M_STOP = 3'b000,
           M_FWD  = 3'b001,
           M_LEFT = 3'b010,
           M_RIGHT= 3'b011,
           M_UTURN= 3'b100;

localparam EM_UNVIS=2'b00,
           EM_ONCE =2'b01,
           EM_TWICE=2'b10,
           EM_BLOCK=2'b11;

//========================================================
// State Registers
//========================================================
reg [3:0] row, col;
reg [1:0] dir;

reg [1:0] H_edge [0:N_H-1];
reg [1:0] V_edge [0:N_V-1];

reg s_left_s1, s_mid_s1, s_right_s1;

reg [1:0] chosen_dir_s1;
reg [1:0] chosen_dir_s2;

reg done;

integer i;

// locals
reg unv_r, oncev_r;
reg [1:0] cand_un_r, cand_once_r;
reg [1:0] absL_r, absS_r, absR_r, absB_r;

reg [1:0] final_dir_r;
reg ok_r;
integer k_r;
reg [1:0] try_dirs_r [0:3];

reg [1:0] chosen_dir_next;

//========================================================
// EXACT Testbench Rotation Mapping
//========================================================
function [1:0] rel_to_abs;
    input [1:0] cur;
    input [1:0] rel;
begin
    case(cur)
        DIR_N: case(rel)
                0: rel_to_abs=DIR_N;
                1: rel_to_abs=DIR_E;
                2: rel_to_abs=DIR_S;
                3: rel_to_abs=DIR_W;
              endcase
        DIR_E: case(rel)
                0: rel_to_abs=DIR_E;
                1: rel_to_abs=DIR_S;
                2: rel_to_abs=DIR_W;
                3: rel_to_abs=DIR_N;
              endcase
        DIR_S: case(rel)
                0: rel_to_abs=DIR_S;
                1: rel_to_abs=DIR_W;
                2: rel_to_abs=DIR_N;
                3: rel_to_abs=DIR_E;
              endcase
        DIR_W: case(rel)
                0: rel_to_abs=DIR_W;
                1: rel_to_abs=DIR_N;
                2: rel_to_abs=DIR_E;
                3: rel_to_abs=DIR_S;
              endcase
    endcase
end
endfunction

//========================================================
// Edge access helpers
//========================================================
function [1:0] get_edge_mark;
    input [3:0] r,c;
    input [1:0] ad;
    integer idx;
begin
    case(ad)
        DIR_N: get_edge_mark = (r==0)?EM_BLOCK : V_edge[(r-1)*9 + c];
        DIR_S: get_edge_mark = (r==8)?EM_BLOCK : V_edge[r*9 + c];
        DIR_E: get_edge_mark = (c==8)?EM_BLOCK : H_edge[r*8 + c];
        DIR_W: get_edge_mark = (c==0)?EM_BLOCK : H_edge[r*8 + (c-1)];
        default: get_edge_mark=EM_BLOCK;
    endcase
end
endfunction

function is_free_s1;
    input [1:0] ad;
    reg [1:0] rel;
begin
    if(ad==rel_to_abs(dir,3))      rel=3;
    else if(ad==rel_to_abs(dir,0)) rel=0;
    else if(ad==rel_to_abs(dir,1)) rel=1;
    else                            rel=2;

    if(get_edge_mark(row,col,ad)==EM_BLOCK)
        is_free_s1=0;
    else begin
        case(rel)
            3: is_free_s1 = (s_left_s1==0);
            0: is_free_s1 = (s_mid_s1==0);
            1: is_free_s1 = (s_right_s1==0);
            2: is_free_s1 = 1;
        endcase
    end
end
endfunction

task inc_edge_mark;
    input [3:0] r,c;
    input [1:0] ad;
    integer idx;
    reg [1:0] cur;
begin
    case(ad)
        DIR_N: if(r!=0) begin
            idx=(r-1)*9+c; cur=V_edge[idx];
            if(cur==EM_UNVIS) V_edge[idx]<=EM_ONCE;
            else if(cur==EM_ONCE) V_edge[idx]<=EM_TWICE;
        end
        DIR_S: if(r!=8) begin
            idx=r*9+c; cur=V_edge[idx];
            if(cur==EM_UNVIS) V_edge[idx]<=EM_ONCE;
            else if(cur==EM_ONCE) V_edge[idx]<=EM_TWICE;
        end
        DIR_E: if(c!=8) begin
            idx=r*8+c; cur=H_edge[idx];
            if(cur==EM_UNVIS) H_edge[idx]<=EM_ONCE;
            else if(cur==EM_ONCE) H_edge[idx]<=EM_TWICE;
        end
        DIR_W: if(c!=0) begin
            idx=r*8+(c-1); cur=H_edge[idx];
            if(cur==EM_UNVIS) H_edge[idx]<=EM_ONCE;
            else if(cur==EM_ONCE) H_edge[idx]<=EM_TWICE;
        end
    endcase
end
endtask

//========================================================
// Trémaux Direction Choice (Combinational)
//========================================================
always @(*) begin
    absS_r = rel_to_abs(dir,0);
    absR_r = rel_to_abs(dir,1);
    absB_r = rel_to_abs(dir,2);
    absL_r = rel_to_abs(dir,3);

    unv_r=0; oncev_r=0;

    if(!s_left_s1) begin
        if(get_edge_mark(row,col,absL_r)==EM_UNVIS) begin unv_r=1; cand_un_r=absL_r; end
        else if(get_edge_mark(row,col,absL_r)==EM_ONCE) begin oncev_r=1; cand_once_r=absL_r; end
    end

    if(!unv_r && !s_mid_s1) begin
        if(get_edge_mark(row,col,absS_r)==EM_UNVIS) begin unv_r=1; cand_un_r=absS_r; end
        else if(!oncev_r && get_edge_mark(row,col,absS_r)==EM_ONCE) begin oncev_r=1; cand_once_r=absS_r; end
    end

    if(!unv_r && !s_right_s1) begin
        if(get_edge_mark(row,col,absR_r)==EM_UNVIS) begin unv_r=1; cand_un_r=absR_r; end
        else if(!oncev_r && get_edge_mark(row,col,absR_r)==EM_ONCE) begin oncev_r=1; cand_once_r=absR_r; end
    end

    if(unv_r) chosen_dir_next = cand_un_r;
    else if(oncev_r) chosen_dir_next = cand_once_r;
    else chosen_dir_next = absB_r;  // backtrack
end

//========================================================
// Sequential Logic
//========================================================
always @(posedge clk) begin
    if(!rst_n) begin
        row<=8; col<=4; dir<=DIR_N;
        move<=M_STOP; done<=0;

        for(i=0;i<N_H;i=i+1) H_edge[i]<=EM_UNVIS;
        for(i=0;i<N_V;i=i+1) V_edge[i]<=EM_UNVIS;

        s_left_s1<=left;
        s_mid_s1<=mid;
        s_right_s1<=right;

        chosen_dir_s1<=DIR_N;
        chosen_dir_s2<=DIR_N;
    end

    else if(done) begin
        move <= M_STOP;
    end

    else begin
        // stage 1 sensor sample
        s_left_s1 <= left;
        s_mid_s1  <= mid;
        s_right_s1<= right;

        // pipeline Trémaux
        chosen_dir_s1 <= chosen_dir_next;
        chosen_dir_s2 <= chosen_dir_s1;

        final_dir_r = chosen_dir_s2;
        ok_r = is_free_s1(final_dir_r);

        // fallback if blocked unexpectedly
        if(!ok_r) begin
            try_dirs_r[0]=absL_r;
            try_dirs_r[1]=absS_r;
            try_dirs_r[2]=absR_r;
            try_dirs_r[3]=absB_r;
            for(k_r=0;k_r<4;k_r=k_r+1)
                if(!ok_r && is_free_s1(try_dirs_r[k_r])) begin
                    final_dir_r = try_dirs_r[k_r];
                    ok_r=1;
                end
        end

        //----------------------------------------------------
        // CORRECT MOVE ENCODER (final_dir_r vs dir)
        //----------------------------------------------------
        if(!ok_r) begin
            move <= M_STOP;
        end
        else begin
            if(final_dir_r == dir)
                move <= M_FWD;

            else if((final_dir_r==DIR_N && dir==DIR_E) ||
                    (final_dir_r==DIR_W && dir==DIR_N) ||
                    (final_dir_r==DIR_S && dir==DIR_W) ||
                    (final_dir_r==DIR_E && dir==DIR_S))
                move <= M_LEFT;

            else if((final_dir_r==DIR_N && dir==DIR_W) ||
                    (final_dir_r==DIR_E && dir==DIR_N) ||
                    (final_dir_r==DIR_S && dir==DIR_E) ||
                    (final_dir_r==DIR_W && dir==DIR_S))
                move <= M_RIGHT;

            else
                move <= M_UTURN;

            //------------------------------------------------
            // UPDATE edge, pos, facing  (TB-synchronous)
            //------------------------------------------------
            inc_edge_mark(row,col,final_dir_r);

            case(final_dir_r)
                DIR_N: if(row>0) row <= row-1;
                DIR_S: if(row<8) row <= row+1;
                DIR_E: if(col<8) col <= col+1;
                DIR_W: if(col>0) col <= col-1;
            endcase

            dir <= final_dir_r;
        end

        // exit condition
        if(row==0 && col==4) begin
            move<=M_STOP;
            done<=1;
        end
    end
end


//////////////////DO NOT MAKE ANY CHANGES BELOW THIS LINE //////////////////

endmodule
