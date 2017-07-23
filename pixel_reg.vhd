library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pixel_reg is
  Port ( clk,rstn : in std_logic;
         up_lo_byte : in std_logic; -- '0' <=> read lo byte.
         pixrg : out unsigned(7 downto 0);
         -- RAM signals
         higher_byte : in unsigned(7 downto 0);
         lower_byte : in unsigned(7 downto 0));
end pixel_reg;

architecture rtl of pixel_reg is
begin
	pixrg <= higher_byte when up_lo_byte = '1' else
	lower_byte;
end rtl;

