module Lab6_5 (SW, KEY, CLOCK_50, LEDs, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);
input [2:0]KEY;
input [9:0]SW;
input CLOCK_50;
output [15:0]LEDs;
wire [15:0]addr;
wire [15:0]data;
wire [15:0]dataout; //q
reg [15:0]DIN;
wire [15:0]portout;
wire wr_en;
wire LEDs_en;
wire W;
wire run;
wire en_seg7_scroll;

wire sel_mem;
wire sel_port;

assign sel_mem = ~(addr[12]|addr[13]|addr[14]|addr[15]);
assign sel_port = addr[12] & addr[13] & ~addr[14] & ~addr[15];

assign wr_en = (~(addr[12]|addr[13]|addr[14]|addr[15])) & W;
assign LEDs_en = (~(~addr[12]|addr[13]|addr[14]|addr[15])) & W;

assign en_seg7_scroll = (~addr[12] & addr[13] & ~addr[14] & ~addr[15]) & W;

output [0:6]HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;

always @(*)
begin
if(sel_mem)
DIN = dataout;
if(sel_port)
DIN = portout;
end

port_n port (SW, CLOCK_50, portout);

proc p0 (run, dataout, CLOCK_50, KEY, data);
mem m0 (addr, CLOCK_50, data, wr_en, dataout);
regR LEDout (data, LEDs_en, CLOCK_50, LEDs);
FF regrun (SW[9],CLOCK_50,run);

seg7_scroll part4 (addr, data, en_seg7_scroll, LEDs_en, CLOCK_50, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);
/*

hexdisplay x0 (LEDs[3:0], HEX0[0:6]);
hexdisplay x1 (LEDs[7:4], HEX1[0:6]);
hexdisplay x2 (LEDs[11:8], HEX2[0:6]);
hexdisplay x3 (LEDs[15:12], HEX3[0:6]);
*/
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



module seg7_scroll (address, data, en_seg7_scroll, en_LEDs, clock, hex0out, hex1out, hex2out, hex3out, hex4out, hex5out);
input [15:0]address;
input [15:0]data;
output [0:6]hex0out, hex1out, hex2out, hex3out, hex4out, hex5out;
input clock;
input en_seg7_scroll, en_LEDs;
wire en_hex0, en_hex1, en_hex2, en_hex3, en_hex4, en_hex5;
wire [0:6] hex0out_char, hex1out_char, hex2out_char, hex3out_char, hex4out_char, hex5out_char, hex0_leds, hex1_leds, hex2_leds, hex3_leds;

assign en_hex0 = (en_seg7_scroll & (~address[15] & ~address[14] & address[13] & ~address[12] & address[0] & address[1] & address[2] & ~address[3])) ;
assign en_hex1 = (en_seg7_scroll & (~address[15] & ~address[14] & address[13] & ~address[12] & ~address[0] & address[1] & address[2] & ~address[3])) ;
assign en_hex2 = (en_seg7_scroll & (~address[15] & ~address[14] & address[13] & ~address[12] & address[0] & ~address[1] & address[2] & ~address[3])) ;
assign en_hex3 = (en_seg7_scroll & (~address[15] & ~address[14] & address[13] & ~address[12] & ~address[0] & ~address[1] & address[2] & ~address[3])) ;
assign en_hex4 = en_seg7_scroll & (~address[15] & ~address[14] & address[13] & ~address[12] & address[0] & address[1] & ~address[2] & ~address[3]);
assign en_hex5 = en_seg7_scroll & (~address[15] & ~address[14] & address[13] & ~address[12] & ~address[0] & address[1] & ~address[2] & ~address[3]);

hex_reg h0 (data[6:0], en_hex0, clock, hex0out_char);
hex_reg h1 (data[6:0], en_hex1, clock, hex1out_char);
hex_reg h2 (data[6:0], en_hex2, clock, hex2out_char);
hex_reg h3 (data[6:0], en_hex3, clock, hex3out_char);
hex_reg h4 (data[6:0], en_hex4, clock, hex4out_char);
hex_reg h5 (data[6:0], en_hex5, clock, hex5out_char);

hexdisplay x0 (data[3:0], hex0_leds[0:6]);
hexdisplay x1 (data[7:4], hex1_leds[0:6]);
hexdisplay x2 (data[11:8], hex2_leds[0:6]);
hexdisplay x3 (data[15:12], hex3_leds[0:6]);

assign hex0out = en_LEDs? hex0_leds: hex0out_char;
assign hex1out = en_LEDs? hex1_leds: hex1out_char;
assign hex2out = en_LEDs? hex2_leds: hex2out_char;
assign hex3out = en_LEDs? hex3_leds: hex3out_char;

assign hex4out = en_LEDs? 6'b0000001: hex4out_char;
assign hex5out = en_LEDs? 6'b0000001: hex5out_char;

endmodule

module hex_reg (din, rin, clock, qout);
	input [6:0]din;
	input clock, rin;
	output reg [6:0]qout;
	
	always @(posedge clock)
		if (rin==1) qout <= din;
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

module port_n (sw, clock, portout);
input [9:0]sw;
input clock;
output reg [15:0]portout;

always @(posedge clock)
	portout <= {5'b0,sw};

endmodule


