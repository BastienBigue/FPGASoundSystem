library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Roland is
  port(rstn,clk : in std_logic;
		 GPIO_0_0 : in std_logic; --PIN_D25
		 GPIO_0_1 : in std_logic; --PIN_J22
		 GPIO_0_2 : in std_logic; --PIN_E26
		 GPIO_0_3 : in std_logic; --PIN_E25
		 GPIO_0_4 : in std_logic; --PIN_F24
		 sel : out unsigned (3 downto 0) ; 
		 tones_out : out unsigned (7 downto 0));
end entity ;

  
architecture arch1 of Roland is
	 signal memory : unsigned(74 downto 0);
	 signal counter : unsigned (8 downto 0);
	 signal sel_int : unsigned (3 downto 0);
begin 
sel <= sel_int;
tones_out<=(memory(19) or memory(19+12) or memory(19+12*2) or memory(19+12*3) or memory(19+12*4))&(memory(5) or memory(17)  or memory(17+12) or memory(17+12*2) or memory(17+12*3) or memory(17+12*4))&(memory(3)or memory(3+12)or memory(3+12*2)or memory(3+12*3)or memory(3+12*4)or memory(3))&(memory(2) or memory(14) or memory(26) or memory(38) or memory(50) or memory(62))&(memory(0) or memory(12) or memory(24) or memory(36) or memory(48) or memory(60) or memory(72))&(memory(10) or memory(22) or memory(34) or memory(46) or memory(58) or memory(70))&(memory(8)or memory(20)or memory(32)or memory(44)or memory(56)or memory(68))&memory(7);
p1 : process(clk) 

begin

	if rstn = '0' then
	   counter <= (others => '0');
		sel_int <= (others => '0');		
	elsif rising_edge(clk) then
	   counter <= counter + 1; 
	   if (counter=0) then
		   sel_int <= sel_int + 1;
			if GPIO_0_0 = '0' then   -- la touche sel sur les 16 premieres touches droites est active
			   memory(to_integer(sel_int))<='1';
			else -- desactivee
			   memory(to_integer(sel_int))<='0';
		   end if;
		   if GPIO_0_1 = '0'then
			   memory(to_integer(sel_int)+16)<='1';
			else -- desactivee
			   memory(to_integer(sel_int)+16)<='0';
			end if;	
	   	if GPIO_0_2 = '0'then
		   	memory(to_integer(sel_int)+2*16)<='1';
		   else  -- desactivee
			   memory(to_integer(sel_int)+16*2)<='0';
			end if;	
		   if GPIO_0_3 = '0'then
			   memory(to_integer(sel_int)+3*16)<='1';
			else -- desactivee
			   memory(to_integer(sel_int)+16*3)<='0';
			end if;	
			if GPIO_0_4 = '0'then
			   memory(to_integer(sel_int)+4*16)<='1';
			else -- desactivee
			   memory(to_integer(sel_int)+16*4)<='0';
			end if;	
		end if; --counter
	end if ; --process
end process; 
	
	
end architecture ; 	

