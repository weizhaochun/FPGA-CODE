module vga(clk,rst_n,hsync,vsync,vga_r,vga_g,vga_b,red,gre);

input clk,red,gre; //50MHz
input rst_n; 
output hsync; 
output vsync; 
output reg vga_r;
output reg vga_g;
output reg vga_b;
reg[25:0] a;
reg clk1;
reg[1:0] num;
reg[10:0] x_cnt;
reg[9:0] y_cnt;
initial
   num=2'd0;
always@(posedge clk or posedge rst_n)
     if(rst_n)
	    begin
	     a<=26'd0;
		  clk1<=0;
		 end
	  else if( a==26'd24999999)
	    begin
	     a<=26'd0;
		  clk1<=~clk1;
		 end
     else
	     a<=a+1;
always @ (posedge clk or posedge rst_n)
	if(rst_n) 
		x_cnt <= 11'd0;
	else if(x_cnt == 11'd1039) 
		x_cnt <= 11'd0;
	else 
		x_cnt <= x_cnt+1'b1;
always @ (posedge clk or posedge rst_n)
	if(rst_n) 
		y_cnt <= 10'd0;
	else if(y_cnt == 10'd665) 
		y_cnt <= 10'd0;
	else if(x_cnt == 11'd1039) 
		y_cnt <= y_cnt+1'b1;
always@(posedge clk1)
    if(num==2'd3)
	    num<=1'd0;
    else
	    num<=num+1;
wire valid; 
assign 
	valid = (x_cnt >= 11'd187) && (x_cnt < 11'd987) 
	&& (y_cnt >= 10'd31) && (y_cnt < 10'd631); 

wire[9:0] xpos,ypos; 

assign xpos = x_cnt-11'd187;
assign ypos = y_cnt-10'd31;
reg hsync_r,vsync_r; 

always @ (posedge clk or posedge rst_n)
	if(rst_n) 
		hsync_r <= 1'b1;
	else if(x_cnt == 11'd0) 
		hsync_r <= 1'b0; 
	else if(x_cnt == 11'd120) 
		hsync_r <= 1'b1;
 
always @ (posedge clk or posedge rst_n)
	if(rst_n) 
		vsync_r <= 1'b1;
	else if(y_cnt == 10'd0) 
		vsync_r <= 1'b0; 
	else if(y_cnt == 10'd6) 
		vsync_r <= 1'b1;
assign hsync = hsync_r;
assign vsync = vsync_r;
wire a_dis,b_dis,c_dis,d_dis;
assign a_dis = ( (xpos>=300) && (xpos<=540) ) 
		 && ( (ypos>140)  && (ypos<=160) );
assign c_dis = ( (xpos>=239) && (xpos<=479) )
		 && ( (ypos>=340) && (ypos<=360) );
assign d_dis = ( (xpos>=279) && (xpos<=299) )
		 && ( (ypos>=100) && (ypos<=339) );
assign b_dis = ( (xpos>=480) && (xpos<=500) )
		 && ( (ypos>=161) && (ypos<=401) );
always@(posedge clk)
    begin
     case(num)
	     2'd0:
		  begin
		  vga_r <= valid ? a_dis: 1'b0;
		  vga_b <= valid ? ~a_dis : 1'b0;
		  vga_g<=1'b0;
		  end
        2'd1:
		  begin
		  vga_r <= valid ? (a_dis|b_dis): 1'b0;
		  vga_b <= valid ? ~(a_dis|b_dis): 1'b0;
		  vga_g<=1'b0;
		  end
		  2'd2:
		  begin
		  vga_r <= valid ? (c_dis|a_dis|b_dis): 1'b0;
		  vga_b <= valid ? ~(c_dis|a_dis|b_dis): 1'b0;
		  vga_g<=1'b0;
		  end
		  2'd3:
		  begin
		  vga_r <= valid ? (d_dis|c_dis|a_dis|b_dis): 1'b0;
		  vga_b <= valid ? ~(d_dis|c_dis|a_dis|b_dis): 1'b0;
		  vga_g <=1'b0;
		  end
	  endcase
	  end
endmodule