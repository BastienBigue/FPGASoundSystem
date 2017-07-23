library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vga_gen is
  Port ( clk,rstn : in std_logic;
        color_code:  in unsigned(1 downto 0);
         blank1 : in std_logic;
         vga_r :  out unsigned(9 downto 0);
         vga_g :  out unsigned(9 downto 0);
         vga_b :  out unsigned(9 downto 0);
         vga_blank : out std_logic;
         vga_sync  : out std_logic);
end vga_gen;

architecture behave of vga_gen is
begin   
	process(clk, rstn)
	begin
		vga_sync  <= '0';
		vga_blank <= blank1;  
    	if(rstn = '0') then
			vga_r <= (others => '0');
			vga_g <= (others => '0');
			vga_b <= (others => '0');
			vga_sync  <= '0';
    	elsif rising_edge(clk) then  
			if (color_code = "01") then -- COLOR CODE FOR GREEN = 01
				vga_r <= "0000000000";
         		vga_g <= "1111111111";
         		vga_b <= "0000000000";
			elsif (color_code = "11") then -- COLOR CODE FOR BLUE = 11
				vga_b <= "1111111111";
		        vga_g <= "0000000000";
		        vga_r <= "0000000000";
			elsif (color_code = "00") then  -- COLOR CODE FOR WHITE = 00
				vga_r <= "1111111111";
       		  	vga_g  <= "1111111111";
        		vga_b <= "1111111111";
			elsif (color_code = "10") then -- COLOR CODE FOR GREY = 10
				vga_r <= "1000000000";
         		vga_g  <= "1000000000";
         		vga_b <= "1000000000";
			else -- BLACK IN CASE OF EMERGENCY
				vga_r <= "0000000000";
         		vga_g  <= "0000000000";
         		vga_b <= "0000000000";
			end if; 
		end if;
	end process;
end behave;
