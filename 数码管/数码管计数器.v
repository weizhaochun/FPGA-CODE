module shuma(clk,data,res,wei);
	 input clk,res;
	 output[7:0] data;
	 output[2:0] wei;
	 reg[7:0] data;
	 reg clk1,clk2;
	 reg[2:0] wei;
	 reg[25:0] a;
	 reg[3:0] ge,shi,bai,shu;
	 integer cout2;
always@(posedge clk or posedge res)
	   if(res)
		  begin
		   a<=26'd0;
			clk1<=1'b0;
	     end
		else if(a==26'd24999999)
		   begin
				 a<=26'd0;
			    clk1<=~clk1;
			end
	   else
		   a<=a+1;
always@(posedge clk )
		   case(shu)
			  4'd0:data<=~(8'b00111111);
           4'd1:data<=~(8'b00000110);
			  4'd2:data<=~(8'b01011011);
			  4'd3:data<=~(8'b01001111);
			  4'd4:data<=~(8'b01100110);
			  4'd5:data<=~(8'b01101101);
			  4'd6:data<=~(8'b01111101);
			  4'd7:data<=~(8'b00000111);
			  4'd8:data<=~(8'b01111111);
			  4'd9:data<=~(8'b01101111);
		   endcase
always@(posedge clk1 or posedge res)
      if(res)
		    ge<=0;
	   else if(ge==4'd9)
		    begin
		     ge<=0;
			  if(shi==4'd9)
			     begin
			      shi<=4'd0;
				   if(bai<=9)
					  bai<=4'd0;
					else
					  bai<=bai+1;
				  end
			  else
			    shi<=shi+1;
			 end	     
		else
		    ge<=ge+1;
always @ (posedge clk)
begin
	if (cout2==50)
		begin
		clk2<=~clk2;
		cout2=0;
		end
	else
		cout2=cout2+1;
end

always @ (posedge clk2)
begin
   if(wei<=3'b001)
	   wei<=3'b010;
   else if(wei<=3'b010)
	   wei<=3'b100;
	else
	wei<=3'b001;
end
always@(posedge clk)
     if(wei==3'b001)
	     shu<=ge;
	  else if(wei==3'b010)
	     shu<=shi;
	  else if(wei==3'b100)
	     shu<=bai;
endmodule