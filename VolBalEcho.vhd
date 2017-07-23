
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity Vol_Bal_Echo is
  port(clk, sel,rstn : in std_logic; 
		 Parameters_Echo : in unsigned (3 downto 0);
		 RADC_Echo : in signed (15 downto 0);
		 LADC_Echo : in signed (15 downto 0);
		 RDAC_Echo : out signed (15 downto 0);
		 LDAC_Echo : out signed (15 downto 0);
		 Volume_Echo : out unsigned (3 downto 0);
		 Balance_Echo : out signed (4 downto 0));
end entity;

architecture Vo_Ba of Vol_Bal_Echo is
  signal volume_Echo_int : unsigned (3 downto 0);
  signal balance_Echo_int : signed (4 downto 0);
  signal balance_Echo_int_gauche : signed (4 downto 0);
  signal parameters_Echo_int : unsigned (3 downto 0);
  signal RDAC_Echo_Vol_Initial : signed (15 downto 0);
  signal LDAC_Echo_Vol_Initial : signed (15 downto 0);
  signal LDAC_Echo_Vol1 : signed (15 downto 0);
  signal RDAC_Echo_Vol1 : signed (15 downto 0);
  signal LDAC_Echo_Vol2 : signed (15 downto 0);
  signal RDAC_Echo_Vol2 : signed (15 downto 0);
  signal LDAC_Echo_Vol3 : signed (15 downto 0);
  signal RDAC_Echo_Vol3 : signed (15 downto 0);
  signal LDAC_Echo_Vol_Final : signed (15 downto 0);
  signal RDAC_Echo_Vol_Final : signed (15 downto 0);
  signal RDAC_Echo_Bal_Initial : signed (15 downto 0);
  signal LDAC_Echo_Bal_Initial : signed (15 downto 0);
  signal LDAC_Echo_Bal1 : signed (15 downto 0);
  signal RDAC_Echo_Bal1 : signed (15 downto 0);
  signal LDAC_Echo_Bal2 : signed (15 downto 0);
  signal RDAC_Echo_Bal2 : signed (15 downto 0);
  signal LDAC_Echo_Bal3 : signed (15 downto 0);
  signal RDAC_Echo_Bal3 : signed (15 downto 0);
  signal LDAC_Echo_Bal_Final : signed (15 downto 0);
  signal RDAC_Echo_Bal_Final : signed (15 downto 0);
  
  signal sel_old, sel_change : std_logic := '0';
  function asr(slv : signed; n : natural) return signed is begin
    return (slv'left downto slv'left-n+1 => slv(slv'left)) & slv(slv'left downto n);
  end function;

begin


--------------------------------------------
	--pb initialiser des valeurs balance, volume echo mute
   	
	process(clk)
	begin
		if(rstn = '0') then
				volume_Echo_int <= "0101";
				balance_Echo_int <= "00000";
		
		elsif rising_edge(clk) then
		
			parameters_Echo_int <=parameters_Echo; --parameters
	
			--controle du volume
			
			if (parameters_Echo_int(0)='1') then
				if volume_Echo_int >=1  then
					volume_Echo_int <= volume_Echo_int - 1;
				end if ;
			end if;
			
			if (parameters_Echo_int(1)='1') then
				if volume_Echo_int <=10 then
					volume_Echo_int <= volume_Echo_int + 1;
				end if ;
			end if;

			-- controle de balance
			if (parameters_Echo_int(2)='1') then
				if balance_Echo_int <8  then
					balance_Echo_int <= balance_Echo_int + 1;
				end if ;
			end if;
			if (parameters_Echo_int(3)='1') then
				if balance_Echo_int > -8  then
					balance_Echo_int <= balance_Echo_int + "11111";
				end if ;
			end if;

-------------outputs-------------------------------
			Volume_Echo <= Volume_Echo_Int;
			Balance_Echo <= Balance_Echo_Int;


-----------------VOLUME---------------------------

			if volume_Echo_int(3)='1' then
				RDAC_Echo_Vol1 <= asr(RADC_Echo,4) ;
  				LDAC_Echo_Vol1 <= asr(LADC_Echo,4) ;
			else
				RDAC_Echo_Vol1 <= RADC_Echo ;
				LDAC_Echo_Vol1 <= LADC_Echo ;
			end if;
			
			if volume_Echo_int(2)='1' then
				RDAC_Echo_Vol2 <= asr(RDAC_Echo_Vol1,2) ;
  				LDAC_Echo_Vol2 <= asr(LDAC_Echo_Vol1,2) ;
			else
				RDAC_Echo_Vol2 <= RDAC_Echo_Vol1 ;
				LDAC_Echo_Vol2 <= LDAC_Echo_Vol1 ;
			end if;
			
			if volume_Echo_int(1)='1' then
				RDAC_Echo_Vol3 <= asr(RDAC_Echo_Vol2,1) ;
  				LDAC_Echo_Vol3 <= asr(LDAC_Echo_Vol2,1) ;
			else
				RDAC_Echo_Vol3 <= RDAC_Echo_Vol2 ;
				LDAC_Echo_Vol3 <= LDAC_Echo_Vol2 ;
			end if;
			
			if volume_Echo_int(0)='1' then
				RDAC_Echo_Vol_Final <= RDAC_Echo_Vol3 - asr(RDAC_Echo_Vol3,2) ;
  				LDAC_Echo_Vol_Final <= LDAC_Echo_Vol3 - asr(LDAC_Echo_Vol3,2) ;
			else
				RDAC_Echo_Vol_Final <= RDAC_Echo_Vol3 ;
				LDAC_Echo_Vol_Final <= LDAC_Echo_Vol3 ;
			end if;
	
-------------------BALANCE-------------------------

			LDAC_Echo_Bal_Initial <= LDAC_Echo_Vol_Final;
			RDAC_Echo_Bal_Initial <= RDAC_Echo_Vol_Final;
		
			if (balance_Echo_int(4)='1') then
				balance_Echo_int_gauche <= (balance_Echo_int(4) & not balance_Echo_int(3) & not balance_Echo_int(2) & not balance_Echo_int(1) & not balance_Echo_int(0)) +1;
				if (balance_Echo_int(3)='1') then
  					RDAC_Echo_Bal1 <= "0000000000000000";
				else
					RDAC_Echo_Bal1 <= RDAC_Echo_Bal_Initial;
				end if;
				
				if (balance_Echo_int(2)='1') then
  					RDAC_Echo_Bal2 <= RDAC_Echo_Bal1 - asr(RDAC_Echo_Bal1,1) ;
				else
					RDAC_Echo_Bal2 <= RDAC_Echo_Bal1;
				end if;
				
				if (balance_Echo_int(1)='1') then
  					RDAC_Echo_Bal3 <= RDAC_Echo_Bal2 - asr(RDAC_Echo_Bal2,2) ;
				else
					RDAC_Echo_Bal3 <= RDAC_Echo_Bal2;
				end if;
				
				if (balance_Echo_int(0)='1') then
  					RDAC_Echo_Bal_Final <= RDAC_Echo_Bal3 - asr(RDAC_Echo_Bal3,3) ;
				else
					RDAC_Echo_Bal_Final <= RDAC_Echo_Bal3;
				end if;
				LDAC_Echo_Bal_Final <= LDAC_Echo_Bal_Initial;		
		
			else --a4=0
				if (balance_Echo_int(3)='1') then
  					LDAC_Echo_Bal1 <= "0000000000000000";
				else
					LDAC_Echo_Bal1 <= LDAC_Echo_Bal_Initial;
				end if;
				
				if (balance_Echo_int(2)='1') then
  					LDAC_Echo_Bal2 <= LDAC_Echo_Bal1 - asr(LDAC_Echo_Bal1,1) ;
				else
					LDAC_Echo_Bal2 <= LDAC_Echo_Bal1;
				end if;
				
				if (balance_Echo_int(1)='1') then
  					LDAC_Echo_Bal3 <= LDAC_Echo_Bal2 - asr(LDAC_Echo_Bal2,2) ;
				else
					LDAC_Echo_Bal3 <= LDAC_Echo_Bal2;
				end if;
				
				if (balance_Echo_int(0)='1') then
  					LDAC_Echo_Bal_Final <= LDAC_Echo_Bal3 - asr(LDAC_Echo_Bal3,3) ;
				else
					LDAC_Echo_Bal_Final <= LDAC_Echo_Bal3;
				end if;		
			    RDAC_Echo_Bal_Final <= RDAC_Echo_Bal_Initial;
				
			end if;
	
------------------OUTPUTS--------------------------

				sel_old <= sel;
				sel_change <= sel_old xor sel;
				if (sel_change = '1' and sel = '1') then -- activate left channel
					LDAC_Echo <= LDAC_Echo_Bal_Final;
				elsif (sel_change = '1' and sel = '0') then -- activate right channel
					RDAC_Echo <= RDAC_Echo_Bal_Final;
				end if;
		end if;
	end process;			
end Vo_Ba;