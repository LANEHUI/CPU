 /*------------------------------------------------------------------------------
--------------------------------------------------------------------------------
Copyright (c) 2016, Loongson Technology Corporation Limited.

All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice,
this list of conditions and the following disclaimer in the documentation and/or
other materials provided with the distribution.

3. Neither the name of Loongson Technology Corporation Limited nor the names of
its contributors may be used to endorse or promote products derived from this
software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL LOONGSON TECHNOLOGY CORPORATION LIMITED BE LIABLE
TO ANY PARTY FOR DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--------------------------------------------------------------------------------
------------------------------------------------------------------------------*/

//*************************************************************************
//   > File Name   : confreg.v
//   > Description : Control module of
//                   16 red leds.
//
//   > Author      : LOONGSON
//   > Date        : 2017-08-04
//*************************************************************************

`define MAX_VALUE    16'd80
module confreg
(
    input  wire        clk,
    input  wire        resetn,
    // read and write from cpu
    input  wire        conf_we,
    input  wire [31:0] conf_wdata,
    // read and write to device on board
    output wire [15:0] led,
    output wire [1 :0] led_rg0,
    output wire [1 :0] led_rg1,
    output wire [7 :0] num_csn,   //new value   
    output wire [6 :0] num_a_g    
);

reg  [31:0] led_data;
wire [15:0] show_num_data;
//--------------------------------{led}begin-----------------------------//
//led display
//led_data[31:0]
wire write_led = conf_we;
assign led = led_data[15:0];
always @(posedge clk)
begin
    if(!resetn)
    begin
        led_data <= 32'h0;
    end
    else if(write_led)
    begin
        led_data <= ~conf_wdata[31:0];
    end
end
//---------------------------------{led}end------------------------------//


wire [3:0] show_num [7:0];
wire [15:0] num_data[7:0];
wire [3:0] show_data;
assign show_num_data = ~led_data[15:0];
assign num_data[0][15:15] = show_num_data[15:15];
assign num_data[0][14:14] = show_num_data[14:14]^num_data[0][15:15];
assign num_data[0][13:13] = show_num_data[13:13]^num_data[0][14:14];
assign num_data[0][12:12] = show_num_data[12:12]^num_data[0][13:13];
assign num_data[0][11:11] = show_num_data[11:11]^num_data[0][12:12];
assign num_data[0][10:10] = show_num_data[10:10]^num_data[0][11:11];
assign num_data[0][9:9] = show_num_data[9:9]^num_data[0][10:10];
assign num_data[0][8:8] = show_num_data[8:8]^num_data[0][9:9];
assign num_data[0][7:7] = show_num_data[7:7]^num_data[0][8:8];
assign num_data[0][6:6] = show_num_data[6:6]^num_data[0][7:7];
assign num_data[0][5:5] = show_num_data[5:5]^num_data[0][6:6];
assign num_data[0][4:4] = show_num_data[4:4]^num_data[0][5:5];
assign num_data[0][3:3] = show_num_data[3:3]^num_data[0][4:4];
assign num_data[0][2:2] = show_num_data[2:2]^num_data[0][3:3];
assign num_data[0][1:1] = show_num_data[1:1]^num_data[0][2:2];
assign num_data[0][0:0] = show_num_data[0:0]^num_data[0][1:1];

assign led_rg0 = num_data[0] >= `MAX_VALUE ? 2'b10: //亮红灯
                                          2'b01;
assign led_rg1 = led_rg0;
                                     
assign num_data[1] = num_data[0] / 4'd10;
assign num_data[2] = num_data[1] / 4'd10;
assign num_data[3] = num_data[2] / 4'd10;
assign num_data[4] = num_data[3] / 4'd10;
assign num_data[5] = num_data[4] / 4'd10;
assign num_data[6] = num_data[5] / 4'd10;
assign num_data[7] = num_data[6] / 4'd10;
assign show_num[0] = num_data[0] % 4'd10;
assign show_num[1] = num_data[1] % 4'd10;
assign show_num[2] = num_data[2] % 4'd10;
assign show_num[3] = num_data[3] % 4'd10;
assign show_num[4] = num_data[4] % 4'd10;
assign show_num[5] = num_data[5] % 4'd10;
assign show_num[6] = num_data[6] % 4'd10;
assign show_num[7] = num_data[7] % 4'd10;

reg [3:0] count;
always @(posedge clk) 
begin
    if ( !resetn )
    begin
        count <= 4'b0000;
    end
    else
    begin
        count <= (count+1)%4'd8;
    end
end

assign num_csn = count == 4'd0 ? 8'b1111_1110:
                 count == 4'd1 ? 8'b1111_1101:
                 count == 4'd2 ? 8'b1111_1011:
                 count == 4'd3 ? 8'b1111_0111:
                 count == 4'd4 ? 8'b1110_1111:
                 count == 4'd5 ? 8'b1101_1111:
                 count == 4'd6 ? 8'b1011_1111:
                                 8'b0111_1111;

assign show_data = num_csn == 8'b1111_1110 ? show_num[0]:  //0
                   num_csn == 8'b1111_1101 ? show_num[1]:   //1
                   num_csn == 8'b1111_1011 ? show_num[2]:   //2
                   num_csn == 8'b1111_0111 ? show_num[3]:   //3
                   num_csn == 8'b1110_1111 ? show_num[4]:   //4
                   num_csn == 8'b1101_1111&&num_data[0] < `MAX_VALUE ? show_num[5]:   //5
                   num_csn == 8'b1011_1111&&num_data[0] < `MAX_VALUE ? show_num[6]:   //6
                   num_csn == 8'b0111_1111&&num_data[0] < `MAX_VALUE ? show_num[7]:   //7
                   num_data[0] >= `MAX_VALUE&&(num_csn == 8'b0111_1111
                                           ||num_csn == 8'b1101_1111)?  4'd5     :
                                                                        4'd0;
                                                                    
                                                

assign num_a_g = show_data==4'd0 ? 7'b1111110 :   //0
                 show_data==4'd1 ? 7'b0110000 :   //1
                 show_data==4'd2 ? 7'b1101101 :   //2
                 show_data==4'd3 ? 7'b1111001 :   //3
                 show_data==4'd4 ? 7'b0110011 :   //4
                 show_data==4'd5 ? 7'b1011011 :   //5
                 show_data==4'd6 ? 7'b1011111 :   //6
                 show_data==4'd7 ? 7'b1110000 :   //7
                 show_data==4'd8 ? 7'b1111111 :   //8
                                   7'b1111011 ;   //9


// always @(posedge clk)
// begin
//     if ( !resetn )
//     begin
//         num_csn <= 8'b00000000;
//     end
//     else
//     begin
//         case ( count)
//             4'd0 : num_csn <= 8'b0111_1111;   //0
//             4'd1 : num_csn <= 8'b1011_1111;   //1
//             4'd2 : num_csn <= 8'b1101_1111;   //2
//             4'd3 : num_csn <= 8'b1110_1111;   //3
//             4'd4 : num_csn <= 8'b1111_0111;   //4
//             4'd5 : num_csn <= 8'b1111_1011;   //5
//             4'd6 : num_csn <= 8'b1111_1101;   //6
//             4'd7 : num_csn <= 8'b1111_1110;   //7
//         endcase
//     end
// end

// always @(posedge clk)
// begin
//     if ( !resetn )
//     begin
//         show_data <= 4'b0000;
//     end
//     else
//     begin
//         case ( num_csn )
//             8'b1111_1011 : show_data <= show_num[0];   //0
//             8'b1111_0111 : show_data <= show_num[1];   //1
//             8'b1110_1111 : show_data <= show_num[2];   //2
//             8'b1101_1111 : show_data <= show_num[3];   //3
//             8'b1011_1111 : show_data <= show_num[4];   //4
//             8'b0111_1111 : show_data <= show_num[5];   //5
//             8'b1111_1110 : show_data <= show_num[6];   //6
//             8'b1111_1101 : show_data <= show_num[7];   //7
//         endcase
//     end
// end

// always @(posedge clk)
// begin
//     if ( !resetn )
//     begin
//         num_a_g <= 7'b0000000;
//     end
//     else
//     begin
//         case ( show_data )
//             4'd0 : num_a_g <= 7'b1111110;   //0
//             4'd1 : num_a_g <= 7'b0110000;   //1
//             4'd2 : num_a_g <= 7'b1101101;   //2
//             4'd3 : num_a_g <= 7'b1111001;   //3
//             4'd4 : num_a_g <= 7'b0110011;   //4
//             4'd5 : num_a_g <= 7'b1011011;   //5
//             4'd6 : num_a_g <= 7'b1011111;   //6
//             4'd7 : num_a_g <= 7'b1110000;   //7
//             4'd8 : num_a_g <= 7'b1111111;   //8
//             4'd9 : num_a_g <= 7'b1111011;   //9
//         endcase
//     end
// end
    

endmodule
