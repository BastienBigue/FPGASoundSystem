library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SRAM_control is
  Port ( clk,rstn,lrsel   : in std_logic;
		 cntrlecho : in unsigned(1 downto 0);
		 addr : out unsigned(17 downto 0);
		 enable_reading : out std_logic;
		 sram_ce,sram_oe,sram_we : out std_logic; -- enable chip, -- enable output -- enable writing 
         sram_lb,sram_ub         : out std_logic; 
		 longecho : out  unsigned(1 downto 0));
end SRAM_control;

architecture rtl of SRAM_control is
signal compteur : unsigned (8 downto 0);
signal address : unsigned(17 downto 0);
signal cntrlecho_int : unsigned(1 downto 0);

begin  
	process(clk, rstn, lrsel)
    begin
		if(rstn = '0') then   --compteur until 512
			compteur <= (others => '0');   
			address <= (others => '0');
			enable_reading <='0'; 
			cntrlecho_int<="11";
			sram_ce <= '0' ;
			sram_oe <= '0' ;
			sram_we <= '1' ;
			sram_lb <= '0' ;
			sram_ub  <= '0' ;  
			longecho <= "11";	
		elsif rising_edge(clk) then
			if (cntrlecho(0)='1') and  (cntrlecho_int<"11") then
				cntrlecho_int<=cntrlecho_int+1;
			elsif (cntrlecho(1)='1') and  (cntrlecho_int>"00") then
				cntrlecho_int<=cntrlecho_int-1;
			end if;
			if (compteur="000000000") then
				if address < (25000*(to_integer(cntrlecho_int)+1)) then   -- Length of SRAM
					address<=address + 1;
				else
					address<= (others => '0');
				    enable_reading <='1';
				end if; 
			end if;
			compteur <= compteur + 1;
		end if; -- rstn, rising_edge(clk)
		addr<=address; 
		sram_ce <= '0';
		sram_oe <= compteur(8);
		sram_we <= not(compteur(8));
		sram_lb <= '0';
		sram_ub <= '0';
		longecho<=cntrlecho_int;
	end process; 
end rtl;

