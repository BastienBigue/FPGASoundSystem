library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity clock_gen is
  Port ( fpga_clk : in std_logic;
         vga_clk : out std_logic);
end clock_gen;

architecture rtl of clock_gen is
  signal clki : std_logic := '1';
  begin
  p1 : process(fpga_clk) is
	begin
		if rising_edge(fpga_clk) then
			vga_clk <= clki;
			clki <= not clki;
		end if;
	end process;
end rtl;