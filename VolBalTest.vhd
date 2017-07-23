
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity Vol_Bal is
  port(clk, sel,rstn : in std_logic; 
		 Parameters : in unsigned (5 downto 0);
		 RADC_MP3 : in signed (15 downto 0);
		 LADC_MP3 : in signed (15 downto 0);
		 RADC_Synth : in signed (15 downto 0);
		 LADC_Synth : in signed (15 downto 0);
		 RADC_Echo : in signed (15 downto 0);
		 LADC_Echo : in signed (15 downto 0);
		 --dacdat : out std_logic;
		 RDAC : out signed (15 downto 0);
		 LDAC : out signed (15 downto 0);
		 Echo, Mute : out std_logic;
		 Volume : out unsigned (3 downto 0);
		 Balance : out signed (4 downto 0));
end entity;

architecture Vo_Ba of Vol_Bal is
  signal volume_int : unsigned (3 downto 0);
  signal balance_int : signed (4 downto 0);
  signal balance_int_gauche : signed (4 downto 0);
  signal echo_int, mute_int : std_logic;
  signal parameters_int : unsigned (5 downto 0);
  signal RDAC_Vol_Initial : signed (15 downto 0);
  signal LDAC_Vol_Initial : signed (15 downto 0);
  signal LDAC_Vol1 : signed (15 downto 0);
  signal RDAC_Vol1 : signed (15 downto 0);
  signal LDAC_Vol2 : signed (15 downto 0);
  signal RDAC_Vol2 : signed (15 downto 0);
  signal LDAC_Vol3 : signed (15 downto 0);
  signal RDAC_Vol3 : signed (15 downto 0);
  signal LDAC_Vol_Final : signed (15 downto 0);
  signal RDAC_Vol_Final : signed (15 downto 0);
  signal RDAC_Bal_Initial : signed (15 downto 0);
  signal LDAC_Bal_Initial : signed (15 downto 0);
  signal LDAC_Bal1 : signed (15 downto 0);
  signal RDAC_Bal1 : signed (15 downto 0);
  signal LDAC_Bal2 : signed (15 downto 0);
  signal RDAC_Bal2 : signed (15 downto 0);
  signal LDAC_Bal3 : signed (15 downto 0);
  signal RDAC_Bal3 : signed (15 downto 0);
  signal LDAC_Bal_Final : signed (15 downto 0);
  signal RDAC_Bal_Final : signed (15 downto 0);
  signal sel_old, sel_change : std_logic := '0';
  
  function asr(slv : signed; n : natural) return signed is begin
    return (slv'left downto slv'left-n+1 => slv(slv'left)) & slv(slv'left downto n);
  end function;

begin


--------------------------------------------	
	process(clk)
	begin
	
	
		if(rstn = '0') then
			volume_int <= "0101";
			balance_int <= "00000";
			echo_int <= '0';
			mute_int<= '0';
		    parameters_int <= "000000";	
		elsif rising_edge(clk) then
	
			--controle du volume
			parameters_int <= parameters;
			
			if (parameters_int(0)='1') then
				if volume_int >= 1  then
					volume_int <= volume_int - 1;
				end if ;
			end if;
			
			if (parameters_int(1)='1') then
				if volume_int <= 10  then
					volume_int <= volume_int + 1; -- UTurn up volume --> level +1 ( more division)
				end if ;
			end if;
	
			-- controle de balance
			if (parameters_int(2)='1' and balance_int < 8) then
					balance_int <= balance_int + 1;
			end if;
			if (parameters_int(3)='1' and balance_int > -8 ) then
					balance_int <= balance_int + "11111";
			end if;

			--activation du mute
				Mute_Int <= parameters_int(4);
			--activation de l'echo
				Echo_Int <=parameters_int(5);
				
--------------------------------------------
	--outputs
			 Volume <= Volume_Int;
			 Balance <= Balance_Int;
			 Echo <= Echo_int;
			 Mute <= Mute_int;

-------------------------------
	
			if echo_int='1' then
				RDAC_Vol_Initial <= asr(RADC_MP3,1) + asr(RADC_Echo,1)+ RADC_Synth  ;
  				LDAC_Vol_Initial <= asr(LADC_MP3,1) + asr(LADC_Echo,1)+ LADC_Synth  ;
			else
				RDAC_Vol_Initial <=  asr(RADC_MP3,1) + RADC_Synth ; 
  				LDAC_Vol_Initial <=  asr(LADC_MP3,1) + LADC_Synth ; 
			end if;
	
-----------------VOLUME---------------------------


			if volume_int(3)='1' then
				RDAC_Vol1 <= asr(RDAC_Vol_Initial,4) ;
  				LDAC_Vol1 <= asr(LDAC_Vol_Initial,4) ;
			else
				RDAC_Vol1 <= RDAC_Vol_Initial ;
				LDAC_Vol1 <= LDAC_Vol_Initial ;
			end if;
			
			if volume_int(2)='1' then
				RDAC_Vol2 <= asr(RDAC_Vol1,2) ;
  				LDAC_Vol2 <= asr(LDAC_Vol1,2) ;
			else
				RDAC_Vol2 <= RDAC_Vol1 ;
				LDAC_Vol2 <= LDAC_Vol1 ;
			end if;
			
			if volume_int(1)='1' then
				RDAC_Vol3 <= asr(RDAC_Vol2,1) ;
  				LDAC_Vol3 <= asr(LDAC_Vol2,1) ;
			else
				RDAC_Vol3 <= RDAC_Vol2 ;
				LDAC_Vol3 <= LDAC_Vol2 ;
			end if;
			
			if volume_int(0)='1' then
				RDAC_Vol_Final <= RDAC_Vol3 - asr(RDAC_Vol3,2) ;
  				LDAC_Vol_Final <= LDAC_Vol3 - asr(LDAC_Vol3,2) ;
			else
				RDAC_Vol_Final <= RDAC_Vol3 ;
				LDAC_Vol_Final <= LDAC_Vol3 ;
			end if;
	
-------------------BALANCE-------------------------

			LDAC_Bal_Initial <= LDAC_Vol_Final;
			RDAC_Bal_Initial <= RDAC_Vol_Final;
		
			if (balance_int(4)='1') then
				balance_int_gauche <= (balance_int(4) & not balance_int(3) & not balance_int(2) & not balance_int(1) & not balance_int(0)) +1;
		
				if (balance_int_gauche(3)='1') then
  					RDAC_Bal1 <= "0000000000000000";
				else
					RDAC_Bal1 <= RDAC_Bal_Initial;
				end if;
				
				if (balance_int_gauche(2)='1') then
  					RDAC_Bal2 <= RDAC_Bal1 - asr(RDAC_Bal1,1) ;
					else
					RDAC_Bal2 <= RDAC_Bal1;
				end if;
				
				if (balance_int_gauche(1)='1') then
  					RDAC_Bal3 <= RDAC_Bal2 - asr(RDAC_Bal2,2) ;
					else
					RDAC_Bal3 <= RDAC_Bal2;
				end if;
				
				if (balance_int_gauche(0)='1') then
  					RDAC_Bal_Final <= RDAC_Bal3 - asr(RDAC_Bal3,3) ;
				else
					RDAC_Bal_Final <= RDAC_Bal3;
				end if;
				LDAC_Bal_Final <= LDAC_Bal_Initial;	
		
			else --a4=0
				if (balance_int(3)='1') then
  					LDAC_Bal1 <= "0000000000000000";
				else
					LDAC_Bal1 <= LDAC_Bal_Initial;
				end if;
				
				if (balance_int(2)='1') then
  					LDAC_Bal2 <= LDAC_Bal1 - asr(LDAC_Bal1,1) ;
					else
					LDAC_Bal2 <= LDAC_Bal1;
				end if;
				
				if (balance_int(1)='1') then
  					LDAC_Bal3 <= LDAC_Bal2 - asr(LDAC_Bal2,2) ;
					else
					LDAC_Bal3 <= LDAC_Bal2;
				end if;
				
				if (balance_int(0)='1') then
  					LDAC_Bal_Final <= LDAC_Bal3 - asr(LDAC_Bal3,3) ;
				else
					LDAC_Bal_Final <= LDAC_Bal3;

				end if;		
			    RDAC_Bal_Final <= RDAC_Bal_Initial;	
			end if;
	
------------------OUTPUTS--------------------------

			sel_old <= sel;
			sel_change <= sel_old xor sel;
			if (mute_int = '0') then
				if (sel_change = '1' and sel = '1') then -- activate left channel
					LDAC <= LDAC_Bal_Final;
				elsif (sel_change = '1' and sel = '0') then -- activate right channel
					RDAC <= RDAC_Bal_Final;
				end if;
			else
				LDAC <= "0000000000000000";
				RDAC <= "0000000000000000";
			end if;	
		end if;
	end process;		
end Vo_Ba;