module Lab_3 (SW, KEY, CLOCK_50, LEDs, HEX0, HEX1, HEX2, HEX3);
input [2:0]KEY;
input [9:0]SW;
input CLOCK_50;
output [15:0]LEDs;
wire [15:0]addr;
wire [15:0]data;
wire [15:0]dataout;
wire wr_en;
wire LED_en;
wire W;
wire run;

assign wr_en = (~(addr[12]|addr[13]|addr[14]|addr[15])) & W;
assign LED_en = (~(~addr[12]|addr[13]|addr[14]|addr[15])) & W;

output [0:6]HEX0, HEX1, HEX2, HEX3;


proc p0 (run, dataout, CLOCK_50, KEY);
mem m0 (addr, CLOCK_50, data, wr_en, dataout);
regR LEDout (data, LED_en, CLOCK_50, LEDs);
FF regrun (SW[9],CLOCK_50,run);

hexdisplay x0 (LEDs[3:0], HEX0[0:6]);
hexdisplay x1 (LEDs[7:4], HEX1[0:6]);
hexdisplay x2 (LEDs[11:8], HEX2[0:6]);
hexdisplay x3 (LEDs[15:12], HEX3[0:6]);

endmodule

/*
module regR (din, rin, clock, qout);
	input [15:0]din;
	input clock, rin;
	output reg [15:0]qout;
	
	always @(posedge clock)
		if (rin==1) qout <= din;
endmodule*/

module FF (din, clock, qout);
	input din;
	input clock;
	output reg qout;
	
	always @(posedge clock)
		qout <= din;
endmodule

module hexdisplay(in, out);
input[3:0]in;
output reg [0:6]out;
always @(in)
case(in)
0:out=7'b0000001;
1:out=7'b1001111;
2:out=7'b0010010;
3:out=7'b0000110;
4:out=7'b1001100;
5:out=7'b0100100;
6:out=7'b0100000;
7:out=7'b0001111;
8:out=7'b0000000;
9:out=7'b0000100;
10:out=7'b0001000;
11:out=7'b1100000;
12:out=7'b0110001;
13:out=7'b1000010;
14:out=7'b0110000;
15:out=7'b0111000;
default out=7'bx;
endcase
endmodule
