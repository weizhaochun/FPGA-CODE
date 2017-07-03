module color(a,b,c,clk,res,out);
  input a,b,c,clk,res;
  output reg[7:0] out;
  reg[25:0] h;
  reg  clk1;
always@(posedge clk or posedge res)
    begin
	  if(res)
		out<=8'b11111111;
	  else if(a)
	   begin
		   if(out==8'b10000000)
			  out<=8'b00000001;
			else
			out<=out<<1;
			 
		end	   
	  else if(b)
		    begin
			 if(out==8'b11111111)
			  out<=8'b00000000;
			 else
			 out<=(out<<1)+1;
			 end
	  else if(c)
	   begin
		  if(out==8'b01010101)
		     out<=8'b10101010;
		  else
		     out<=8'b01010101;
		end
	  else
	   out<=8'b00000001;
	end
always@(posedge clk)
   if(h==2499999)
    begin
    h<=26'd00;
	 clk1<=~clk1;
	 end
	else
    h<=h+1;



endmodule