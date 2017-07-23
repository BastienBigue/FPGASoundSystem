library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity left_channel is
  port(clk, men, sel, adcdat : in std_logic;
		 BitCnt : in unsigned (4 downto 0);
		 SCCnt : in unsigned (1 downto 0);
		 DAC : in signed (15 downto 0);
		 dacdat : out std_logic;
		 ADC : out signed (15 downto 0));
end entity;

architecture inst_left of left_channel is
  signal RXReg : signed (15 downto 0);
  signal TXReg : signed (15 downto 0);
begin
--------------------------------------------
	rx : process(clk)
	begin
		if rising_edge(clk) then
			if sel='0' then
				if (SCCnt = "01") and men='1' then
				RXReg(15 downto 1) <= RXReg(14 downto 0);
				--RXreg(0) <= adcdat;
				end if ;
			--else
				--ADC <= RXReg;
			end if;
		end if;
	end process;
	RXreg(0) <= adcdat;
	ADC <= RXReg;
--------------------------------------------
	dacdat <= TXreg(15);
	tx : process(clk)
	begin
		if rising_edge(clk) then
			if sel='0' then
				if (SCCnt="11") and men='1' then
				--dacdat <= TXreg(15);
				TXReg(15 downto 1) <= TXReg(14 downto 0);
				end if ;
			else
			  TXReg <= DAC;
			end if;
		end if;
	end process;
--	TXReg <= DAC;
--------------------------------------------
			
end inst_left;