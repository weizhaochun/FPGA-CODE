module xuanzhuan(clk,a,b,rst,rst1,anya,led);input clk,a, b,anya,rst,rst1;output [7:0]led;reg[7:0]kaishi=8'b00000011;reg  qa=0,qb=0;reg  qa_dly=0;reg  rot_event=0;reg  left=0;reg  clk1;reg [31:0]count;always@(posedge clk) if(count<6999999)    count<=count+1; else   begin count<=0; clk1=~clk1; endalways@(posedge clk) begin   case({a,b})	2'b00: begin  qa<=0;qb<=qb; end	2'b01: begin  qa<=qa;qb<=1; end	//qa的功能是是判断上升沿的到来   2'b10: begin  qa<=qa;qb<=0; end //qb的功能是判断左移还是右移   2'b11: begin  qa<=1;qb<=qb; end   default:begin qa<=qa;qb<=qb;end	endcase endalways@(posedge clk)begin qa_dly<=qa; if((qa_dly==0)&&(qa==1))  begin      rot_event=1; left=qb; end else  begin rot_event=0;left=left;end end  always@(posedge clk1 or posedge rst or posedge rst1)  if(rst)   kaishi<=8'b00000001;	else if(rst1)	kaishi<=8'b00000011;	else //if(rot_event)   kaishi<=left?{kaishi[6:0],kaishi[7]}:{kaishi[0],kaishi[7:1]};				assign  led=anya?8'hff:kaishi;endmodule