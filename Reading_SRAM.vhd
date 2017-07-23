library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Reading_SRAM is
Port (clk, rstn,lrsel, enable_reading  : in std_logic; 
	data : in signed(15 downto 0);
	LADC,RADC : out signed(15 downto 0));
end Reading_SRAM;

architecture rtl of Reading_SRAM is
begin
	process(clk, rstn, lrsel, enable_reading)
	begin
		if (rstn = '0')  then
			LADC <= "0000000000000000";
			RADC <= "0000000000000000" ;
		elsif (enable_reading='0') then
			LADC <= "0000000000000000";
			RADC <="0000000000000000" ;
		elsif rising_edge(clk) then
			if lrsel='1' then
				LADC(15 downto 0) <= data  ;
			else
				RADC(15 downto 0) <= data  ;
			end if;
		end if;
	end process;
end rtl;
