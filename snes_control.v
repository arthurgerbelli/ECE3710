`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:08:10 12/11/2013 
// Design Name: 
// Module Name:    snes_control 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module snes_control(
						//input clk,
						input [15:0] serial_data,
						output data_latch,
						output interrupt,
						output reg data_clock
						);

reg clk;
reg clk_60;
reg [15:0] new_reg;
reg [15:0] old_reg;
wire data_clk_en; //signal which enables data_clock to the controller
integer i, count_60, count_6us;

initial
begin
	data_clock = 1'b1;
	new_reg=16'hFFFF;
	old_reg=16'hFFF1;    
    i=15;
    count_60=0;
    count_6us=0;
    clk_60 = 1'b0;
	 clk=1'b0;
end

always
begin
	#5 clk=~clk;
end

//clock 60Hz divider
always@(posedge clk)
begin
	if(count_60<833500)  //period 16.67ms
		count_60=count_60+1;    
   else
   begin
		clk_60 =~clk_60;
		count_60=0; 
	end
end

assign data_latch = (count_60<=1200 & clk_60); //12us wide pulse every 60Hz
assign data_clk_en = (count_60>1200 & count_60<20400  & clk_60); //interval for 16 pulses

always@(posedge clk)
begin
	if(data_clk_en) 
	begin
		if(count_6us<600)
			count_6us=count_6us+1; //16x 12us-wide-50%-duty pulses
		else
		begin
			data_clock=~data_clock;
			count_6us=0;
		end
	end
	else //just to ensure
	begin
		count_6us=0;
		data_clock=1'b1;    
	end
end

//always@(negedge data_clock)
//begin
//	//initial i=15
//	new_reg[i]=serial_data[i];
//   if(i==0)
//		i=15;
//   else
//		i=i-1;
//end

//interrupt pulse, if you control pulse width, add a count<X in the contional
assign interrupt = (new_reg!=old_reg & count_60>20400 & count_60<21000 & clk_60); 

endmodule
