library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Gen_Pixel is
  port(clk,rstn: in std_logic; 
	hcnt, vcnt : in unsigned(9 downto 0);
	echo_Volume, main_Volume : in unsigned (3 downto 0);
	echo_Balance, main_Balance : in signed (4 downto 0);	
	mute, echo_activated: in std_logic;
	echo_length : in unsigned(1 downto 0);
	color_code : out unsigned (1 downto 0));
end entity;
--VOLUME = 0 MEANS LEVEL MAX OF THE VOLUME (NO DIVISION)------------------------------------
architecture rtl of Gen_Pixel is
begin
	process(clk, rstn)
	begin
		if(rstn = '0') then
				color_code <= "00";
		elsif rising_edge(clk) then  
			if ((200 < hcnt) and (hcnt < 300) and (58 < vcnt) and (vcnt < 300)) then		--DISPLAY OF MAIN VOLUME
				if (mute = '0') then -- IF MUTE IS ACTIVATED, ALL THE AREA IS GREY
					if ((300-((11-to_integer(main_Volume))*22)< vcnt) and (vcnt < 300)) then -- MATHEMATICAL FUNCTION FOR THE MAIN VOLUME AREA
						color_code<="01"; --01 = GREEN COLOR CODE
					else
						color_code<="10"; -- 10 = GREY COLOR CODE
					end if;
				else
					color_code<="10"; -- 10 = GREY COLOR CODE
				end if;
			elsif ((200 < hcnt) and (hcnt < 300) and (299 < vcnt) and (vcnt < 322)) then -- DISPLAY OF ONE LITTLE BAR UNDER THE MODULABLE BAR SO THAT THERE IS STILL COLOR WHEN THE LEVEL VALUE IS THE LOWEST.
				if (mute = '0') then -- DISPLAY IN GREEN JUST IF THE MUTE IS NOT ACTIVATED
					color_code<="01"; -- 01 = GREEN COLOR CODE
				else
					color_code<="10"; -- 10 = GREY COLOR CODE
				end if;
				
--================================================================================================================--
			elsif ((100 < hcnt) and (hcnt < 404) and (380 < vcnt) and (vcnt < 430)) then 	--DISPLAY OF THE MAIN BALANCE 
			-- 17 possible values for the balance =>> 17 intervals
				if ((main_Balance(4) = '0') and ((main_Balance(3) = '1') or (main_Balance(2) = '1') or (main_Balance(1) = '1') or (main_Balance(0) = '1'))) then -- LEFT BALANCE
					if ((253+((to_integer(main_Balance))*19) > hcnt) and (hcnt > 253)) then 
						color_code <= "11" ; --WE DISPLAY THIS INTERVAL IN BLUE
					else 
						color_code <= "10" ; -- WE DISPLAY THIS INTERVAL IN GREY
					end if ; 

				elsif (main_Balance(4) = '1') then -- RIGHT BALANCE
					if ((252 > hcnt) and (hcnt > 252+((to_integer(main_Balance))*19))) then 
						color_code <= "11" ; --WE DISPLAY THIS INTERVAL IN BLUE
					else 
						color_code <= "10" ; -- WE DISPLAY THIS INTERVAL in GREY
					end if ; 

				else -- IF THE BALANCE = 0 THEN ALL THE AREA IS GREY
					color_code <= "10" ; 
				end if ; 
--================================================================================================================--			 
			elsif ((509 < hcnt) and (hcnt < 559) and (58 < vcnt) and (vcnt < 300)) then		--DISPLAY OF THE ECHO VOLUME
				if (echo_activated = '1') then --WE ONLY DISPLAY THIS IF THE ECHO IS ACTIVATED
					if (mute='0') then -- IF THE ECHO IS ACTIVATED, ALL THE AREA IS GREY
						if ((300-((11-to_integer(echo_Volume))*22)< vcnt) and (vcnt < 300)) then 
							color_code<="01"; --0001 = GREEN COLOR CODE
						else
							color_code<="10"; -- 0010 = GREY COLOR CODE
						end if;
					else
						color_code<="10"; -- 0010 = GREY COLOR CODE
					end if;
				end if;
			
			elsif ((509 < hcnt) and (hcnt < 559) and (299 < vcnt) and (vcnt < 322)) then
				if (echo_activated = '1') then
					if (mute = '0') then
						color_code<="01"; -- 0001 = GREEN COLOR CODE
					else
						color_code<="10"; -- 0010 = GREY COLOR CODE
					end if;
				end if;
--================================================================================================================--
			elsif ((454 < hcnt) and (hcnt < 614) and (380 < vcnt) and (vcnt < 430)) then 	--DISPLAY OF THE ECHO BALANCE
				if (echo_activated = '1') then -- WE ONLY DISPLAY THIS IF THE ECHO IS ACTIVATED
					if ((echo_Balance(4) = '0') and ((echo_Balance(3) = '1') or (echo_Balance(2) = '1') or (echo_Balance(1) = '1') or (echo_Balance(0) = '1'))) then 
						if ((535+((to_integer(echo_Balance))*10) > hcnt) and (hcnt > 535)) then 
							color_code <= "11" ; --BLUE COLOR CODE
						else 
							color_code <= "10" ; -- GREY COLOR CODE
						end if ; 
					elsif (echo_Balance(4) = '1') then 
						if ((534 > hcnt) and (hcnt > 534+(to_integer(echo_Balance))*10)) then 
							color_code <= "11" ; --BLUE COLOR CODE
						else 
							color_code <= "10" ; -- GREY COLOR CODE
						end if ; 
					else -- IF THE BALANCE = 0, ALL THE AREA IS GREY
						color_code <= "10" ; 
					end if ; 
				end if;
--================================================================================================================--
			elsif ((454 < hcnt) and (hcnt < 494) and (350 < vcnt) and (vcnt < 370)) then -- DISPLAY OF ECHO LENGTH
				if (echo_activated = '1') then
					color_code <= "01"; -- GREN COLOR CODE
				end if;
			elsif ((493 < hcnt) and (hcnt < 613) and (350 < vcnt) and (vcnt < 370)) then
				if (echo_activated = '1') then
					if ((493 < hcnt) and (hcnt <(493+(to_integer(echo_length))*40)) and (350 < vcnt) and (vcnt < 370)) then
						color_code <= "01"; -- GREEN COLOR CODE
					else
						color_code <= "10"; -- GREY CODE
					end if;
				end if;
--================================================================================================================--
			else -- NO SETTINGS AREA, THE COLOR CODE IS THE COLOR CODE FOR THE WHITE
				color_code <= "00" ; 
			end if  ; 
		end if;
	end process;
end rtl;
  
