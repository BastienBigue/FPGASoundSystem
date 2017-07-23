library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity ctrl is
  port(clk : in std_logic;
		 rstn : in std_logic;
		 mclk, bclk, adclrc, daclrc, lrsel, men : out std_logic;
		 BitCnt : out unsigned (4 downto 0);
		 SCCnt : out unsigned (1 downto 0));

end entity;

architecture inst_ctrl of ctrl is
  signal cntr : unsigned (9 downto 0) := "1111111111";
begin
	process(clk,rstn)
	begin
		if rstn='0' then
			--mclk <= '0';
			--bclk <= '0';
			--SCCnt <= "00";
			--BitCnt <= "00000";
			--cntr <= "1111111111";	
		elsif rising_edge(clk) then
			if cntr = 1023 then
				cntr <= "0000000000";
			else
			   cntr <= cntr + 1;
			end if ;
		end if;
	end process;	
			SCCnt <= cntr(3 downto 2);
			BitCnt <= cntr(8 downto 4);
			mclk <= not cntr(1);
			bclk <= cntr(3);
			men <= cntr(1) and cntr(0);
			lrsel <= cntr(9) ;
			adclrc <= not cntr(9);
			daclrc <= not cntr(9);
end inst_ctrl;