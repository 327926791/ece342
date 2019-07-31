// contected to switches, keys & leds
module proc (run, datain, CLOCK_50,  KEY);
input run;
input [15:0]datain;
input [2:0]KEY;
input CLOCK_50;

wire keyposedege;
assign keyposedege=~KEY[1];

wire [15:0]busdata;



datapath dp (CLOCK_50, datain[15:0], busdata, KEY[0], run);
endmodule
//===========================================================================================
module datapath (clock, din, busout, resetn, run);
	input clock;
	wire irin, gout, dinout, ain, gin, addsub, clear, counter;
	input [15:0]din;
	output [15:0]busout;
	input resetn;
	input run;
	wire done; 
	wire[7:0]rout;
	wire [15:0]bus;	
	wire [8:0]ird;
	wire [15:0]r0, r1, r2, r3, r4, r5, r6, r7, a, g, reggout; //all the registers
	wire r0in, r1in, r2in, r3in, r4in, r5in, r6in, r7in;
	assign ird[8:0]= din[8:0];
	
	//connect all modules as following
control_unit ctrl0(clock, ird, run, resetn, irin, rout, gout, dinout, 
		r0in, r1in, r2in, r3in, r4in, r5in, r6in, r7in, ain, gin, 
		addsub, clear, counter, done);
	
multiplexer mux (rout, gout, dinout, din, r0, r1, r2, r3, r4, r5, r6, r7, g, bus);

addsub u0(addsub, a, bus, reggout);

counter c0(clock, clear, couterin);

regIR RIR(ird, irin, clock, ir);

regR G(reggout, gin, clock, g);

regR A(bus, ain, clock, a);

regR R0(bus, r0in, clock, r0);
regR R1(bus, r1in, clock, r1);
regR R2(bus, r2in, clock, r2);
regR R3(bus, r3in, clock, r3);
regR R4(bus, r4in, clock, r4);
regR R5(bus, r5in, clock, r5);
regR R6(bus, r6in, clock, r6);
regR R7(bus, r7in, clock, r7);

assign busout = bus;

endmodule 


module control_unit (clock, ir, run, resetn, irin, rout, gout, dinout, 
		r0in, r1in, r2in, r3in, r4in, r5in, r6in, r7in, ain, gin, 
		addsub, clear, counter, done);
	input clock;
	input [8:0]ir;
	input run, resetn;
	output reg irin, gout, dinout, ain, gin, addsub, clear, done;
	output reg r0in, r1in, r2in, r3in, r4in, r5in, r6in, r7in;
	output reg [7:0]rout;
	output reg [1:0]counter;
	
	reg [3:0]state;
	
	localparam [3:0] s0=0, smv=1, smvi=2, sadd1=3, sadd2=4, sadd3=5, 
		ssub1=6, ssub2=7, ssub3=8, sresetn=15;
		
	always @(posedge clock or negedge resetn)
	begin
		if (!resetn) state=sresetn;
		else 
		begin
			case(state)
			s0: if(ir[8:6]==0 && run==1) state=smv;
				else if (ir[8:6]==1 && run==1) state=smvi;
				else if (ir[8:6]==2 && run==1) state=sadd1;
				else if (ir[8:6]==3 && run==1) state=ssub1;
				else state=s0;
			smv: state=s0;
			smvi: state=s0;
			sadd1: state=sadd2;
			sadd2: state=sadd3;
			sadd3: state=s0;
			ssub1: state=ssub2;
			ssub2: state=ssub3;
			ssub3: state=s0;
			sresetn: state=s0;
			default: state=s0;
			endcase
		end	
	end
	
	always @(*)
	begin
		case(state)
			s0:
				begin
				irin=1;
				gout=0;
				dinout=0;
				ain=0; 
				gin=0; 
				addsub=0; 
				clear=0; 
				done=0;
				counter[1:0]=0;
				
				r0in=0;
				r1in=0; 
				r2in=0; 
				r3in=0; 
				r4in=0; 
				r5in=0; 
				r6in=0; 
				r7in=0;
				rout[7:0]=0;
				end
			smv:
				begin
				irin=0;
				gout=0;
				dinout=0;
				ain=0; 
				gin=0; 
				addsub=0; 
				clear=0; 
				done=1;
				counter[1:0]=0;
					begin
						case(ir[2:0])  //RY
						3'b000:
							rout[7:0]=8'b00000001;
						3'b001:
							rout[7:0]=8'b00000010;
						3'b010:
							rout[7:0]=8'b00000100;
						3'b011:
							rout[7:0]=8'b00001000;
						3'b100:
							rout[7:0]=8'b00010000;
						3'b101:
							rout[7:0]=8'b00100000;
						3'b110:
							rout[7:0]=8'b01000000;
						3'b111:
							rout[7:0]=8'b10000000;
						endcase
					end
					begin 
						case(ir[5:3])  //RX
						3'b000: begin
							r0in=1;
							r1in=0; 
							r2in=0; 
							r3in=0; 
							r4in=0; 
							r5in=0; 
							r6in=0; 
							r7in=0;
							end
						3'b001: begin
							r0in=0;
							r1in=1; 
							r2in=0; 
							r3in=0; 
							r4in=0; 
							r5in=0; 
							r6in=0; 
							r7in=0;
							end
						3'b010: begin
							r0in=0;
							r1in=0; 
							r2in=2; 
							r3in=0; 
							r4in=0; 
							r5in=0; 
							r6in=0; 
							r7in=0;
							end
						3'b011: begin 
							r0in=0;
							r1in=0; 
							r2in=0; 
							r3in=1; 
							r4in=0; 
							r5in=0; 
							r6in=0; 
							r7in=0;
							end
						3'b100: begin
							r0in=0;
							r1in=0; 
							r2in=0; 
							r3in=0; 
							r4in=1; 
							r5in=0; 
							r6in=0; 
							r7in=0;
							end
						3'b101: begin
							r0in=0;
							r1in=0; 
							r2in=0; 
							r3in=0; 
							r4in=0; 
							r5in=1; 
							r6in=0; 
							r7in=0;
							end
						3'b110: begin
							r0in=0;
							r1in=0; 
							r2in=0; 
							r3in=0; 
							r4in=0; 
							r5in=0; 
							r6in=1; 
							r7in=0;
							end
						3'b111: begin
							r0in=0;
							r1in=0; 
							r2in=0; 
							r3in=0; 
							r4in=0; 
							r5in=0; 
							r6in=0; 
							r7in=1;
							end
						endcase
					end
				end
			smvi:
				begin
				irin=0;
				gout=0;
				dinout=1;
				ain=0; 
				gin=0; 
				addsub=0; 
				clear=0; 
				done=1;
				counter[1:0]=0;
				rout[7:0]=0;
					begin 
						case(ir[5:3])  //RX
						3'b000: begin
							r0in=1;
							r1in=0; 
							r2in=0; 
							r3in=0; 
							r4in=0; 
							r5in=0; 
							r6in=0; 
							r7in=0;
							end
						3'b001: begin
							r0in=0;
							r1in=1; 
							r2in=0; 
							r3in=0; 
							r4in=0; 
							r5in=0; 
							r6in=0; 
							r7in=0;
							end 
						3'b010: begin 
							r0in=0;
							r1in=0; 
							r2in=2; 
							r3in=0; 
							r4in=0; 
							r5in=0; 
							r6in=0; 
							r7in=0;
							end 
						3'b011: begin 
							r0in=0;
							r1in=0; 
							r2in=0; 
							r3in=1; 
							r4in=0; 
							r5in=0; 
							r6in=0; 
							r7in=0;
							end 
						3'b100: begin
							r0in=0;
							r1in=0; 
							r2in=0; 
							r3in=0; 
							r4in=1; 
							r5in=0; 
							r6in=0; 
							r7in=0;
							end 
						3'b101: begin 
							r0in=0;
							r1in=0; 
							r2in=0; 
							r3in=0; 
							r4in=0; 
							r5in=1; 
							r6in=0; 
							r7in=0;
							end 
						3'b110: begin 
							r0in=0;
							r1in=0; 
							r2in=0; 
							r3in=0; 
							r4in=0; 
							r5in=0; 
							r6in=1; 
							r7in=0;
							end 
						3'b111: begin 
							r0in=0;
							r1in=0; 
							r2in=0; 
							r3in=0; 
							r4in=0; 
							r5in=0; 
							r6in=0; 
							r7in=1;
							end 
						endcase
					end
				end
			sadd1:
				begin
				irin=0;
				gout=0;
				dinout=0;
				ain=1; 
				gin=0; 
				addsub=0; 
				clear=0; 
				done=0;
				counter[1:0]=0;
				r0in=0;
				r1in=0; 
				r2in=0; 
				r3in=0; 
				r4in=0; 
				r5in=0; 
				r6in=0; 
				r7in=0;
					begin
						case(ir[5:3])  //Rx
						3'b000:
							rout[7:0]=8'b00000001;
						3'b001:
							rout[7:0]=8'b00000010;
						3'b010:
							rout[7:0]=8'b00000100;
						3'b011:
							rout[7:0]=8'b00001000;
						3'b100:
							rout[7:0]=8'b00010000;
						3'b101:
							rout[7:0]=8'b00100000;
						3'b110:
							rout[7:0]=8'b01000000;
						3'b111:
							rout[7:0]=8'b10000000;
						endcase
					end
				end
			sadd2:
				begin
				irin=0;
				gout=0;
				dinout=0;
				ain=0; 
				gin=1; 
				addsub=0; 
				clear=0; 
				done=0;
				counter[1:0]=0;
				r0in=0;
				r1in=0; 
				r2in=0; 
				r3in=0; 
				r4in=0; 
				r5in=0; 
				r6in=0; 
				r7in=0;
					begin
						case(ir[2:0])  //RY
						3'b000:
							rout[7:0]=8'b00000001;
						3'b001:
							rout[7:0]=8'b00000010;
						3'b010:
							rout[7:0]=8'b00000100;
						3'b011:
							rout[7:0]=8'b00001000;
						3'b100:
							rout[7:0]=8'b00010000;
						3'b101:
							rout[7:0]=8'b00100000;
						3'b110:
							rout[7:0]=8'b01000000;
						3'b111:
							rout[7:0]=8'b10000000;
						endcase
					end
				end
			sadd3:
				begin
				irin=0;
				gout=1;
				dinout=0;
				ain=0; 
				gin=0; 
				addsub=0; 
				clear=0; 
				done=1;
				counter[1:0]=0;
				rout[7:0]=0;
					begin 
						case(ir[5:3])  //RX
						3'b000: begin 
							r0in=1;
							r1in=0; 
							r2in=0; 
							r3in=0; 
							r4in=0; 
							r5in=0; 
							r6in=0; 
							r7in=0;
							end 
						3'b001: begin 
							r0in=0;
							r1in=1; 
							r2in=0; 
							r3in=0; 
							r4in=0; 
							r5in=0; 
							r6in=0; 
							r7in=0;
							end 
						3'b010: begin 
							r0in=0;
							r1in=0; 
							r2in=2; 
							r3in=0; 
							r4in=0; 
							r5in=0; 
							r6in=0; 
							r7in=0;
							end 
						3'b011: begin 
							r0in=0;
							r1in=0; 
							r2in=0; 
							r3in=1; 
							r4in=0; 
							r5in=0; 
							r6in=0; 
							r7in=0;
							end 
						3'b100: begin 
							r0in=0;
							r1in=0; 
							r2in=0; 
							r3in=0; 
							r4in=1; 
							r5in=0; 
							r6in=0; 
							r7in=0;
							end 
						3'b101: begin 
							r0in=0;
							r1in=0; 
							r2in=0; 
							r3in=0; 
							r4in=0; 
							r5in=1; 
							r6in=0; 
							r7in=0;
							end 
						3'b110: begin 
							r0in=0;
							r1in=0; 
							r2in=0; 
							r3in=0; 
							r4in=0; 
							r5in=0; 
							r6in=1; 
							r7in=0;
							end 
						3'b111: begin 
							r0in=0;
							r1in=0; 
							r2in=0; 
							r3in=0; 
							r4in=0; 
							r5in=0; 
							r6in=0; 
							r7in=1;
							end 
						endcase
					end
				end	
			ssub1:
				begin
				irin=0;
				gout=0;
				dinout=0;
				ain=1; 
				gin=0; 
				addsub=0; 
				clear=0; 
				done=0;
				counter[1:0]=0;
				r0in=0;
				r1in=0; 
				r2in=0; 
				r3in=0; 
				r4in=0; 
				r5in=0; 
				r6in=0; 
				r7in=0;
					begin
						case(ir[5:3])  //Rx
						3'b000:
							rout[7:0]=8'b00000001;
						3'b001:
							rout[7:0]=8'b00000010;
						3'b010:
							rout[7:0]=8'b00000100;
						3'b011:
							rout[7:0]=8'b00001000;
						3'b100:
							rout[7:0]=8'b00010000;
						3'b101:
							rout[7:0]=8'b00100000;
						3'b110:
							rout[7:0]=8'b01000000;
						3'b111:
							rout[7:0]=8'b10000000;
						endcase
					end
				end	
			ssub2:
				begin
				irin=0;
				gout=0;
				dinout=0;
				ain=0; 
				gin=1; 
				addsub=1; 
				clear=0; 
				done=0;
				counter[1:0]=0;
				r0in=0;
				r1in=0; 
				r2in=0; 
				r3in=0; 
				r4in=0; 
				r5in=0; 
				r6in=0; 
				r7in=0;
					begin
						case(ir[2:0])  //RY
						3'b000:
							rout[7:0]=8'b00000001;
						3'b001:
							rout[7:0]=8'b00000010;
						3'b010:
							rout[7:0]=8'b00000100;
						3'b011:
							rout[7:0]=8'b00001000;
						3'b100:
							rout[7:0]=8'b00010000;
						3'b101:
							rout[7:0]=8'b00100000;
						3'b110:
							rout[7:0]=8'b01000000;
						3'b111:
							rout[7:0]=8'b10000000;
						endcase
					end
				end
			ssub3:
				begin
				irin=0;
				gout=1;
				dinout=0;
				ain=0; 
				gin=0; 
				addsub=0; 
				clear=0; 
				done=1;
				counter[1:0]=0;
				rout[7:0]=0;
					begin 
						case(ir[5:3])  //RX
						3'b000: begin 
							r0in=1;
							r1in=0; 
							r2in=0; 
							r3in=0; 
							r4in=0; 
							r5in=0; 
							r6in=0; 
							r7in=0;
							end 
						3'b001: begin 
							r0in=0;
							r1in=1; 
							r2in=0; 
							r3in=0; 
							r4in=0; 
							r5in=0; 
							r6in=0; 
							r7in=0;
							end 
						3'b010: begin 
							r0in=0;
							r1in=0; 
							r2in=2; 
							r3in=0; 
							r4in=0; 
							r5in=0; 
							r6in=0; 
							r7in=0;
							end 
						3'b011: begin 
							r0in=0;
							r1in=0; 
							r2in=0; 
							r3in=1; 
							r4in=0; 
							r5in=0; 
							r6in=0; 
							r7in=0;
							end 
						3'b100: begin 
							r0in=0;
							r1in=0; 
							r2in=0; 
							r3in=0; 
							r4in=1; 
							r5in=0; 
							r6in=0; 
							r7in=0;
							end 
						3'b101: begin
							r0in=0;
							r1in=0; 
							r2in=0; 
							r3in=0; 
							r4in=0; 
							r5in=1; 
							r6in=0; 
							r7in=0;
							end 
						3'b110: begin 
							r0in=0;
							r1in=0; 
							r2in=0; 
							r3in=0; 
							r4in=0; 
							r5in=0; 
							r6in=1; 
							r7in=0;
							end 
						3'b111: begin 
							r0in=0;
							r1in=0; 
							r2in=0; 
							r3in=0; 
							r4in=0; 
							r5in=0; 
							r6in=0; 
							r7in=1;
							end 
						endcase
					end
				end
			sresetn:
				begin
				irin=0;
				gout=0;
				dinout=0;
				ain=0; 
				gin=0; 
				addsub=0; 
				clear=1; 
				done=0;
				counter[1:0]=0;
				
				r0in=0;
				r1in=0; 
				r2in=0; 
				r3in=0; 
				r4in=0; 
				r5in=0; 
				r6in=0; 
				r7in=0;
				rout[7:0]=0;
				end
			default:
				begin
				irin=0;
				gout=0;
				dinout=0;
				ain=0; 
				gin=0; 
				addsub=0; 
				clear=0; 
				done=0;
				counter[1:0]=0;
				
				r0in=0;
				r1in=0; 
				r2in=0; 
				r3in=0; 
				r4in=0; 
				r5in=0; 
				r6in=0; 
				r7in=0;
				rout[7:0]=0;
				end
		endcase
	end
endmodule

//components

module multiplexer (rout, gout, dinout, din, r0, r1, r2, r3, r4, r5, r6, r7, gin, busout);
	input [7:0]rout;
	input gout, dinout;
	input [15:0]din, r0, r1, r2, r3, r4, r5, r6, r7, gin;
	output reg [15:0]busout;
	
	always @(*)
	begin
		if (rout[7:0]==8'b00000001 && gout==0 && dinout==0) busout=r0;
		else if (rout[7:0]==8'b00000010 && gout==0 && dinout==0) busout=r1;
		else if (rout[7:0]==8'b00000100 && gout==0 && dinout==0) busout=r2;
		else if (rout[7:0]==8'b00001000 && gout==0 && dinout==0) busout=r3;
		else if (rout[7:0]==8'b00010000 && gout==0 && dinout==0) busout=r4;
		else if (rout[7:0]==8'b00100000 && gout==0 && dinout==0) busout=r5;
		else if (rout[7:0]==8'b01000000 && gout==0 && dinout==0) busout=r6;
		else if (rout[7:0]==8'b10000000 && gout==0 && dinout==0) busout=r7;
		else if (rout[7:0]==8'b00000000 && gout==1 && dinout==0) busout=gin;
		else if (rout[7:0]==8'b00000000 && gout==0 && dinout==1) busout=din;
		else busout = busout;
	end
endmodule

module regR (din, rin, clock, qout);
	input [15:0]din;
	input clock, rin;
	output reg [15:0]qout;
	
	always @(posedge clock)
		if (rin==1) qout <= din;
endmodule

module regIR (din, irin, clock, qout);
	input [8:0]din;
	input clock, irin;
	output reg [8:0]qout;
	
	always @(posedge clock)
		if (irin==1) qout <= din;
endmodule

// addsub u0(addsub, a, bus, reggout);

module addsub (addsub, regain, busin, reggout);
	input addsub;
	input [15:0]regain, busin;
	output reg [15:0]reggout;
	always @(*) begin
	if (addsub==0) reggout=regain+busin;
	else reggout=regain-busin;
	end
endmodule


module counter(clock, clear, counterin);
	input clock, clear;
	input [1:0]counterin;
endmodule
