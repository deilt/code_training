//*********************************************************************************
// Project Name : 1101sequdentection.v
// File Name    : 1101sequdentection
// Module Name  : 1101sequdentection
// Author       : Deilt
// Email        : cjdeilt@qq.com
// Create Time  : 2023-08-10
// Called By    :
// Description  :1101 sequence detector
//
//
//
//*********************************************************************************
// Modification History:
// Date         Auther          Version                 Description
// -----------------------------------------------------------------------
// 22023-08-10   Deilt           1.0                     Original
//  
//
// *********************************************************************************
/*
11101101011010，在第5个时钟检测到序列，下一个时钟输出高电平；
11101101011010，在第8个时钟检测到序列，下一个时钟输出高电平；
11101101011010，在第13个时钟检测到序列，下一个时钟输出高电平；
*/
module 1101sequdentection(
  input           clk     ,
  input           rstn    ,
  input           data_in ,
  output          valid   //when decetced the 1101 ,valid = 1
);
reg valid;
//define state , usgin one hot code
  reg[4:0]    current_state;
  reg[4:0]    next_state   ;
  
  parameter IDLE = 00001,
			S1	 = 00010,
			S2   = 00100,
			S3   = 01000,
			S4   = 10000;
//state switch 
  always @(posedege clk or negedge rstn)begin
	if(rstn == 1'b0)
	  current_state <= IDLE;
	else 
	  current_state <= next_state;
  end

//state judge
  always @(*)begin
	if(!rstn)
	  next_state = IDLE;
    else begin
	  case(current_state)
		IDLE:
		  if(data_in == 1'b1)
			next_state = S1;
		  else
			next_state = IDLE;
		S1:
		  if(data_in == 1'b1)
			next_state = S2;
		  else
			next_state = IDLE;
		S2:
		  if(data_in == 1'b0)
			next_state = S3;
		  else 
			next_state = S2;
		S3:
		  if(data_in == 1'b1)
			next_state = S4;
		  else
			next_state = IDLE;
		S4:
		  if(data_in == 1'b1)
			next_state = S2;
		  else
			next_state = IDLE;
		default:
		  next_state = IDLE;
	  endcase
	end	  
  end
//output
  always @(posedge clk or negedge rstn)begin
	if(rstn == 1'b0)
	  valid <= 1'b0;	  
	else if(next_state == S4)
	  valid <= 1'b1;
	else
	  valid <= 1'b0;
  end

endmodule
						
