`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:46:15 11/22/2015 
// Design Name: 
// Module Name:    lcd_clock 
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
module lcd_clock(clk, zuo,you,set, reset, a, b, push, led8, qa, qb, rot_event, rot_left,  rst, LCD_E,  LCD_RS, LCD_RW, SF_D );
	 
	 input clk,rst,reset,zuo,you,set,a,b,push;//set修改时间
    output reg LCD_E;//使能端，0---无效，1--可读可写
    output reg LCD_RS;//0---命令，1----数据
    output reg LCD_RW;//读写控制 0---写， 1---读
    output  [11:8] SF_D;//数据线，高四位
	 output [7:0]led8;
	 output qa, qb;
	 output rot_event, rot_left;

	 reg [7:0]lpshf = 8'b1000_0000;     //FPGA can init registers from bitstream, diff. from ASIC
	 reg qa = 0, qb = 0;
	 reg qa_dly = 0;
	 reg rot_event = 0; 
	 reg rot_left = 0;

	 reg clk1=0;
//reg clk2=0;
reg[31:0]counter=32'b0;
//reg[31:0]cnt=32'b0;
reg[3:0]n1=4'd2;
reg[3:0]n2=4'd0;
reg[3:0]n3=4'd1;
reg[3:0]n4=4'd6;
reg[3:0]y1=4'd1;
reg[3:0]y2=4'd1;
reg[3:0]d1=4'd1;
reg[3:0]d2=4'd4;
reg[3:0]mg=4'b0;
reg[3:0]md=4'b0;
reg[3:0]sg=4'd2;
reg[3:0]sd=4'd7;
reg[3:0]hg=4'b1;
reg[3:0]hd=4'd0;
parameter x0=8'b00110000;
parameter x1=8'b00110001;
parameter x2=8'b00110010;
parameter x3=8'b00110011;
parameter x4=8'b00110100;
parameter x5=8'b00110101;
parameter x6=8'b00110110;
parameter x7=8'b00110111;
parameter x8=8'b00111000;
parameter x9=8'b00111001;
parameter x00=8'b00100000;
reg[7:0]m1;
reg[7:0]m2;
reg[7:0]s1;
reg[7:0]s2;
reg[7:0]h1;
reg[7:0]h2;
reg[7:0]y01;
reg[7:0]y02;
reg[7:0]y03;
reg[7:0]y04;
reg[7:0]m01;
reg[7:0]m02;
reg[7:0]d01;
reg[7:0]d02;

	 reg [3:0]sf_d;
	 assign SF_D = sf_d;
	 
	 reg [7:0]dataTran;
	 reg inited;//判读是否已经能够初始化
	 reg dataIn;//判断此时是否有数据要输入
	 reg cmd_data;//当前时刻是否写命令状态
	 reg dataTranDone;//判断数据是否传送结束
	 reg dataState;//当前时刻??否是写数?葑刺?

	 reg state_change;
	 reg [20:0]cnt;
	 
	 reg [5:0]dspState;
	 reg dspState_change;
	 reg [24:0]dsp_cnt;
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


always @(posedge clk)		//loop shift left/right
if (set)
	lpshf <= lpshf;
else if (rot_event)
	lpshf <= rot_left ? {lpshf[6:0], lpshf[7]} : {lpshf[0], lpshf[7:1]};

 
/*
always @(posedge clk)		//shift left/right and stop at either endpoint
if (rot_event)
begin
	if (rot_left && (lpshf != 8'b1000_0000))	//stuck at left end
		lpshf <= {lpshf[6:0], lpshf[7]};
	else if ((rot_left ==0) && (lpshf != 8'b0000_0001))		//stuck at right end
		lpshf <= {lpshf[0], lpshf[7:1]};
end
*/

assign led8 = push ? (lpshf ^ 8'hff) : lpshf;			//push (high) to invert display


	 initial begin
		dsp_cnt <= 25'd0;
		dspState_change <= 1'b1;
		dspState <= dspStateA;
	 end 
	 
always@(posedge clk)
begin
	if(counter<50000000)
		begin
			counter=counter+1;
			clk1=0;
		end
	else
		begin
			counter=0;
			clk1=1;
		end
end	 

always@(posedge clk1)
begin
if(rst)
	begin
	hg=0;
	md=0;
	mg=0;
	md=0;
	sg=0;
	sd=0;
	end
else
	if(!zuo&!you)
	begin
		if(sd<9)
				sd=sd+1;
		else if(sg<5)
			begin
				sd=0;
				sg=sg+1;
			end
		else if(md<9)
			begin
				sd=0;
				sg=0;
				md=md+1;
			end
		else if(mg<5)
			begin
				sd=0;
				sg=0;
				md=0;
				mg=mg+1;
			end
		else if(hd<9 && hg<1)
			begin
				sd=0;
				sg=0;
				md=0;
				mg=0;
				hd=hd+1;
			end
		else if(hd==9 && hg<1)
			begin
				sd=0;
				sg=0;
				md=0;
				mg=0;
				hd=0;
				hg=hg+1;
			end
		else if(hd<2 && hg==1)
			begin
				sd=0;
				sg=0;
				md=0;
				mg=0;
				hd=hd+1;
			end
		else
			begin
				sd=0;
				sg=0;
				md=0;
				mg=0;
				hd=0;
				hg=0;
			end
	end
	else if(zuo)
		if(md<9)
			md=md+1;
		else mg=mg+1;
	else if(you)
		if(md>0)
			md=md-1;
		else mg=mg-1;
end

always@(posedge clk)
	if(led8[0])
		begin
			if(rot_left)
			begin
			if(d2==9)
				d2=0;
			else
				d2=d2+1;
			end
		end
	else if(led8[1])
		begin
			if(rot_left)
			begin
			if(d1==5)
				d1=0;
			else
				d1=d1+1;
			end
		end
	else if(led8[2])
		begin
			if(rot_left)
			begin
			if(y2==9)
				y2=0;
			else
				y2=y2+1;
			end
		end
	else if(led8[3])
		begin
			if(rot_left)
			begin
			if(y1==1)
				y1=0;
			else
				y1=y1+1;
			end
		end
	else if(led8[4])
		begin
			if(rot_left)
			begin
			if(n4==9)
				n4=0;
			else
				n4=n4+1;
			end
		end
	else if(led8[5])
		begin
			if(rot_left)
			begin
			if(n3==9)
				n3=0;
			else
				n3=n3+1;
			end
		end
	else if(led8[6])
		begin
		if(rot_left)
		begin
			if(n2==9)
				n2=0;
			else
				n2=n2+1;
		end
		end
	else if(led8[7])
		begin
			if(rot_left)
			begin
			if(n1==9)
				n1=0;
			else
				n1=n1+1;
		end
		end
		
always@(posedge clk1)
begin
if(rst)
	m1=x0;
else
case(mg)
	4'b0000:m1=x0;
	4'b0001:m1=x1;
	4'b0010:m1=x2;
	4'b0011:m1=x3;
	4'b0100:m1=x4;
	4'b0101:m1=x5;
	
	default:m1=x0;
endcase
end

always@(posedge clk1)
begin
if(rst)
	m2=x0;
case(md)
	4'b0000:m2=x0;
	4'b0001:m2=x1;
	4'b0010:m2=x2;
	4'b0011:m2=x3;
	4'b0100:m2=x4;
	4'b0101:m2=x5;
	4'b0110:m2=x6;
	4'b0111:m2=x7;
	4'b1000:m2=x8;
	4'b1001:m2=x9;
	default:m2=x0;
endcase
end

always@(posedge clk1)
begin
if(rst)
	s1=x0;
case(sg)
	4'b0000:s1=x0;
	4'b0001:s1=x1;
	4'b0010:s1=x2;
	4'b0011:s1=x3;
	4'b0100:s1=x4;
	4'b0101:s1=x5;
	
	default:s1=x0;
endcase
end

always@(posedge clk1)
begin
if(rst)
	s2=x0;
case(sd)
	4'b0000:s2=x0;
	4'b0001:s2=x1;
	4'b0010:s2=x2;
	4'b0011:s2=x3;
	4'b0100:s2=x4;
	4'b0101:s2=x5;
	4'b0110:s2=x6;
	4'b0111:s2=x7;
	4'b1000:s2=x8;
	4'b1001:s2=x9;
	default:s2=x0;
endcase
end

always@(posedge clk1)
begin
if(rst)
	h2=x0;
case(hd)
	4'b0000:h2=x0;
	4'b0001:h2=x1;
	4'b0010:h2=x2;
	4'b0011:h2=x3;
	4'b0100:h2=x4;
	4'b0101:h2=x5;
	4'b0110:h2=x6;
	4'b0111:h2=x7;
	4'b1000:h2=x8;
	4'b1001:h2=x9;
	default:h2=x0;
endcase
end

always@(posedge clk1)
begin
if(rst)
	h1=x0;
case(hg)
	4'b0000:h1=x0;
	4'b0001:h1=x1;

	default:h1=x0;
endcase
end

always@(posedge clk1)
begin
case(n1)
	4'b0000:y01=x0;
	4'b0001:y01=x1;
	4'b0010:y01=x2;
	4'b0011:y01=x3;
	4'b0100:y01=x4;
	4'b0101:y01=x5;
	4'b0110:y01=x6;
	4'b0111:y01=x7;
	4'b1000:y01=x8;
	4'b1001:y01=x9;
	default:y01=x0;
endcase
end

always@(posedge clk1)
begin
case(n2)
	4'b0000:y02=x0;
	4'b0001:y02=x1;
	4'b0010:y02=x2;
	4'b0011:y02=x3;
	4'b0100:y02=x4;
	4'b0101:y02=x5;
	4'b0110:y02=x6;
	4'b0111:y02=x7;
	4'b1000:y02=x8;
	4'b1001:y02=x9;
	default:y02=x0;
endcase
end

always@(posedge clk1)
begin
case(n3)
	4'b0000:y03=x0;
	4'b0001:y03=x1;
	4'b0010:y03=x2;
	4'b0011:y03=x3;
	4'b0100:y03=x4;
	4'b0101:y03=x5;
	4'b0110:y03=x6;
	4'b0111:y03=x7;
	4'b1000:y03=x8;
	4'b1001:y03=x9;
	default:y03=x0;
endcase
end

always@(posedge clk1)
begin
case(n4)
	4'b0000:y04=x0;
	4'b0001:y04=x1;
	4'b0010:y04=x2;
	4'b0011:y04=x3;
	4'b0100:y04=x4;
	4'b0101:y04=x5;
	4'b0110:y04=x6;
	4'b0111:y04=x7;
	4'b1000:y04=x8;
	4'b1001:y04=x9;
	default:y04=x0;
endcase
end

always@(posedge clk1)
begin
case(y1)
	4'b0000:m01=x0;
	4'b0001:m01=x1;
	4'b0010:m01=x2;
	4'b0011:m01=x3;
	4'b0100:m01=x4;
	4'b0101:m01=x5;
	4'b0110:m01=x6;
	4'b0111:m01=x7;
	4'b1000:m01=x8;
	4'b1001:m01=x9;
	default:m01=x0;
endcase
end

always@(posedge clk1)
begin
case(y2)
	4'b0000:m02=x0;
	4'b0001:m02=x1;
	4'b0010:m02=x2;
	4'b0011:m02=x3;
	4'b0100:m02=x4;
	4'b0101:m02=x5;
	4'b0110:m02=x6;
	4'b0111:m02=x7;
	4'b1000:m02=x8;
	4'b1001:m02=x9;
	default:m02=x0;
endcase
end

always@(posedge clk1)
begin
case(d1)
	4'b0000:d01=x0;
	4'b0001:d01=x1;
	4'b0010:d01=x2;
	4'b0011:d01=x3;
	4'b0100:d01=x4;
	4'b0101:d01=x5;
	4'b0110:d01=x6;
	4'b0111:d01=x7;
	4'b1000:d01=x8;
	4'b1001:d01=x9;
	default:d01=x0;
endcase
end

always@(posedge clk1)
begin
case(d2)
	4'b0000:d02=x0;
	4'b0001:d02=x1;
	4'b0010:d02=x2;
	4'b0011:d02=x3;
	4'b0100:d02=x4;
	4'b0101:d02=x5;
	4'b0110:d02=x6;
	4'b0111:d02=x7;
	4'b1000:d02=x8;
	4'b1001:d02=x9;
	default:d02=x0;
endcase
end

	 always@(posedge clk)begin
		dsp_cnt <= dsp_cnt-1;
		if(reset)begin
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
									dsp_cnt <= 25'h0;//等待若干时间
									dspState_change <= 1'b0;
									dspState <= dspStateE;
									if(address <(8'hcf) ) address <= address+1;
									else	address <= 8'h7f;//第二位
									case(address)
									8'h7f:dataWrite<=8'b01000100;
									8'h80:dataWrite<=8'b01000001;
									8'h81:dataWrite<=8'b01011001;
									8'h84:dataWrite<=y01;
									8'h85:dataWrite<=y02;
									8'h86:dataWrite<=y03;
									8'h87:dataWrite<=y04;
									8'h88:dataWrite<=8'b00101110;
									8'h89:dataWrite<=m01;
									8'h8a:dataWrite<=m02;
									8'h8b:dataWrite<=8'b00101110;
									8'h8c:dataWrite<=d01;
									8'h8d:dataWrite<=d02;
									
								   8'hbf:dataWrite<=8'b01010011;
									8'hc0:dataWrite<=8'b01010101;
									8'hc1:dataWrite<=8'b01001110;
									8'hc2:dataWrite<=8'b00101110;
									8'hc5:dataWrite<=h1;
									8'hc6:dataWrite<=h2;
									8'hc7:dataWrite<=8'b00111010;
									8'hc8:dataWrite<=m1;
									8'hc9:dataWrite<=m2;
									8'hca:dataWrite<=8'b00111010;
									8'hcb:dataWrite<=s1;
									8'hcc:dataWrite<=s2;
									
									default: dataWrite <= 8'h20;
									endcase
									//$display($time," dspStateG! dataTranDone=%b",dataTranDone);
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
		inited<=0;
		state<=initStateA;
		dataState<=0;//未初始化
	end
	//*****************驱动部分主程序*******************//
	always@(posedge clk)begin 
		cnt<=cnt-1;
		if(reset)begin 
			inited<=0;
			state<=0;
			state_change<=1;
			cnt<=0;
			state<=initStateA;
			dataState<=0;
			dataTranDone<=1'b0;
			end
			else if(cnt==0)
			state_change<=1;
			else if(state_change&&!inited)begin
				case(state)
				initStateA:begin //等待15ms
					cnt<=20'd750000;
					state<=initStateB;
					state_change<=0;
					end
				initStateB:begin //写SF_D<11:8>=0x3，LCD_E保持高电平12时钟周期。
					cnt<=20'd12;
					LCD_E<=1;
					LCD_RW<=0;
					sf_d<=4'h3;
					state<=initStateC;
					state_change<=0;
					end
				initStateC:begin//等待4.1ms或更长，即在50MHz时，205000时钟周期。
					cnt <=20'd205000; //cnt <= 20'd205000;
					state <= initStateD;
					state_change <= 0;
					end
				initStateD:begin//写SF_D<11:8>=0x3，LCD_E保持高电平12时钟?芷凇?					
					cnt <= 20'd12;
					LCD_E <= 1;
					LCD_RW <= 0;
					sf_d <= 4'h3;
					state <= initStateE;
					state_change <= 0;
					end
				initStateE:begin//等待100us或更长，即在50MHz时，5000时钟周期。
					cnt<=20'd5000;
					state <=initStateF;
					state_change<=0;
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
				initStateG:begin //等待40us或更长，即在50MHz时，2000时钟??期。
					cnt<=20'd2000;
				   state<=initStateH;
					state_change<=0;
					end
				initStateH:begin//写SF_D<11:8>=0x2，LCD_E保持高电平12时钟周期。
					cnt<=20'd12;
					LCD_E <=1'b1;
					LCD_RW <=1'b0;
					sf_d<=4'h2;
					state<=initStateI;
					state_change <= 0;
					end
				initStateI:begin //等待40us或更长，即??0MHz时，2000时钟周期。
					cnt<=20'd2000;
					state <= initStateDone;
					state_change <= 0;
					end
				initStateDone:begin
					inited <= 1;
					state  <= dataStateA;
					state_change<=1'b0;
					cnt<=20'b1;
					dataTranDone <=1'b1;
					end
				endcase
			end
//***********************数据传送部分******************************//
			else if(state_change && inited && dataIn)begin
				case(state)
					dataStateA:begin 
						  dataTranDone <=1'b0;//数据传送开始
						  sf_d<=dataTran[7:4];//传送高四位
						  LCD_E  <= 1'b0;
						  LCD_RW <= 1'b0;
						  LCD_RS <= cmd_data;
						  cnt    <= 20'd3;
						  state  <= dataStateB;
						  state_change  <=1'b0;
						  end
					dataStateB:begin 
							dataTranDone <=1'b0;//数据传送未结束
							cnt<=20'd12;
							LCD_E <= 1'b1;  
							LCD_RW <= 1'b0;
							LCD_RS <= cmd_data; 
							state <= dataStateC;
							state_change <= 1'b0;
							end
					dataStateC:begin
							dataTranDone <= 1'b0;//数据传送未结束							
							LCD_E <= 1'b0;
							cnt <= 20'd53;//1us
							state <= dataStateD;
							cnt <= 20'd1;
							state_change <= 1'b0;	
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
							end
					dataStateF:begin
							LCD_E <= 1'b0;
			 				cnt <= 20'd2120;//40us
							state_change <= 1'b0;
							state <= dataStateA;
							dataTranDone <= 1'b1;//数据传送结束	
							end
						endcase
			end
			end
endmodule


/*

NET "LCD_E" LOC = M18;
NET "LCD_RS" LOC = L18;
NET "LCD_RW" LOC = L17;
NET "SF_D[8]" LOC = R15;
NET "SF_D[9]" LOC = R16;
NET "SF_D[10]" LOC = P17;
NET "SF_D[11]" LOC = M15;

NET "clk" LOC = C9;
NET "reset" LOC = N17;
NET "rst" LOC = L13;
NET "set" LOC = H18;



# PlanAhead Generated physical constraints 

NET "you" LOC = D18;
NET "zuo" LOC = K17;
# PlanAhead Generated physical constraints 

NET "a" LOC = K18;
NET "b" LOC = G18;
NET "push" LOC = V16;

# PlanAhead Generated physical constraints 

NET "a" PULLUP;
NET "b" PULLUP;
NET "push" PULLDOWN;

# PlanAhead Generated physical constraints 

NET "led8[0]" LOC = F12;
NET "led8[1]" LOC = E12;
NET "led8[2]" LOC = E11;
NET "led8[3]" LOC = F11;
NET "led8[4]" LOC = C11;
NET "led8[5]" LOC = D11;
NET "led8[6]" LOC = E9;
NET "led8[7]" LOC = F9;

*/
