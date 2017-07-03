module lcd(
input clk,sw,
output reg rs,en,
output rw,
output reg [3:0] db);
reg clkr ;
reg [31:0] cnt ;
reg [7:0]	state;
reg [79:0] temp_1,temp_2;
reg [4:0] count_1,count_2;
parameter [79:0] char_dat = "wei zhao chun";
parameter [79:0] char_Dat = "201484006 ";
assign rw = 0;
always@(posedge clk or posedge sw)
   begin
    if(sw)
		begin
			cnt <= 0;
			clkr <= 0;
		end
	 else if(cnt == 32'd25000)
		begin
			cnt <= 0;
			clkr <= ~clkr;
		end
	 else
		begin
			clkr <= clkr;
			cnt <= cnt +1;
		end
   end
always@(posedge clkr or posedge sw)
	begin
		if(sw)	//同步复位初始化
			begin
				rs	<= 1;
				en	<= 0;
				state <= 8'd0;
				db <= 4'h0;
				count_1 <= 5'd0;
				count_2 <= 5'd0;
				temp_1 <= char_dat;
				temp_2 <= char_Dat;
			end
		else
			case(state)	//显示模式28
				8'd1	:	begin rs <= 0; db <= 4'h2; en <= 1; state <= 8'd2; end

				8'd2	:	begin en <= 0; state <= 8'd3;	end

				8'd3	:	begin rs <= 0; db <= 4'h8; en <= 1; state <= 8'd4;	end

				8'd4	:	begin	en <= 0; state <= 8'd5;	end
		      //08
				8'd5	:	begin rs <= 0; db <= 4'h0; en <= 1; state <= 8'd6; end
				8'd6	:	begin en <= 0; state <= 8'd7;	end
				8'd7	:	begin rs <= 0; db <= 4'h1; en <= 1; state <= 8'd8;	end
								8'd8	:	begin	en <= 0; state <= 8'd9;	end
				//06
				8'd9	:	begin rs <= 0; db <= 4'h0; en <= 1; state <= 8'd10; end
				8'd10	:	begin en <= 0; state <= 8'd11;	end
				8'd11	:	begin rs <= 0; db <= 4'h6; en <= 1; state <= 8'd12;	end
				8'd12	:	begin	en <= 0; state <= 8'd13;	end
				//0c
				8'd13	:	begin rs <= 0; db <= 4'h0; en <= 1; state <= 8'd14; end
				8'd14	:	begin en <= 0; state <= 8'd15;	end
				8'd15	:	begin rs <= 0; db <= 4'hc; en <= 1; state <= 8'd16;	end
				8'd16	:	begin	en <= 0; state <= 8'd17;	end
				//80
				8'd17	:	begin rs <= 0; db <= 4'h8; en <= 1; state <= 8'd18; end
				8'd18	:	begin en <= 0; state <= 8'd19;	end
				8'd19	:	begin rs <= 0; db <= 4'h0; en <= 1; state <= 8'd20;	end
				8'd20	:	begin	en <= 0; state <= 8'd21;	end
				//写数据
				8'd21	:	begin rs <= 1; db <= temp_1[79:76]; temp_1 <= (temp_1 << 4); en <= 1; state <= 8'd22; end
				8'd22	:	begin en <= 0; state <= 8'd23;	end
				8'd23	:	begin rs <= 1; db <= temp_1[79:76]; temp_1 <= (temp_1 << 4); en <= 1; count_1 <= count_1 +1; state <= 8'd24;	end
				8'd24 :	
				begin
					en <= 0;
					if(count_1 == 5'd10)//判断第一行数据是否写完
						begin
							state <= 8'd25;
							count_1 <= 0;
						end
					else
							state <= 8'd21;
				end
				8'd25	:	begin rs <= 0; db <= 4'hc; en <= 1; state <= 8'd26; end
				8'd26	:	begin en <= 0; state <= 8'd27; end
				8'd27	:	begin rs <= 0; db <= 4'h2; en <= 1; state <= 8'd28;	end
				8'd28	:	begin	en <= 0; state <= 8'd29; end
				8'd29	:	begin rs <= 1; db <=
				temp_2[79:76]; temp_2 <= (temp_2 << 4); en <= 1; state <= 8'd30; end
				8'd30	:	begin en <= 0; state <= 8'd31; end
				8'd31	:	begin rs <= 1; db <= temp_2[79:76]; temp_2 <= (temp_2 << 4); en <= 1; count_2 <= count_2 +1; state <= 8'd32; end
				8'd32 :	
				begin
					en <= 0;
					if(count_2 == 5'd10)//判断第二行数据是否写完
						begin
							state <= 8'd33;
							count_2 <= 0;
						end
					else
							state <= 8'd29;
					end
				8'd33	:	state <= 8'd33;//死循环
		default	:	state <= 8'd1;
		endcase
	end

endmodule
