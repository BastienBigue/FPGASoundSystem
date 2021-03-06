library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity hsyncr is
  Port ( clk : in std_logic;
         hcnt : in unsigned(9 downto 0);
         rstn : in std_logic;
         hsync : out std_logic);
end hsyncr;

architecture rtl of hsyncr is
	constant DEL : integer := 2; -- delay hsync DEL pixels to compensate for pipelining.
begin
	process(rstn, clk)
	begin
		if (rstn = '0') then
		    hsync <= '1';
		elsif (rising_edge(clk)) then
			if hcnt = 640+15+DEL-1 then       -- turn ON here
				hsync <= '0';
			elsif hcnt = 640+15+95+DEL-1 then -- turn OFF here
				hsync <= '1';
		    end if; -- Let it keep its value in between (An "=" test operation
				  --  is often simpler than a "<" test operation in hardware).
		end if;
  end process;
end rtl;
