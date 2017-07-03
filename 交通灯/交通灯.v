module traffic(clk_in,clk,hold1,hold2,r1,g1,y1,
               r2,g2,y2);
input clk_in,hold1,hold2;
output reg clk;
output reg r1,g1,y1,r2,g2,y2;
reg [31:0]k;
integer num;
always@(posedge clk_in)
  if(k==32'd24999999)
    begin
	   k<=0;
		clk<=~clk;
	 end
	else
      k<=k+1'b1;
always@(posedge clk)
  begin
    if(num==25)
	   num=0;
	 else
		num=num+1;
  end
always@(posedge clk)
 begin
   if(hold1)
	  begin
	    r1<=1'b0;g1<=1'b1;y1<=1'b0;
		 r2<=1'b1;g2<=1'b0;y2<=1'b0;
	  end
	else if(hold2)
	  begin
	    r1<=1'b1;g1<=1'b0;y1<=1'b0;
		 r2<=1'b0;g2<=1'b1;y2<=1'b0;
	  end
   else
    if(num<5)
      begin
	    r1<=1'b1;g1<=1'b0;y1<=1'b0;
		 r2<=1'b0;g2<=1'b1;y2<=1'b0;
      end
    else if(num<8)
      begin
	    r1<=1'b1;g1<=1'b0;y1<=1'b0;
		 r2<=1'b0;g2<=1'b0;y2<=1'b1;
      end
    else if(num<13)
      begin
 	    r1<=1'b0;g1<=1'b1;y1<=1'b0;
		 r2<=1'b1;g2<=1'b0;y2<=1'b0;
      end
    else if(num<16)
      begin
 	    r1<=1'b0;g1<=1'b0;y1<=1'b1;
		 r2<=1'b0;g2<=1'b1;y2<=1'b0;
      end		 
 end
endmodule