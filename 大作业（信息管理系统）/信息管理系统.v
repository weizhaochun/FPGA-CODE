`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:42:48 11/21/2015 
// Design Name: 
// Module Name:    lcd 
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
module lcd( clk,a,b,st1,push,LCD_E,reset,rst2, LCD_RS, LCD_RW, SF_D);
	 
	input clk,reset,rst2,a,b,push,st1;
    output reg LCD_E;//使能端，0---无效，1--可读可写
    output reg LCD_RS;//0---命令，1----数据
    output reg LCD_RW;//读写控制 0---写， 1---读
    output  [11:8] SF_D;//数据线，高四位
 //switch_1切换1：时钟0：秒表  switch_2 1:清零 switch_3 1:保持
	 
	 
	 
	 reg [3:0]sf_d;
	 assign SF_D = sf_d;
	 
	 reg [7:0]dataTran;
	 reg inited;//判读是否已经能够初始化
	 reg dataIn;//判断此时是否有数据要输入
	 reg cmd_data;//当前时刻是否写命令状态
	 reg dataTranDone;//判断数据是否传送结束
	 reg dataState;//当前时刻??否是写数?

	 reg state_change;
	 reg [20:0]cnt;
	 
	 reg [5:0]dspState;
	 reg dspState_change;
	 reg [24:0]dsp_cnt;
	 
	 reg[2:0] zhuangtai;
	 reg push1,pushen;
	 reg[8:0] num,hao1,hao2,hao3,hao4,hao5,hao6,hao7,hao8,hao9;
	 reg[7:0] xue1,xue2,xue3,xue4,xue5,xue6,xue7,xue8,xue9;
	 reg qa,qb,qa_dly,rot_event,rot_left;
	 reg[31:0] i;
	 parameter dspStateA = 6'd0;
	 parameter dspStateB = 6'd1;
	 parameter dspStateC = 6'd2;
	 parameter dspStateD = 6'd3;
	 parameter dspStateE = 6'd4;
	 parameter dspStateF = 6'd5;
	 parameter dspStateG = 6'd6;
	 parameter dspStateD1 = 6'd7;
	 
	 reg [7:0]address;//地址
	 reg [7:0]dataWrite;//写入的数据
	 
	 initial begin
		dsp_cnt <= 25'd0;
		dspState_change <= 1'b1;
		dspState <= dspStateA;
		zhuangtai<=3'd0;
		i<=32'd0;
		num=1;
		hao1=0;
		hao2=0;
		hao3=0;
		hao4=0;
		hao5=0;
		hao6=0;
		hao7=0;
		hao8=0;
		hao9=0;
	 end 
always @(posedge clk)
    if(i<=32'd99999999)
       i<=32'd0;
    else
       i<=i+1;	
	 
always @(posedge clk)		//latch io signal into registers
begin

case ({a,b})
	2'b00:
		begin
			qa <= 0;
			qb <= qb;
		end
	2'b11:
		begin
			qa <= 1;
			qb <= qb;
		end
	2'b01:
		begin
			qa <= qa;
			qb <= 1;
		end
	2'b10:
		begin
			qa <= qa;
			qb <= 0;
		end
	default:
		begin
			qa <= qa;
			qb <= qb;
		end
endcase

end
always @(posedge clk)
	begin
	push1 <= push;			//non-blocking, take effect next cycle
	if ((push1== 0) && (push == 1))		//rising edge
		begin
			pushen = 1; 
		end
	else
		begin
			pushen = 0; 
		end
	end	
	  


always @(posedge clk)		//detect rising edge on A line
	begin
	qa_dly <= qa;			//non-blocking, take effect next cycle
	if ((qa_dly == 0) && (qa == 1))		//rising edge
		begin
			rot_event = 1; 
			rot_left = qb;		//qb ==1 means rot left, see figure on p8
		end
	else
		begin
			rot_event = 0; 
			rot_left = rot_left;
		end
	end	
always@(posedge clk)
	 begin
		case(zhuangtai)
			4'd0:begin
					if(rot_event)begin
						zhuangtai<=4'd1;
						end
					else
					  zhuangtai<=4'd0;
				 end
			4'd1:begin
					if(rot_event)begin
					   if(rot_left)
						  zhuangtai <= 4'd2;
					   else 
						  zhuangtai <= 4'd3;
						  end
					else if(pushen)
					     zhuangtai<=4'd0;
				   else
					  zhuangtai<=4'd1;
				end
			4'd2:begin
					if(rot_event)begin
						if(rot_left)
							zhuangtai<=4'd4;
						end
					else if(pushen)
							zhuangtai<=4'd1;
					else
					  zhuangtai<=4'd2;
				end
			4'd3:begin
					if(rot_event)begin
						if(!rot_left)
							zhuangtai<=4'd5;
						end
					else if(pushen)
							zhuangtai<=4'd1;
					else
					  zhuangtai<=4'd3;
				end
			4'd4:begin
			        if(pushen)
						zhuangtai<=4'd2;
					  else
					  zhuangtai<=4'd4;
				end
			4'd5:begin
					if(pushen)
					   zhuangtai<=4'd6;
					else
					  zhuangtai<=4'd5;
				end
			4'd6:begin
			     begin
			     if(num==1 && rot_event==1)
				   begin
				    if(rot_left)begin
					    if(hao1==9)
                    hao1<=4'd0;
						 else
						  hao1<=hao1+1;
						 end
                else	
					   begin
						 if(hao1==0)
                    hao1<=4'd9;
						 else
						  hao1<=hao1-1;
						 end
					end
				  else if(num==2 && rot_event==1)
				   begin
				    if(rot_left)begin
					    if(hao2==9)
                    hao2<=4'd0;
						 else
						  hao2<=hao2+1;
						 end
                else	
					   begin
						 if(hao2==0)
                    hao2<=4'd9;
						 else
						  hao2<=hao2-1;
						 end
					end
				  else if(num==3 && rot_event==1)
				   begin
				    if(rot_left)begin
					    if(hao3==9)
                    hao3<=4'd0;
						 else
						  hao3<=hao3+1;
						 end
                else	
					   begin
						 if(hao3==0)
                    hao3<=4'd9;
						 else
						  hao3<=hao3-1;
						 end
					end
				  else if(num==4 && rot_event==1)
				   begin
				    if(rot_left)begin
					    if(hao4==9)
                    hao4<=4'd0;
						 else
						  hao4<=hao4+1;
						 end
                else	
					   begin
						 if(hao4==0)
                    hao4<=4'd9;
						 else
						  hao4<=hao4-1;
						 end
					end
				  else if(num==5 && rot_event==1)
				   begin
				    if(rot_left)begin
					    if(hao5==9)
                    hao5<=4'd0;
						 else
						  hao5<=hao5+1;
						 end
                else	
					   begin
						 if(hao5==0)
                    hao5<=4'd9;
						 else
						  hao5<=hao5-1;
						 end
					end
				  else if(num==6 && rot_event==1)
				   begin
				    if(rot_left)begin
					    if(hao6==9)
                    hao6<=4'd0;
						 else
						  hao6<=hao6+1;
						 end
                else	
					   begin
						 if(hao6==0)
                    hao6<=4'd9;
						 else
						  hao6<=hao6-1;
						 end
					end
				  else if(num==7 && rot_event==1)
				   begin
				    if(rot_left)begin
					    if(hao7==9)
                    hao7<=4'd0;
						 else
						  hao7<=hao7+1;
						 end
                else	
					   begin
						 if(hao7==0)
                    hao7<=4'd9;
						 else
						  hao7<=hao7-1;
						 end
					end
				  else if(num==8 && rot_event==1)
				   begin
				    if(rot_left)begin
					    if(hao8==9)
                    hao8<=4'd0;
						 else
						  hao8<=hao8+1;
						 end
                else	
					   begin
						 if(hao8==0)
                    hao8<=4'd9;
						 else
						  hao8<=hao8-1;
						 end
					end
				else if(num==9 && rot_event==1)
				   begin
				    if(rot_left)begin
					    if(hao9==9)
                    hao9<=4'd0;
						 else
						  hao9<=hao9+1;
						 end
                else	
					   begin
						 if(hao9==0)
                    hao9<=4'd9;
						 else
						  hao9<=hao9-1;
						 end
					end
				end
				begin	
				if(pushen)
				   begin
				    if(num==9)
					    num<=4'd1;
					 else
					    num<=num+1;
					end
				end
			   begin
			    if(st1)
			    begin
				   if(hao1==2 && hao2==0 && hao3==1 && hao4==4 && hao5==8 && hao6==4 && hao7==0 && hao8==0 && hao9==6)
					   zhuangtai<=4'd7;
					else
					   zhuangtai<=4'd8;
			    end
				end
         end
       4'd7:begin
		       if(pushen)
				   zhuangtai<=4'd5;
				 else
				   zhuangtai<=4'd7;
				end
		 4'd8:
		   begin
			    if(pushen)
				   zhuangtai<=4'd5;
				 else
				   zhuangtai<=4'd8;
			end
         		 
		endcase
	end
/*task ascll(acll_in,ascll_out);
input[3:0]ascll_in;
output[7:0]ascll_out;
		begin
			case(ascll_in)
			4'b0000: ascll_out=8'b00110000;
			4'b0001: ascll_out=8'b00110001;
			4'b0010: ascll_out=8'b00110010;
			4'b0011: ascll_out=8'b00110011;
			4'b0100: ascll_out=8'b00110100;
			4'b0101: ascll_out=8'b00110101;
			4'b0110: ascll_out=8'b00110110;
			4'b0111: ascll_out=8'b00110111;
			4'b1000: ascll_out=8'b00111000;
			4'b1001: ascll_out=8'b00111001;
			default: ascll_out=8'b0010000;
			endcase
		end
endtask
always@(posedge clk)
     begin
			   ascll(hao1,xue1);
				ascll(hao2,xue1);
				ascll(hao3,xue3);
				ascll(hao4,xue4);
				ascll(hao5,xue5);
				ascll(hao6,xue6);
				ascll(hao7,xue7);
				ascll(hao8,xue8);
				ascll(hao9,xue9);
				ascll(hao10,xue10);
			end	*/
always@(posedge clk)begin
		dsp_cnt <= dsp_cnt-1;
		if(reset)begin                       //此处原为reset
			cmd_data <= 1'b0;//输入命令??式
			dspState <= dspStateA;
			dspState_change <= 1'b1;
			dsp_cnt <= 25'd0;
			dataIn <= 1'b0;
			address<=8'hc0; //address <= (8'h00|8'h80);//第一行第一个位置
			dataWrite <= 8'h41;//A
		end
		else if(dsp_cnt==0)dspState_change <=1'b1;
		else if(dspState_change) begin//上一个数据传输结束可以传送下一个
			case(dspState) 
				dspStateA:begin
								if(dataTranDone)begin
								dataIn <= 1'b1;// 输入命令 启动驱动部分
								cmd_data <= 0;//输入命令模式
								dataTran <= 8'h28;//输入命令0x28
								dspState <= dspStateB;
								dspState_change <=1'b0;
								dsp_cnt <= 25'd2120;
								//$display($time," dspStateA! dataTranDone=%b",dataTranDone);
								end
							end
				dspStateB:begin
								if(dataTranDone)begin
									dataIn <= 1'b1;
									cmd_data <= 1'b0;
									dataTran <= 8'h06;
									dspState_change <=1'b0;
									dspState <= dspStateC;
									dsp_cnt <= 25'd2120;
									//$display($time," dspStateB! dataTranDone=%b",dataTranDone);
								end
							end
				dspStateC:begin
								if(dataTranDone)begin
									dataIn <=1'b1;
									cmd_data <=1'b0;
									dataTran <= 8'h0c;
									dspState_change <= 1'b0;
									dspState <= dspStateD;
									dsp_cnt <= 25'd2120;
									//$display($time," dspStateC! dataTranDone=%b",dataTranDone);
								end
							end
				dspStateD:begin
								if(dataTranDone)begin
									dataIn <= 1'b1;
									dsp_cnt <= 25'd2120; 
									dspState_change <=1'b0;
									cmd_data <= 1'b0;
									dataTran <= 8'h01;//发清屏命令
									dspState <= dspStateD1;
									//$display($time," dspStateD! dataTranDone=%b",dataTranDone);
								end
							end
				dspStateD1:begin
								if(dataTranDone)begin
									dataIn <= 1'b0;
									dspState_change <= 1'b0;
									dsp_cnt <= 25'd8200;//dsp_cnt <= 25'd82000;//等待1.64ms
									dspState <= dspStateE;
									//$display($time," dspStateD1! dataTranDone=%b",dataTranDone);
								end
							end
				dspStateE:begin
							//	if(dataTranDone)begin//输入地址
									dataTran <= address;
									dataIn <= 1'b1;
									cmd_data <=1'b0;
									dspState_change <= 1'b0;
									dspState <= dspStateF;
									dsp_cnt <= 25'd2120;
									//$display($time," dspStateE! dataTranDone=%b",dataTranDone);
							//	end
							end
				dspStateF:begin
								if(dataTranDone)begin
									dataIn <= 1'b1;
									cmd_data <= 1'b1;//写入数据
									dataTran <= dataWrite;//写入数据
									dspState <= dspStateG;
									dspState_change <= 1'b0;
									dsp_cnt <= 25'd2120;
							   	//$display($time," dspStateF! dataTranDone=%b",dataTranDone);
								end
							end
				dspStateG:begin
								if(dataTranDone)begin
									dataIn <= 1'b0;//关闭
									dsp_cnt <= 25'h0_00ff_ff;//等待若干时间
									dspState_change <= 1'b0;
									dspState <= dspStateE;
									
									if(address < (8'h8f) ) address <= address+1;
									else 	
									begin
									address<=8'hc0;
									if(address < (8'hcf) ) address <= address+1;
									else
									address<=8'h80;
									end
									
									//第二位
								//	if(dataWrite < (8'h5a))	dataWrite <= dataWrite+1;//A---Z
								//	else dataWrite <= 8'h41;  //A---Z
									//$display($time," dspStateG! dataTranDone=%b",dataTranDone);
									case(zhuangtai)	
									    4'd0:begin
										    case(address)
											8'h80:dataWrite<=8'b01010111;    //w
											8'h81:dataWrite<=8'b01100101;    //e
											8'h82:dataWrite<=8'b01101100;    //l
											8'h83:dataWrite<=8'b01101100;    //l
											8'h84:dataWrite<=8'b01000011;    //c
											8'h85:dataWrite<=8'b01001111;    //o
											8'h86:dataWrite<=8'b01001101;	 //m
											8'h87:dataWrite<=8'b10100000;    //空格
											8'h88:dataWrite<=8'b01110100;    //t
											8'h89:dataWrite<=8'b01001111;    //o
											8'h8a:dataWrite<=8'b10100000;    //空格
											8'h8b:dataWrite<=8'b01110100;    //t
											8'h8c:dataWrite<=8'b01101000;    //h
											8'h8d:dataWrite<=8'b01100101;    //e
											
											8'hc5:dataWrite<=8'b01110011;    //s
											8'hc6:dataWrite<=8'b01111001;    //y
											8'hc7:dataWrite<=8'b01110011;    //s
											8'hc8:dataWrite<=8'b01110100;    //t
											8'hc9:dataWrite<=8'b01100101;    //e
											8'hca:dataWrite<=8'b01001101;	 //m
											
											default:dataWrite<=8'b0010000;
											endcase
										end
										4'd1:begin
											case(address)
											8'h80:dataWrite<=8'b00110001;    //1
											8'h81:dataWrite<=8'b00101110;    //.
											8'h82:dataWrite<=8'b01100101;    //e
											8'h83:dataWrite<=8'b01101110;    //n
											8'h84:dataWrite<=8'b01110100;    //t
											8'h85:dataWrite<=8'b01100101;    //e
											8'h86:dataWrite<=8'b01110010;    //r
											8'h87:dataWrite<=8'b01101001;    //i
											8'h88:dataWrite<=8'b01101110;    //n
											8'h89:dataWrite<=8'b01100111;    //g
											
											8'hc0:dataWrite<=8'b00110010;    //2
											8'hc1:dataWrite<=8'b00101110;    //.
											8'hc2:dataWrite<=8'b01101001;    //i
											8'hc3:dataWrite<=8'b01101110;    //n
											8'hc4:dataWrite<=8'b01110001;    //q
											8'hc5:dataWrite<=8'b01110101;    //u
											8'hc6:dataWrite<=8'b01101001;    //i
											8'hc7:dataWrite<=8'b01110010;    //r
											8'hc8:dataWrite<=8'b01100101;    //e
										
											default:dataWrite<=8'b0010000;
											endcase
										end
										4'd2:begin
											case(address)
											8'h80:dataWrite<=8'b00110001;    //1
											8'h81:dataWrite<=8'b00101110;    //.
											8'h82:dataWrite<=8'b01110100;    //t
											8'h83:dataWrite<=8'b01100101;    //e
											8'h84:dataWrite<=8'b01100001;    //a
											8'h85:dataWrite<=8'b01000011;    //c
											8'h86:dataWrite<=8'b01101000;    //h
											8'h87:dataWrite<=8'b01100101;    //e
											8'h88:dataWrite<=8'b01110010;    //r
											
											8'hc0:dataWrite<=8'b00110010;    //2
											8'hc1:dataWrite<=8'b00101110;    //.
											8'hc2:dataWrite<=8'b01110011;    //s
											8'hc3:dataWrite<=8'b01110100;    //t
											8'hc4:dataWrite<=8'b01110101;    //u
											8'hc5:dataWrite<=8'b01100100;    //d
											8'hc6:dataWrite<=8'b01100101;    //e
											8'hc7:dataWrite<=8'b01101110;    //n
											8'hc8:dataWrite<=8'b01110100;    //t
										
											default:dataWrite<=8'b0010000;
											endcase
										end 
										4'd3:begin
											case(address)
											8'h80:dataWrite<=8'b00110001;    //1
											8'h81:dataWrite<=8'b00101110;    //.
											8'h82:dataWrite<=8'b01110100;    //t
											8'h83:dataWrite<=8'b01100101;    //e
											8'h84:dataWrite<=8'b01100001;    //a
											8'h85:dataWrite<=8'b01000011;    //c
											8'h86:dataWrite<=8'b01101000;    //h
											8'h87:dataWrite<=8'b01100101;    //e
											8'h88:dataWrite<=8'b01110010;    //r
											
											8'hc0:dataWrite<=8'b00110010;    //2
											8'hc1:dataWrite<=8'b00101110;    //.
											8'hc2:dataWrite<=8'b01110011;    //s
											8'hc3:dataWrite<=8'b01110100;    //t
											8'hc4:dataWrite<=8'b01110101;    //u
											8'hc5:dataWrite<=8'b01100100;    //d
											8'hc6:dataWrite<=8'b01100101;    //e
											8'hc7:dataWrite<=8'b01101110;    //n
											8'hc8:dataWrite<=8'b01110100;    //t
										
											default:dataWrite<=8'b0010000;
											endcase
										end
										4'd4:begin
											case(address)
											8'h80:dataWrite<=8'b01110000;    //p
											8'h81:dataWrite<=8'b01101100;    //l
											8'h82:dataWrite<=8'b01100101;    //e
											8'h83:dataWrite<=8'b01100001;    //a
											8'h84:dataWrite<=8'b01110011;    //s
											8'h85:dataWrite<=8'b01100101;    //e
											8'h86:dataWrite<=8'b10100000;    //空格
											8'h87:dataWrite<=8'b01101001;    //i
											8'h88:dataWrite<=8'b01101110;    //n
											8'h89:dataWrite<=8'b01110000;    //p
											8'h8a:dataWrite<=8'b01110101;    //u
											8'h8b:dataWrite<=8'b01110100;    //t
											8'h8c:dataWrite<=8'b10100000;    //空格
											8'hcd:dataWrite<=8'b01101010;    //j
											8'hce:dataWrite<=8'b01101111;    //o
											8'hcf:dataWrite<=8'b01100010;    //b

											8'hc1:dataWrite<=8'b01101110;    //n
											8'hc2:dataWrite<=8'b01110101;    //u
											8'hc3:dataWrite<=8'b01101101;    //m
											8'hc4:dataWrite<=8'b01100010;    //b
											8'hc5:dataWrite<=8'b01100101;    //e
											8'hc6:dataWrite<=8'b01110010;    //r
											8'hc7:dataWrite<=8'b10100000;    //空格
											8'hc8:dataWrite<=8'b01100001;    //a
											8'hc9:dataWrite<=8'b01101110;    //n
											8'hca:dataWrite<=8'b01100100;    //d
											8'hcb:dataWrite<=8'b10100000;    //空格
											8'hcc:dataWrite<=8'b01101110;    //n
											8'hcd:dataWrite<=8'b01100101;    //a
											8'hce:dataWrite<=8'b01101101;    //m
											8'hcf:dataWrite<=8'b01100101;    //e

											default:dataWrite<=8'b0010000;
											endcase
										end
										4'd5:begin
											case(address)
											8'h80:dataWrite<=8'b01110000;    //p
											8'h81:dataWrite<=8'b01101100;    //l
											8'h82:dataWrite<=8'b01100101;    //e
											8'h83:dataWrite<=8'b01100001;    //a
											8'h84:dataWrite<=8'b01110011;    //s
											8'h85:dataWrite<=8'b01100101;    //e
											8'h86:dataWrite<=8'b10100000;    //空格
											8'h87:dataWrite<=8'b01101001;    //i
											8'h88:dataWrite<=8'b01101110;    //n
											8'h89:dataWrite<=8'b01110000;    //p
											8'h8a:dataWrite<=8'b01110101;    //u
											8'h8b:dataWrite<=8'b01110100;    //t
											8'h8c:dataWrite<=8'b10100000;    //空格

											8'hc1:dataWrite<=8'b01110011;    //s
											8'hc2:dataWrite<=8'b01110100;    //t
											8'hc3:dataWrite<=8'b01110101;    //u
											8'hc4:dataWrite<=8'b01100100;    //d
											8'hc5:dataWrite<=8'b01100101;    //e
											8'hc6:dataWrite<=8'b01101110;    //n
											8'hc7:dataWrite<=8'b01110100;    //t
											8'hc8:dataWrite<=8'b10100000;    //空格
											8'hc9:dataWrite<=8'b01101110;    //n
											8'hca:dataWrite<=8'b01110101;    //u
											8'hcb:dataWrite<=8'b01101101;    //m
											8'hcc:dataWrite<=8'b01100010;    //b
											8'hcd:dataWrite<=8'b01100101;    //e
											8'hce:dataWrite<=8'b01110010;    //r

											default:dataWrite<=8'b0010000;
											endcase
										end
										4'd6:begin
										   case(address)
											8'h80:dataWrite<=hao1+8'b00110000;   
											8'h81:dataWrite<=hao2+8'b00110000;   
											8'h82:dataWrite<=hao3+8'b00110000;    
											8'h83:dataWrite<=hao4+8'b00110000;    
											8'h84:dataWrite<=hao5+8'b00110000;    
											8'h85:dataWrite<=hao6+8'b00110000;    
											8'h86:dataWrite<=hao7+8'b00110000;    
											8'h87:dataWrite<=hao8+8'b00110000;    
											8'h88:dataWrite<=hao9+8'b00110000;    
											
											default:dataWrite<=8'b0010000;
											endcase
										end
										4'd7:begin
											case(address)
											8'h80:dataWrite<=8'b01010111;    //w
											8'h81:dataWrite<=8'b01100101;    //e
											8'h82:dataWrite<=8'b01101001;    //i
											8'h83:dataWrite<=8'b10100000;    //空格
											8'h84:dataWrite<=8'b01110011;    //z
											8'h85:dataWrite<=8'b01101000;    //h
											8'h86:dataWrite<=8'b01100001;    //a
											8'h87:dataWrite<=8'b01101111;    //o
											8'h88:dataWrite<=8'b10100000;    //空格
											8'h89:dataWrite<=8'b01000011;    //c
											8'h8a:dataWrite<=8'b01110101;    //h
											8'h8b:dataWrite<=8'b01110101;    //u
											8'h8c:dataWrite<=8'b01101110;    //n
											
											8'hc0:dataWrite<=hao1+8'b00110000;   
											8'hc1:dataWrite<=hao2+8'b00110000;   
											8'hc2:dataWrite<=hao3+8'b00110000;    
											8'hc3:dataWrite<=hao4+8'b00110000;    
											8'hc4:dataWrite<=hao5+8'b00110000;    
											8'hc5:dataWrite<=hao6+8'b00110000;    
											8'hc6:dataWrite<=hao7+8'b00110000;    
											8'hc7:dataWrite<=hao8+8'b00110000;    
											8'hc8:dataWrite<=hao9+8'b00110000;    
											
											default:dataWrite<=8'b0010000;
											endcase
										end
										4'd8:begin
											case(address)
											8'h80:dataWrite<=8'b01010111;    //f
											8'h81:dataWrite<=8'b01101111;    //o
											8'h82:dataWrite<=8'b01110101;    //u
											8'h83:dataWrite<=8'b01101110;    //n
											8'h84:dataWrite<=8'b01100100;    //d
											8'h85:dataWrite<=8'b10100000;    //空格
											8'h86:dataWrite<=8'b01101110;    //n
											8'h87:dataWrite<=8'b01101111;    //o
											8'h88:dataWrite<=8'b10100000;    //空格
											8'h89:dataWrite<=8'b01101111;    //o
											8'h8a:dataWrite<=8'b01101110;    //n
											8'h8b:dataWrite<=8'b01100101;    //e
											
											default:dataWrite<=8'b0010000;
											endcase
										end
			              endcase
						end
					end
				endcase
			end
		end
	 
	 parameter initStateA = 6'h0;
	 parameter initStateB = 6'h1;
	 parameter initStateC = 6'h2;
	 parameter initStateD = 6'h3;
	 parameter initStateE = 6'h4;
	 parameter initStateF = 6'h5;
	 parameter initStateG = 6'h6;
	 parameter initStateH = 6'h7;
	 parameter initStateI = 6'h8;
	 parameter initStateDone = 6'h9;
	 
	 parameter dataStateA = 6'd10;
	 parameter dataStateB = 6'd11;
	 parameter dataStateC = 6'd12;
	 parameter dataStateD = 6'd13;
	 parameter dataStateE = 6'd14;
	 parameter dataStateF = 6'd15;
	 
	 reg [5:0]state;

	 initial begin
		inited <= 0 ;
		state <= initStateA;
		dataState<=0; //未初始化
	 end

	 always@(posedge clk)begin//lcd驱动部??	 	cnt <= cnt-1;
		cnt <= cnt-1;
		if(reset)begin                       //此处原reset
			inited <= 0;
			state_change <= 1;
			cnt <= 0;
			state <= initStateA;
			dataState<=0;
			dataTranDone <=1'b0;
		end
	else if(cnt==0) state_change <= 1;
		else if(state_change&& !inited) begin
			case(state)
			initStateA:begin//等待15ms
					cnt <= 20'd750000; //cnt <= 20'd750000;
					state <= initStateB;
					state_change <= 0;//等待15ms
					//$display($time," initStateA!");
					//LCD_E <= 1'b1;/////////////////////////////////////////
					end
			initStateB:begin//写SF_D<11:8>=0x3，LCD_E保持高电平12时钟周期。
					cnt <= 20'd12;
					LCD_E <= 1;
					LCD_RW <= 0;
					sf_d <= 4'h3;
					state <= initStateC;
					state_change <= 0;
					//$display($time," initStateB!");
					end
			initStateC:begin//等待4.1ms或更长，即在50MHz时，205000时钟周期。
					cnt <=20'd205000; //cnt <= 20'd205000;
					state <= initStateD;
					state_change <= 0;
					//$display($time," initStateC!");
					end
			initStateD:begin//写SF_D<11:8>=0x3，LCD_E保持高电平12时钟?芷凇?					cnt <= 20'd12;
					LCD_E <= 1;
					LCD_RW <= 0;
					sf_d <= 4'h3;
					state <= initStateE;
					state_change <= 0;
					//$display($time," initStateD!");
					end
			initStateE:begin//等待100us或更长，即在50MHz时，5000时钟周期。
					cnt <=20'd5000; //cnt <= 20'd5000;
					state <= initStateF;
					state_change <= 0;
					//$display($time," initStateE!");
					end
			initStateF:begin//??SF_D<11:8>=0x3，LCD_E保持高电平12时钟周期。
					cnt <= 20'd12;
					LCD_E <= 1;
					LCD_RW <= 0;
					sf_d <= 4'h3;
					state <= initStateG;
					state_change <= 0;
					//$display($time," initStateF!");
					end
			initStateG:begin//等待40us或更长，即在50MHz时，2000时钟??期。
					cnt <=20'd2000; //cnt <= 20'd2000;
					state <= initStateH;
					state_change <= 0;
					//$display($time," initStateG!");
					end
			initStateH:begin//写SF_D<11:8>=0x2，LCD_E保持高电平12时钟周期。
					cnt <= 20'd12;
					LCD_E <= 1'b1;
					LCD_RW <= 1'b0;
					sf_d <= 4'h2;
					state <= initStateI;
					state_change <= 0;
					//$display($time," initStateH!");
					end
			initStateI:begin//等待40us或更长，即??0MHz时，2000时钟周期。
					cnt <= 20'd2000; //cnt <= 20'd2000;
					state <= initStateDone;
					state_change <= 0;
					//$display($time," initStateI!");
					end
			initStateDone:begin
					inited <= 1;
					state <= dataStateA;
					state_change <= 1'b0;
					cnt <= 20'b1;
					dataTranDone <= 1'b1;
					//$display($time," initStateDone!");
					end
			endcase
		end
		else if(state_change && inited && dataIn)begin
			case(state)
				dataStateA:begin
							//$display($time," dataStateA_1! dataTranDone=%b",dataTranDone);
							dataTranDone <= 1'b0;//数据传送开始,数据传送未结束							
							sf_d <= dataTran[7:4];//传送高四位
							LCD_E <= 1'b0;
							LCD_RW <= 1'b0;
							LCD_RS <= cmd_data;
							cnt <= 20'd3;//40ns
							state <= dataStateB;
							state_change <=1'b0;
							//$display($time," dataStateA! dataTranDone=%b",dataTranDone); 
							end
				dataStateB:begin
							dataTranDone <= 1'b0;//数据传送未结束	
							cnt <= 20'd12;//230ns
							LCD_E <= 1'b1;  
							LCD_RW <= 1'b0;
							LCD_RS <= cmd_data; 
							state <= dataStateC;
							state_change <= 1'b0;
							//$display($time," dataStateB! dataTranDone=%b",dataTranDone);
							end
				dataStateC:begin
							dataTranDone <= 1'b0;//数据传送未结束							
							LCD_E <= 1'b0;
							cnt <= 20'd53;//1us
							state <= dataStateD;
							cnt <= 20'd1;
							state_change <= 1'b0;
							//$display($time," dataStateC! dataTranDone=%b",dataTranDone);
							end
				dataStateD:begin
							dataTranDone <= 1'b0;//数据传送未结束	
							sf_d <= dataTran[3:0];//传送低四位
							LCD_E <= 1'b0;
							LCD_RW <= 1'b0;
							LCD_RS <= cmd_data;
							cnt <= 20'd3;//40ns
							state <= dataStateE;
							state_change <=1'b0;
							cnt <= 20'b1;
							//$display($time," dataStateD! dataTranDone=%b",dataTranDone);
							end
				dataStateE:begin
							dataTranDone <= 1'b0;//数据传送未结束	
							cnt <= 20'd12;//230ns
							LCD_E <= 1'b1;
							LCD_RW <= 1'b0;
							LCD_RS <= cmd_data;
							state <= dataStateF;
							state_change <= 1'b0;
							cnt <= 20'd1;
							//$display($time," dataStateE! dataTranDone=%b",dataTranDone);
							end
				dataStateF:begin
							LCD_E <= 1'b0;
			 				cnt <= 20'd2120;//40us
							state_change <= 1'b0;
							state <= dataStateA;
							dataTranDone <= 1'b1;//数据传送结束	
							//$display($time," dataStateF! dataTranDone=%b",dataTranDone);
							end
			endcase
		end
	 end

endmodule


