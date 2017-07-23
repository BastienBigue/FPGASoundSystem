library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Writing_SRAM is
Port ( 	clk, rstn,lrsel,we  : in std_logic; 
		LADC,RADC : in signed(15 downto 0);
		data : out signed(15 downto 0));
end Writing_SRAM;

architecture rtl of Writing_SRAM is
signal rise_change, fall_change : std_logic;
begin
	process(clk, rstn, lrsel)
	begin
		if(rstn = '0') then
			data <= "ZZZZZZZZZZZZZZZZ";
		elsif rising_edge(clk) then
			if (lrsel = '1') and (we='0') then
				data <= LADC(15 downto 0) ;
			elsif lrsel='0' and (we='0') then
				data <= RADC(15 downto 0) ;
			else -- Allow the reading step
				data <= "ZZZZZZZZZZZZZZZZ" ;
			end if;
		end if;
	end process;
end rtl;
