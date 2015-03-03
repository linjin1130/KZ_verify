
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity encoder_240 is
port(
      stepdata: in std_logic_vector(299 downto 0);
		Finedata: out std_logic_vector(8 downto 0)
	  );
end encoder_240;

architecture Behavioral of encoder_240 is

signal encoderdata: std_logic_vector(8 downto 0);
signal EncodeData_tmp, EncodeData_tmp1,EncodeData_tmp2,EncodeData_tmp3: std_logic_vector(8 downto 0);
signal EncodeData_tmp4, EncodeData_tmp5: std_logic_vector(8 downto 0);
constant valid: std_logic:= '1';

begin

   encoder_process: process(stepdata(239 downto 0))
   begin
	----------######开始120-239的编码#####---------------
       if(stepdata(120)= valid) then
		       if(stepdata(180)= valid) then
                   if(stepdata(210)= valid) then
						       if(stepdata(225)= valid) then
								       if(stepdata(233)= valid) then
										        if(stepdata(237)= valid) then
												          if(stepdata(239)= valid) then
															          encoderdata <= "011101111";     -----Corresponding to Bit 239
                                                elsif(stepdata(238)= valid) then
                                                       encoderdata <= "011101110";     -----Corresponding to Bit 238
                                                else
                                                       encoderdata <= "011101101";  	  -----Corresponding to Bit 237
                                               end if;
                        					elsif(stepdata(235)= valid) then
                                                if(stepdata(236)= valid) then	
                                                       encoderdata <= "011101100";	  -----Corresponding to Bit 236														
 						                              else
																       encoderdata <= "011101011";	  -----Corresponding to Bit 235 
                                                end if;
                                       elsif(stepdata(234)= valid) then															
                                                 encoderdata <= "011101010";	  -----Corresponding to Bit 234
                                       else
													          encoderdata <= "011101001";	  -----Corresponding to Bit 233
                                       end if;
										 elsif(stepdata(229)= valid) then
										          if(stepdata(231)= valid) then
                                                if(stepdata(232)= valid) then													 
													                encoderdata <= "011101000";	  -----Corresponding to Bit 232 
													         else
                                                       encoderdata <= "011100111";	  -----Corresponding to Bit 231  													
                                                end if;
													 elsif(stepdata(230)= valid) then											 
                                                  encoderdata <= "011100110";          -----Corresponding to Bit 230
													 else
            												  encoderdata <= "011100101";          -----Corresponding to Bit 229
                                        end if;
										 elsif(stepdata(227)= valid) then
                                        if(stepdata(228)= valid) then
													        encoderdata <= "011100100";             -----Corresponding to Bit 228
													 else
													        encoderdata <= "011100011";             -----Corresponding to Bit 227
													 end if;
										 elsif(stepdata(226)= valid) then
													        encoderdata <= "011100010";             -----Corresponding to Bit 226
                               else
										         encoderdata <= "011100001";                     -----Corresponding to Bit 225
									    end if;
                      elsif(stepdata(218)= valid) then
							          if(stepdata(222)= valid) then
                                      if(stepdata(224)= valid) then										 
													        encoderdata <= "011100000";             -----Corresponding to Bit 224
													elsif(stepdata(223)= valid) then										 
													        encoderdata <= "011011111";             -----Corresponding to Bit 223
                                       else
                                               encoderdata <= "011011110";             -----Corresponding to Bit 222													
										         end if;
										  elsif(stepdata(220)= valid) then
                                       if(stepdata(221)= valid) then										  
													        encoderdata <= "011011101";             -----Corresponding to Bit 221
                                       else
										                 encoderdata <= "011011100";             -----Corresponding to Bit 220
													end if;
										  elsif(stepdata(219)= valid) then
													        encoderdata <= "011011011";             -----Corresponding to Bit 219
                                else
										         encoderdata <= "011011010";                     -----Corresponding to Bit 218
									     end if;
						     elsif(stepdata(214)= valid) then
							          if(stepdata(216)= valid) then
                                      if(stepdata(217)= valid) then										 
													        encoderdata <= "011011001";             -----Corresponding to Bit 217
                                      else															  
                                               encoderdata <= "011011000";             -----Corresponding to Bit 216
												  end if;
										 elsif(stepdata(215)= valid) then										 
													        encoderdata <= "011010111";             -----Corresponding to Bit 215
										 else
										        encoderdata <= "011010110";                      -----Corresponding to Bit 214
                               end if;
                      										 
						     elsif(stepdata(212)= valid) then
							           if(stepdata(213)= valid) then									 
													        encoderdata <= "011010101";             -----Corresponding to Bit 213
                                      else															  
                                               encoderdata <= "011010100";             -----Corresponding to Bit 212
												  end if;
							  elsif(stepdata(211)= valid) then										 
													        encoderdata <= "011010011";             -----Corresponding to Bit 211
							  else
										 encoderdata <= "011010010";                             -----Corresponding to Bit 210
                       end if;
                   elsif(stepdata(195)= valid) then
							          if(stepdata(203)= valid) then
                                      if(stepdata(207)= valid) then
                                             if(stepdata(209)= valid) then 												  
													             encoderdata <= "011010001";             -----Corresponding to Bit 209
													      elsif(stepdata(208)= valid) then										 
													             encoderdata <= "011010000";             -----Corresponding to Bit 208
                                             else
                                                    encoderdata <= "011001111";             -----Corresponding to Bit 207													
										               end if;
										        elsif(stepdata(205)= valid) then
                                             if(stepdata(206)= valid) then										  
													             encoderdata <= "011001110";             -----Corresponding to Bit 206
                                             else
										                      encoderdata <= "011001101";             -----Corresponding to Bit 205
													      end if;
										        elsif(stepdata(204)= valid) then
													         encoderdata <= "011001100";                  -----Corresponding to Bit 204
                                      else
										                  encoderdata <= "011001011";                     -----Corresponding to Bit 203
									           end if;
										  elsif(stepdata(199)= valid) then
                                             if(stepdata(201)= valid) then
                                                    if(stepdata(202)= valid) then															
													                    encoderdata <= "011001010";             -----Corresponding to Bit 202
                                                    else
										                             encoderdata <= "011001001";             -----Corresponding to Bit 201
													             end if;
                      						      elsif(stepdata(200)= valid) then
															              encoderdata <= "011001000";             -----Corresponding to Bit 200
															else
															              encoderdata <= "011000111";             -----Corresponding to Bit 199
															end if;
										  elsif(stepdata(197)= valid) then
                                             if(stepdata(198)= valid) then															
													             encoderdata <= "011000110";             -----Corresponding to Bit 198
                                             else
										                      encoderdata <= "011000101";             -----Corresponding to Bit 197
													      end if;
                      			  elsif(stepdata(196)= valid) then
										            encoderdata <= "011000100";                       -----Corresponding to Bit 196
										  else
														encoderdata <= "011000011";                       -----Corresponding to Bit 195
										  end if;											
                   elsif(stepdata(188)= valid) then
						       if(stepdata(192)= valid) then
								        if(stepdata(194)= valid) then
                                       encoderdata <= "011000010";                          -----Corresponding to Bit 194
                                elsif(stepdata(193)= valid) then
                                       encoderdata <= "011000001";                          -----Corresponding to Bit 193
                                else
                                       encoderdata <= "011000000";  	                      -----Corresponding to Bit 192
                                end if;
                         elsif(stepdata(190)= valid) then
								        if(stepdata(191)= valid) then
                                       encoderdata <= "010111111";                          -----Corresponding to Bit 191
                                else
                                       encoderdata <= "010111110";                          -----Corresponding to Bit 190
                                end if;
                         elsif(stepdata(189)= valid) then
                                   encoderdata <= "010111101";                              -----Corresponding to Bit 189
                         else
                                   encoderdata <= "010111100";  	                         -----Corresponding to Bit 188
                         end if;										  
                   elsif(stepdata(184)= valid) then
						       if(stepdata(186)= valid) then
								        if(stepdata(187)= valid) then
                                       encoderdata <= "010111011";                          -----Corresponding to Bit 187
                                else
                                       encoderdata <= "010111010";                          -----Corresponding to Bit 186
                                end if;
								 elsif(stepdata(185)= valid) then
                                   encoderdata <= "010111001";  	                        -----Corresponding to Bit 185
                         else
                               	  encoderdata <= "010111000";                             -----Corresponding to Bit 184
                         end if;						 
                   elsif(stepdata(182)= valid) then
						       if(stepdata(183)= valid) then
                                encoderdata <= "010110111";                                -----Corresponding to Bit 183
                         else
                                encoderdata <= "010110110";                                -----Corresponding to Bit 182
                         end if;
                   elsif(stepdata(181)= valid) then
                             encoderdata <= "010110101";  	                              -----Corresponding to Bit 181
                   else
                             encoderdata <= "010110100";
                   end if;                                                    -----Corresponding to Bit 180----------######结束180-239的编码#####---------------
  		       elsif(stepdata(150)= valid) then                                                ----------######开始179-120的编码#####---------------
                    if(stepdata(165)= valid) then
									if(stepdata(173)= valid) then
											 if(stepdata(177)= valid) then
											        if(stepdata(179)= valid) then
															   encoderdata <= "010110011";                -----Corresponding to Bit 179
                                         elsif(stepdata(178)= valid) then
                                                encoderdata <= "010110010";                -----Corresponding to Bit 178
                                         else
                                                encoderdata <= "010110001";  	            -----Corresponding to Bit 177
                                         end if;
                        			 elsif(stepdata(175)= valid) then
                                            if(stepdata(176)= valid) then	
                                                   encoderdata <= "010110000";	            -----Corresponding to Bit 176														
 						                          else
																   encoderdata <= "010101111";	            -----Corresponding to Bit 175 
                                            end if;
                                  elsif(stepdata(174)= valid) then															
                                            encoderdata <= "010101110";	                  -----Corresponding to Bit 174
                                  else
													     encoderdata <= "010101101";	                  -----Corresponding to Bit 173
                                  end if;
                            elsif(stepdata(169)= valid) then
											        if(stepdata(171)= valid) then
													         if(stepdata(172)= valid) then 
															          encoderdata <= "010101100";                -----Corresponding to Bit 172
                                                else
                                                       encoderdata <= "010101011";  	             -----Corresponding to Bit 171
                                                end if;
                                         elsif(stepdata(170)= valid) then															
                                                encoderdata <= "010101010";	                         -----Corresponding to Bit 170
                                         else
												            encoderdata <= "010101001";	                         -----Corresponding to Bit 169
                                         end if;
                            elsif(stepdata(167)= valid) then
											        if(stepdata(168)= valid) then
															   encoderdata <= "010101000";                -----Corresponding to Bit 168
                                         else
                                                encoderdata <= "010100111";  	             -----Corresponding to Bit 167
                                         end if;
                           elsif(stepdata(166)= valid) then															
                                     encoderdata <= "010100110";	                         -----Corresponding to Bit 166
                           else
												 encoderdata <= "010100101";	                         -----Corresponding to Bit 165
                           end if;
                    elsif(stepdata(158)= valid) then
                              if(stepdata(162)= valid) then
                                     if(stepdata(164)= valid) then										
                                            encoderdata <= "010100100";	                  -----Corresponding to Bit 164														
 						                   elsif(stepdata(163)= valid) then
														  encoderdata <= "010100011";	                  -----Corresponding to Bit 163 
                                     else
													     encoderdata <= "010100010";	                  -----Corresponding to Bit 162
                                     end if;
                              elsif(stepdata(160)= valid) then
											        if(stepdata(161)= valid) then
															   encoderdata <= "010100001";                -----Corresponding to Bit 161
                                         else
                                                encoderdata <= "010100000";  	            -----Corresponding to Bit 160
                                         end if;
                              elsif(stepdata(159)= valid) then															
                                        encoderdata <= "010011111";	                         -----Corresponding to Bit 159
                              else
												    encoderdata <= "010011110";	                         -----Corresponding to Bit 158
                              end if;
                    elsif(stepdata(154)= valid) then
										if(stepdata(156)= valid) then
										       if(stepdata(157)= valid) then
														  encoderdata <= "010011101";                -----Corresponding to Bit 157
                                     else
                                            encoderdata <= "010011100";  	             -----Corresponding to Bit 156
                                     end if;
                              elsif(stepdata(155)= valid) then															
                                        encoderdata <= "010011011";	                         -----Corresponding to Bit 155
                              else
												    encoderdata <= "010011010";	                         -----Corresponding to Bit 154
                              end if;
                    elsif(stepdata(152)= valid) then
										if(stepdata(153)= valid) then
												 encoderdata <= "010011001";                -----Corresponding to Bit 153
                              else
                                     encoderdata <= "010011000";  	             -----Corresponding to Bit 152
                              end if;
                    elsif(stepdata(151)= valid) then															
                              encoderdata <= "010010111";	                         -----Corresponding to Bit 151
                    else
									   encoderdata <= "010010110";	                         -----Corresponding to Bit 150
                    end if;						  --------######结束150-179的编码#####---------------
  		       elsif(stepdata(135)= valid) then										              --------######开始120-149的编码#####---------------
                       if(stepdata(143)= valid) then
									  if(stepdata(147)= valid) then
											   if(stepdata(149)= valid) then
														 encoderdata <= "010010101";                -----Corresponding to Bit 149
                                    elsif(stepdata(148)= valid) then
                                                encoderdata <= "010010100";                -----Corresponding to Bit 148
                                    else
                                                encoderdata <= "010010011";  	            -----Corresponding to Bit 147
                                    end if;
									  elsif(stepdata(145)= valid) then
                                            if(stepdata(146)= valid) then	
                                                   encoderdata <= "010010010";	            -----Corresponding to Bit 146														
 						                          else
																   encoderdata <= "010010001";	            -----Corresponding to Bit 145 
                                            end if;
                             elsif(stepdata(144)= valid) then															
                                       encoderdata <= "010010000";	                  -----Corresponding to Bit 144
                             else
													encoderdata <= "010001111";	                  -----Corresponding to Bit 143
                             end if;
                       elsif(stepdata(139)= valid) then
											if(stepdata(141)= valid) then
													 if(stepdata(142)= valid) then 
															  encoderdata <= "010001110";                -----Corresponding to Bit 142
                                        else
                                               encoderdata <= "010001101";  	             -----Corresponding to Bit 141
                                        end if;
											elsif(stepdata(140)= valid) then															
                                           encoderdata <= "010001100";	                         -----Corresponding to Bit 140
											else
											          encoderdata <= "010001011";	                         -----Corresponding to Bit 139
                                 end if;
                       elsif(stepdata(137)= valid) then
											if(stepdata(138)= valid) then
													 encoderdata <= "010001010";                -----Corresponding to Bit 138
                                 else
                                        encoderdata <= "010001001";  	             -----Corresponding to Bit 137
                                 end if;
                       elsif(stepdata(136)= valid) then															
                                     encoderdata <= "010001000";	                         -----Corresponding to Bit 136
                       else
												 encoderdata <= "010000111";	                         -----Corresponding to Bit 135
                       end if;
  		       elsif(stepdata(128)= valid) then										              --------######开始120-134的编码#####---------------
							  if(stepdata(132)= valid) then
										if(stepdata(134)= valid) then
												 encoderdata <= "010000110";                -----Corresponding to Bit 134
                              elsif(stepdata(133)= valid) then
                                     encoderdata <= "010000101";                -----Corresponding to Bit 133
                              else
                                     encoderdata <= "010000100";  	             -----Corresponding to Bit 132
                              end if;
								elsif(stepdata(130)= valid) then
                                  if(stepdata(131)= valid) then	
                                         encoderdata <= "010000011";	            -----Corresponding to Bit 131														
 						                else
													  encoderdata <= "010000010";	            -----Corresponding to Bit 130 
                                  end if;
                        elsif(stepdata(129)= valid) then															
                                  encoderdata <= "010000001";	                  -----Corresponding to Bit 129
                        else
											 encoderdata <= "010000000";	                  -----Corresponding to Bit 128
                        end if;
  		       elsif(stepdata(124)= valid) then
							  if(stepdata(126)= valid) then
										if(stepdata(127)= valid) then 
												 encoderdata <= "001111111";                -----Corresponding to Bit 127
                              else
                                     encoderdata <= "001111110";  	             -----Corresponding to Bit 126
                              end if;
							  elsif(stepdata(125)= valid) then															
                                 encoderdata <= "001111101";	                         -----Corresponding to Bit 125
							  else
											encoderdata <= "001111100";	                         -----Corresponding to Bit 124
                       end if;
  		       elsif(stepdata(122)= valid) then
								if(stepdata(123)= valid) then 
										 encoderdata <= "001111011";                -----Corresponding to Bit 123
                        else
                               encoderdata <= "001111010";  	             -----Corresponding to Bit 122
                        end if;
				 elsif(stepdata(121)= valid) then															
                       encoderdata <= "001111001";	                         -----Corresponding to Bit 121
				 else
							  encoderdata <= "001111000";	                         -----Corresponding to Bit 120
             end if;
	----------######结束120-239的编码#####---------------
	----------######开始0-119的编码#####---------------
       elsif(stepdata(60)= valid) then
		       if(stepdata(90)= valid) then
                   if(stepdata(105)= valid) then
						       if(stepdata(113)= valid) then
								       if(stepdata(117)= valid) then
												    if(stepdata(119)= valid) then
															encoderdata <= "001110111";     -----Corresponding to Bit 119
                                        elsif(stepdata(118)= valid) then
                                             encoderdata <= "001110110";     -----Corresponding to Bit 118
                                        else
                                             encoderdata <= "001110101";  	  -----Corresponding to Bit 117
                                        end if;
								       elsif(stepdata(115)= valid) then
                                        if(stepdata(116)= valid) then	
                                               encoderdata <= "001110100";	  -----Corresponding to Bit 116														
 						                      else
															  encoderdata <= "001110011";	  -----Corresponding to Bit 115 
                                        end if;
                               elsif(stepdata(114)= valid) then															
                                         encoderdata <= "001110010";	        -----Corresponding to Bit 114
                               else
													  encoderdata <= "001110001";	        -----Corresponding to Bit 113
                               end if;
						       elsif(stepdata(109)= valid) then
										     if(stepdata(111)= valid) then
                                          if(stepdata(112)= valid) then													 
													          encoderdata <= "001110000";	  -----Corresponding to Bit 112 
													   else
                                                 encoderdata <= "001101111";	  -----Corresponding to Bit 111  													
                                          end if;
											  elsif(stepdata(110)= valid) then											 
                                             encoderdata <= "001101110";          -----Corresponding to Bit 110
											  else
            											encoderdata <= "001101101";          -----Corresponding to Bit 109
                                   end if;
						       elsif(stepdata(107)= valid) then
                                   if(stepdata(108)= valid) then
													   encoderdata <= "001101100";             -----Corresponding to Bit 108
											  else
													   encoderdata <= "001101011";             -----Corresponding to Bit 107
											  end if;
								 elsif(stepdata(106)= valid) then
											  encoderdata <= "001101010";                    -----Corresponding to Bit 106
                         else
										     encoderdata <= "001101001";                    -----Corresponding to Bit 105
								 end if;-----------------------######结束105-119的编码#####---------------
                   elsif(stepdata(98)= valid) then  ------------------------2011.8.3 pm
							          if(stepdata(102)= valid) then
                                      if(stepdata(104)= valid) then										 
													        encoderdata <= "001101000";             -----Corresponding to Bit 104
													elsif(stepdata(103)= valid) then										 
													        encoderdata <= "001100111";             -----Corresponding to Bit 103
                                       else
                                               encoderdata <= "001100110";             -----Corresponding to Bit 102													
										         end if;
										  elsif(stepdata(100)= valid) then
                                       if(stepdata(101)= valid) then										  
													        encoderdata <= "001100101";             -----Corresponding to Bit 101
                                       else
										                 encoderdata <= "001100100";             -----Corresponding to Bit 100
													end if;
										  elsif(stepdata(99)= valid) then
													        encoderdata <= "001100011";             -----Corresponding to Bit 99
                                else
										         encoderdata <= "001100010";                     -----Corresponding to Bit 98
									     end if;
                   elsif(stepdata(94)= valid) then
							        if(stepdata(96)= valid) then
                                    if(stepdata(97)= valid) then										 
													    encoderdata <= "001100001";             -----Corresponding to Bit 97
                                    else															  
                                           encoderdata <= "001100000";             -----Corresponding to Bit 96
												end if;
							        elsif(stepdata(95)= valid) then										 
													encoderdata <= "001011111";                 -----Corresponding to Bit 95
									  else
										         encoderdata <= "001011110";                      -----Corresponding to Bit 94
                             end if;
                      										 
                   elsif(stepdata(92)= valid) then
							        if(stepdata(93)= valid) then									 
												encoderdata <= "001011101";             -----Corresponding to Bit 93
                             else															  
                                    encoderdata <= "001011100";             -----Corresponding to Bit 92
									  end if;
						 elsif(stepdata(91)= valid) then										 
										encoderdata <= "001011011";                    -----Corresponding to Bit 91
						 else
										encoderdata <= "001011010";                             -----Corresponding to Bit 90
                   end if;
		       elsif(stepdata(75)= valid) then
							  if(stepdata(83)= valid) then
                               if(stepdata(87)= valid) then
                                      if(stepdata(89)= valid) then 												  
													       encoderdata <= "001011001";             -----Corresponding to Bit 89
												  elsif(stepdata(88)= valid) then										 
													       encoderdata <= "001011000";             -----Corresponding to Bit 88
                                      else
                                              encoderdata <= "001010111";             -----Corresponding to Bit 87													
										        end if;
										 elsif(stepdata(85)= valid) then
                                      if(stepdata(86)= valid) then										  
													      encoderdata <= "001010110";             -----Corresponding to Bit 86
                                      else
										               encoderdata <= "001010101";             -----Corresponding to Bit 85
												  end if;
										 elsif(stepdata(84)= valid) then
													      encoderdata <= "001010100";                  -----Corresponding to Bit 84
                               else
										               encoderdata <= "001010011";                     -----Corresponding to Bit 83
									    end if;
							  elsif(stepdata(79)= valid) then
                               if(stepdata(81)= valid) then
                                      if(stepdata(82)= valid) then															
													      encoderdata <= "001010010";             -----Corresponding to Bit 82
                                      else
										               encoderdata <= "001010001";             -----Corresponding to Bit 81
												  end if;
                               elsif(stepdata(80)= valid) then
											         encoderdata <= "001010000";                          -----Corresponding to Bit 80
							          else
											         encoderdata <= "001001111";                          -----Corresponding to Bit 79
							          end if;
							  elsif(stepdata(77)= valid) then
                               if(stepdata(78)= valid) then															
													encoderdata <= "001001110";             -----Corresponding to Bit 78
                               else
										         encoderdata <= "001001101";             -----Corresponding to Bit 77
										 end if;
							  elsif(stepdata(76)= valid) then
										    encoderdata <= "001001100";                       -----Corresponding to Bit 76
							  else
											 encoderdata <= "001001011";                       -----Corresponding to Bit 75
							  end if;											
		       elsif(stepdata(68)= valid) then
						     if(stepdata(72)= valid) then
								       if(stepdata(74)= valid) then
                                       encoderdata <= "001001010";                          -----Corresponding to Bit 74
                               elsif(stepdata(73)= valid) then
                                       encoderdata <= "001001001";                          -----Corresponding to Bit 73
                               else
                                       encoderdata <= "001001000";  	                      -----Corresponding to Bit 72
                               end if;
                        elsif(stepdata(70)= valid) then
								       if(stepdata(71)= valid) then
                                       encoderdata <= "001000111";                          -----Corresponding to Bit 71
                               else
                                       encoderdata <= "001000110";                          -----Corresponding to Bit 70
                               end if;
                        elsif(stepdata(69)= valid) then
                                   encoderdata <= "001000101";                              -----Corresponding to Bit 69
                        else
                                   encoderdata <= "001000100";  	                         -----Corresponding to Bit 68
                        end if;										  
		       elsif(stepdata(64)= valid) then
						       if(stepdata(66)= valid) then
								        if(stepdata(67)= valid) then
                                       encoderdata <= "001000011";                          -----Corresponding to Bit 67
                                else
                                       encoderdata <= "001000010";                          -----Corresponding to Bit 66
                                end if;
								 elsif(stepdata(65)= valid) then
                                   encoderdata <= "001000001";  	                        -----Corresponding to Bit 65
                         else
                               	  encoderdata <= "001000000";                             -----Corresponding to Bit 64
                         end if;						 
		       elsif(stepdata(62)= valid) then
						     if(stepdata(63)= valid) then
                              encoderdata <= "000111111";                                -----Corresponding to Bit 63
                       else
                              encoderdata <= "000111110";                                -----Corresponding to Bit 62
                       end if;
		       elsif(stepdata(61)= valid) then
                       encoderdata <= "000111101";  	                              -----Corresponding to Bit 61
		       else
                       encoderdata <= "000111100";                                   -----Corresponding to Bit 60----------######结束60-119的编码#####---------------
             end if;
       elsif(stepdata(30)= valid) then                                                ----------######开始59-0的编码#####---------------
                 if(stepdata(45)= valid) then
								if(stepdata(53)= valid) then
										 if(stepdata(57)= valid) then
											     if(stepdata(59)= valid) then
															encoderdata <= "000111011";                -----Corresponding to Bit 59
                                      elsif(stepdata(58)= valid) then
                                             encoderdata <= "000111010";                -----Corresponding to Bit 58
                                      else
                                             encoderdata <= "000111001";  	            -----Corresponding to Bit 57
                                      end if;
										 elsif(stepdata(55)= valid) then
                                      if(stepdata(56)= valid) then	
                                             encoderdata <= "000111000";	            -----Corresponding to Bit 56														
 						                    else
															encoderdata <= "000110111";	            -----Corresponding to Bit 55 
                                      end if;
                               elsif(stepdata(54)= valid) then															
                                         encoderdata <= "000110110";	                  -----Corresponding to Bit 54
                               else
													  encoderdata <= "000110101";	                  -----Corresponding to Bit 53
                               end if;
								elsif(stepdata(49)= valid) then
										 if(stepdata(51)= valid) then
												  if(stepdata(52)= valid) then 
															encoderdata <= "000110100";                -----Corresponding to Bit 52
                                      else
                                                       encoderdata <= "000110011";  	             -----Corresponding to Bit 51
                                      end if;
                               elsif(stepdata(50)= valid) then															
                                         encoderdata <= "000110010";	                         -----Corresponding to Bit 50
                               else
												     encoderdata <= "000110001";	                         -----Corresponding to Bit 49
                               end if;
								elsif(stepdata(47)= valid) then
										 if(stepdata(48)= valid) then
												  encoderdata <= "000110000";                -----Corresponding to Bit 48
                               else
                                      encoderdata <= "000101111";  	             -----Corresponding to Bit 47
                               end if;
                        elsif(stepdata(46)= valid) then															
                                  encoderdata <= "000101110";	                         -----Corresponding to Bit 46
                        else
											 encoderdata <= "000101101";	                         -----Corresponding to Bit 45
                        end if;
                 elsif(stepdata(38)= valid) then
                           if(stepdata(42)= valid) then
                                  if(stepdata(44)= valid) then										
                                         encoderdata <= "000101100";	                  -----Corresponding to Bit 44														
 						                elsif(stepdata(43)= valid) then
													  encoderdata <= "000101011";	                  -----Corresponding to Bit 43 
                                  else
													  encoderdata <= "000101010";	                  -----Corresponding to Bit 42
                                  end if;
                           elsif(stepdata(40)= valid) then
											    if(stepdata(41)= valid) then
														  encoderdata <= "000101001";                -----Corresponding to Bit 41
                                     else
                                            encoderdata <= "000101000";  	            -----Corresponding to Bit 40
                                     end if;
                           elsif(stepdata(39)= valid) then															
                                     encoderdata <= "000100111";	                         -----Corresponding to Bit 39
                           else
												 encoderdata <= "000100110";	                         -----Corresponding to Bit 38
                           end if;
                 elsif(stepdata(34)= valid) then
										if(stepdata(36)= valid) then
										       if(stepdata(37)= valid) then
														  encoderdata <= "000100101";                -----Corresponding to Bit 37
                                     else
                                            encoderdata <= "000100100";  	             -----Corresponding to Bit 36
                                     end if;
                              elsif(stepdata(35)= valid) then															
                                        encoderdata <= "000100011";	                         -----Corresponding to Bit 35
                              else
												    encoderdata <= "000100010";	                         -----Corresponding to Bit 34
                              end if;
                 elsif(stepdata(32)= valid) then
									if(stepdata(33)= valid) then
											 encoderdata <= "000100001";                -----Corresponding to Bit 33
                           else
                                  encoderdata <= "000100000";  	             -----Corresponding to Bit 32
                           end if;
                 elsif(stepdata(31)= valid) then															
                           encoderdata <= "000011111";	                         -----Corresponding to Bit 31
                 else
									encoderdata <= "000011110";	                         -----Corresponding to Bit 30
                 end if;										                       --------######结束30-59的编码#####---------------
       elsif(stepdata(15)= valid) then										              --------######开始0-29的编码#####---------------
                 if(stepdata(23)= valid) then
								if(stepdata(27)= valid) then
										 if(stepdata(29)= valid) then
												  encoderdata <= "000011101";                -----Corresponding to Bit 29
                               elsif(stepdata(28)= valid) then
                                      encoderdata <= "000011100";                -----Corresponding to Bit 28
                               else
                                      encoderdata <= "000011011";  	            -----Corresponding to Bit 27
                               end if;
								elsif(stepdata(25)= valid) then
                               if(stepdata(26)= valid) then	
                                      encoderdata <= "000011010";	            -----Corresponding to Bit 26														
 						             else
												  encoderdata <= "000011001";	            -----Corresponding to Bit 25 
                               end if;
								elsif(stepdata(24)= valid) then															
                                  encoderdata <= "000011000";	                  -----Corresponding to Bit 24
								else
											 encoderdata <= "000010111";	                  -----Corresponding to Bit 23
								end if;
                 elsif(stepdata(19)= valid) then
								   if(stepdata(21)= valid) then
											 if(stepdata(22)= valid) then 
													  encoderdata <= "000010110";                -----Corresponding to Bit 22
                                  else
                                         encoderdata <= "000010101";  	             -----Corresponding to Bit 21
                                  end if;
									elsif(stepdata(20)= valid) then															
                                     encoderdata <= "000010100";	                         -----Corresponding to Bit 20
									else
											    encoderdata <= "000010011";	                         -----Corresponding to Bit 19
                           end if;
                 elsif(stepdata(17)= valid) then
									if(stepdata(18)= valid) then
											 encoderdata <= "000010010";                -----Corresponding to Bit 18
                           else
                                  encoderdata <= "000010001";  	             -----Corresponding to Bit 17
                           end if;
                 elsif(stepdata(16)= valid) then															
                           encoderdata <= "000010000";	                         -----Corresponding to Bit 16
                 else
									encoderdata <= "000001111";	                         -----Corresponding to Bit 15
                 end if;
       elsif(stepdata(8)= valid) then										              --------######开始0-14的编码#####---------------
					  if(stepdata(12)= valid) then
								if(stepdata(14)= valid) then
										 encoderdata <= "000001110";                -----Corresponding to Bit 14
                        elsif(stepdata(13)= valid) then
                               encoderdata <= "000001101";                -----Corresponding to Bit 13
                        else
                               encoderdata <= "000001100";  	             -----Corresponding to Bit 12
                        end if;
					  elsif(stepdata(10)= valid) then
                        if(stepdata(11)= valid) then	
                               encoderdata <= "000001011";	            -----Corresponding to Bit 11														
 						      else
										 encoderdata <= "000001010";	            -----Corresponding to Bit 10 
                        end if;
					  elsif(stepdata(9)= valid) then															
                           encoderdata <= "000001001";	                  -----Corresponding to Bit 9
                 else
									encoderdata <= "000001000";	                  -----Corresponding to Bit 8
                 end if;
       elsif(stepdata(4)= valid) then
					  if(stepdata(6)= valid) then
								if(stepdata(7)= valid) then 
										 encoderdata <= "000000111";                -----Corresponding to Bit 7
                        else
                               encoderdata <= "000000110";  	             -----Corresponding to Bit 6
                        end if;
					  elsif(stepdata(5)= valid) then															
                           encoderdata <= "000000101";	                         -----Corresponding to Bit 5
					  else
									encoderdata <= "000000100";	                         -----Corresponding to Bit 4
                 end if;
       elsif(stepdata(2)= valid) then
					  if(stepdata(3)= valid) then 
								encoderdata <= "000000011";                -----Corresponding to Bit 3
                 else
                        encoderdata <= "000000010";  	             -----Corresponding to Bit 2
                 end if;
		 elsif(stepdata(1)= valid) then															
                 encoderdata <= "000000001";	                         -----Corresponding to Bit 1
		 else
		           encoderdata <= "000000000";			  -----Corresponding to Bit 0
       end if;
end process;		 
		 
process(stepdata(249 downto 240))
begin
if 	   stepdata(249 downto 240) = "0000000001" then
EncodeData_tmp <="011110000";
elsif 	stepdata(249 downto 240) = "0000000011" then
EncodeData_tmp <="011110001";
elsif 	stepdata(249 downto 240) = "0000000111" then
EncodeData_tmp <="011110010";
elsif 	stepdata(249 downto 240) = "0000001111" then
EncodeData_tmp <="011110011";
elsif 	stepdata(249 downto 240) = "0000011111" then
EncodeData_tmp <="011110100";
elsif 	stepdata(249 downto 240) = "0000111111" then
EncodeData_tmp <="011110101";
elsif 	stepdata(249 downto 240) = "0001111111" then
EncodeData_tmp <="011110110";
elsif 	stepdata(249 downto 240) = "0011111111" then
EncodeData_tmp <="011110111";
elsif 	stepdata(249 downto 240) = "0111111111" then
EncodeData_tmp <="011111000";
elsif 	stepdata(249 downto 240) = "1111111111" then
EncodeData_tmp <="011111001"; 
else
EncodeData_tmp <="000000000";
end if;
end process;

process(stepdata(259 downto 250))
begin
if 	   stepdata(259 downto 250) = "0000000001" then
EncodeData_tmp1 <="011111010";
elsif 	stepdata(259 downto 250) = "0000000011" then
EncodeData_tmp1 <="011111011";
elsif 	stepdata(259 downto 250) = "0000000111" then
EncodeData_tmp1 <="011111100";
elsif 	stepdata(259 downto 250) = "0000001111" then
EncodeData_tmp1 <="011111101";
elsif 	stepdata(259 downto 250) = "0000011111" then
EncodeData_tmp1 <="011111110";
elsif 	stepdata(259 downto 250) = "0000111111" then
EncodeData_tmp1 <="011111111";
elsif 	stepdata(259 downto 250) = "0001111111" then
EncodeData_tmp1 <="100000000";
elsif 	stepdata(259 downto 250) = "0011111111" then
EncodeData_tmp1 <="100000001";
elsif 	stepdata(259 downto 250) = "0111111111" then
EncodeData_tmp1 <="100000010";
elsif 	stepdata(259 downto 250) = "1111111111" then
EncodeData_tmp1 <="100000011";
else
EncodeData_tmp1 <="000000000";
end if;
end process;


process(stepdata(269 downto 260))
begin
if 	   stepdata(269 downto 260) = "0000000001" then
EncodeData_tmp2 <="100000100";
elsif 	stepdata(269 downto 260) = "0000000011" then
EncodeData_tmp2 <="100000101";
elsif 	stepdata(269 downto 260) = "0000000111" then
EncodeData_tmp2 <="100000110";
elsif 	stepdata(269 downto 260) = "0000001111" then
EncodeData_tmp2 <="100000111";
elsif 	stepdata(269 downto 260) = "0000011111" then
EncodeData_tmp2 <="100001000";
elsif 	stepdata(269 downto 260) = "0000111111" then
EncodeData_tmp2 <="100001001";
elsif 	stepdata(269 downto 260) = "0001111111" then
EncodeData_tmp2 <="100001010";
elsif 	stepdata(269 downto 260) = "0011111111" then
EncodeData_tmp2 <="100001011";
elsif 	stepdata(269 downto 260) = "0111111111" then
EncodeData_tmp2 <="100001100";
elsif 	stepdata(269 downto 260) = "1111111111" then
EncodeData_tmp2 <="100001101";
else
EncodeData_tmp2 <="000000000";
end if;
end process;

process(stepdata(279 downto 270))
begin
if 	   stepdata(279 downto 270) = "0000000001" then
EncodeData_tmp3 <="100001110";
elsif 	stepdata(279 downto 270) = "0000000011" then
EncodeData_tmp3 <="100001111";
elsif 	stepdata(279 downto 270) = "0000000111" then
EncodeData_tmp3 <="100010000";
elsif 	stepdata(279 downto 270) = "0000001111" then
EncodeData_tmp3 <="100010001";
elsif 	stepdata(279 downto 270) = "0000011111" then
EncodeData_tmp3 <="100010010";
elsif 	stepdata(279 downto 270) = "0000111111" then
EncodeData_tmp3 <="100010011";
elsif 	stepdata(279 downto 270) = "0001111111" then
EncodeData_tmp3 <="100010100";
elsif 	stepdata(279 downto 270) = "0011111111" then
EncodeData_tmp3 <="100010101";
elsif 	stepdata(279 downto 270) = "0111111111" then
EncodeData_tmp3 <="100010110";
elsif 	stepdata(279 downto 270) = "1111111111" then
EncodeData_tmp3 <="100010111";
else
EncodeData_tmp3 <="000000000";
end if;
end process;

process(stepdata(289 downto 280))
begin
if 	   stepdata(289 downto 280) = "0000000001" then
EncodeData_tmp4 <="100011000";
elsif 	stepdata(289 downto 280) = "0000000011" then
EncodeData_tmp4 <="100011001";
elsif 	stepdata(289 downto 280) = "0000000111" then
EncodeData_tmp4 <="100011010";
elsif 	stepdata(289 downto 280) = "0000001111" then
EncodeData_tmp4 <="100011011";
elsif 	stepdata(289 downto 280) = "0000011111" then
EncodeData_tmp4 <="100011100";
elsif 	stepdata(289 downto 280) = "0000111111" then
EncodeData_tmp4 <="100011101";
elsif 	stepdata(289 downto 280) = "0001111111" then
EncodeData_tmp4 <="100011110";
elsif 	stepdata(289 downto 280) = "0011111111" then
EncodeData_tmp4 <="100011111";
elsif 	stepdata(289 downto 280) = "0111111111" then
EncodeData_tmp4 <="100100000";
elsif 	stepdata(289 downto 280) = "1111111111" then
EncodeData_tmp4 <="100100001";
else
EncodeData_tmp4 <="000000000";
end if;
end process;

process(stepdata(299 downto 290))
begin
if 	   stepdata(299 downto 290) = "0000000001" then
EncodeData_tmp5 <="100100010";
elsif 	stepdata(299 downto 290) = "0000000011" then
EncodeData_tmp5 <="100100011";
elsif 	stepdata(299 downto 290) = "0000000111" then
EncodeData_tmp5 <="100100100";
elsif 	stepdata(299 downto 290) = "0000001111" then
EncodeData_tmp5 <="100100101";
elsif 	stepdata(299 downto 290) = "0000011111" then
EncodeData_tmp5 <="100100110";
elsif 	stepdata(299 downto 290) = "0000111111" then
EncodeData_tmp5 <="100100111";
elsif 	stepdata(299 downto 290) = "0001111111" then
EncodeData_tmp5 <="100101000";
elsif 	stepdata(299 downto 290) = "0011111111" then
EncodeData_tmp5 <="100101001";
elsif 	stepdata(299 downto 290) = "0111111111" then
EncodeData_tmp5 <="100101010";
elsif 	stepdata(299 downto 290) = "1111111111" then
EncodeData_tmp5 <="100101011";
else
EncodeData_tmp5 <="000000000";
end if;
end process;

FineData <= encoderdata when StepData(240)='0' else
            EncodeData_tmp when StepData(250)='0' else
				EncodeData_tmp1 when StepData(260)='0' else
				EncodeData_tmp2 when StepData(270)='0' else
				EncodeData_tmp3 when StepData(280)='0' else
				EncodeData_tmp4 when StepData(290)='0' else
				EncodeData_tmp5;


end Behavioral;


