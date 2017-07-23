library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity KB_Module is
  port(rstn,clk,PS2_CLK,PS2_DAT : in std_logic;
		 kb_to_volbal : out std_logic_vector(5 downto 0) ; 
		 kb_to_echo : out std_logic_vector(1 downto 0) ; 
		 kb_to_volbalecho : out std_logic_vector(3 downto 0) ; 
		 kb_to_synth : out std_logic_vector(7 downto 0)) ;  -- XXXXXXXX_XXXX_X_X_XXXX : NOTE_VOLBAL_MUTE_ECHO_VOLBALECHO
end entity ;

  
architecture arch1 of KB_Module is

signal shiftreg: std_logic_vector(9 downto 0);
signal PS2_CLK2, PS2_DAT2, PS2_CLK2_old, detected_fall, f0, mute, echo : std_logic;
signal kb_to_volbal_int :  std_logic_vector(5 downto 0) ; 
signal kb_to_echo_int :  std_logic_vector(1 downto 0) ; 
signal kb_to_volbalecho_int :  std_logic_vector(3 downto 0) ; 
signal kb_to_synth_int :  std_logic_vector(7 downto 0) ; 

constant HEXA_E0 : std_logic_vector(7 downto 0) := "11100000";
constant HEXA_F0 : std_logic_vector(7 downto 0) := "11110000"; -- BREAK CODE
constant HEXA_1C : std_logic_vector(7 downto 0) := "00011100"; -- A
constant HEXA_1B : std_logic_vector(7 downto 0) := "00011011"; -- S
constant HEXA_23 : std_logic_vector(7 downto 0) := "00100011"; -- D
constant HEXA_2B : std_logic_vector(7 downto 0) := "00101011"; -- F
constant HEXA_34 : std_logic_vector(7 downto 0) := "00110100"; -- G
constant HEXA_33 : std_logic_vector(7 downto 0) := "00110011"; -- H
constant HEXA_3B : std_logic_vector(7 downto 0) := "00111011"; -- J
constant HEXA_42 : std_logic_vector(7 downto 0) := "01000010"; -- K
constant HEXA_24 : std_logic_vector(7 downto 0) := "00100100"; -- E (echo)
constant HEXA_3A : std_logic_vector(7 downto 0) := "00111010"; -- M (mute)
constant HEXA_3C : std_logic_vector(7 downto 0) := "00111100"; -- U (echo vol +)
constant HEXA_43 : std_logic_vector(7 downto 0) := "01000011"; -- I (echo vol -)
constant HEXA_44 : std_logic_vector(7 downto 0) := "01000100"; -- O (echo bal l)  
constant HEXA_4D : std_logic_vector(7 downto 0) := "01001101"; -- P (echo bal r)
constant HEXA_75 : std_logic_vector(7 downto 0) := "01110101"; -- ARROW UP
constant HEXA_72 : std_logic_vector(7 downto 0) := "01110010"; -- ARROW DOWN
constant HEXA_6B : std_logic_vector(7 downto 0) := "01101011"; -- ARROW LEFT
constant HEXA_74 : std_logic_vector(7 downto 0) := "01110100"; -- ARROW RIGHT
constant HEXA_15 : std_logic_vector(7 downto 0) := "00010101"; -- Q (- length of echo)
constant HEXA_1D : std_logic_vector(7 downto 0) := "00011101"; -- W (- length of echo)

begin 


	p1 : process(clk) 
	begin 
		if rising_edge(clk) then
			PS2_CLK2 <= PS2_CLK;
			PS2_DAT2 <= PS2_DAT;
			PS2_CLK2_old <= PS2_CLK2;	
		end if;
	end process; 

		detected_fall <= (NOT PS2_CLK2) and (PS2_CLK2_old); 
		--detected_fall <= PS2_CLK2 and not PS2_CLK2_old ; --------------------DIFFERENT 

		
	p2 : process(clk, rstn) 
	begin
		if rstn = '0' then
			shiftreg(9 downto 0) <=(others => '1');
			kb_to_volbal_int <= (others => '0') ; -- code(17 downto 0) <= (others => '0') ;
			kb_to_volbalecho_int <= (others => '0') ; 
			kb_to_synth_int <= (others => '0') ; 
			kb_to_echo_int <= (others => '0') ; 
			mute <= '0' ; 
			echo <= '0' ; 
		elsif rising_edge(clk) then
			kb_to_volbal_int(3 downto 0) <= (others => '0') ; --code(9 downto 6) <= (others => '0') ; 
			kb_to_volbalecho_int <= (others => '0') ;  -- code(3 downto 0) <= (others => '0') ; 		
			kb_to_echo_int <= (others => '0') ; 
		
			if detected_fall = '1' then
				shiftreg(9) <= PS2_DAT2;
				shiftreg(8 downto 0) <= shiftreg(9 downto 1);
				
			elsif shiftreg(0)='0' then 
				if shiftreg(8 downto 1) = HEXA_F0 then 
					f0 <= '1' ; 
					shiftreg(9 downto 0) <= (others => '1') ; 
				end if ;
				
				if f0 = '1' then
					case shiftreg(8 downto 1) is 
						when "00011100" => kb_to_synth_int(7) <= '0'; -- A
						when "00011011" => kb_to_synth_int(6) <= '0'; -- S
						when "00100011" => kb_to_synth_int(5) <= '0'; -- D
						when "00101011" => kb_to_synth_int(4) <= '0'; -- F
						when "00110100" => kb_to_synth_int(3) <= '0'; -- G
						when "00110011" => kb_to_synth_int(2) <= '0'; -- H
						when "00111011" => kb_to_synth_int(1) <= '0'; -- J
						when "01000010" => kb_to_synth_int(0) <= '0'; -- K
						 
						when "00100100" => kb_to_volbal_int(5) <= not(echo) ; echo <= not(echo) ;  --compt <= "00000000001";-- E (echo)
						when "00111010" => kb_to_volbal_int(4) <= not(mute) ; mute <= not(mute) ;-- compt <= "00000000001";-- M (mute) 
						when "01110101" => kb_to_volbal_int(0) <= '1'; --ledr(2)<='1'; compt <= "00000000001";-- ARROW UP
						when "01110010" => kb_to_volbal_int(1) <= '1'; --ledr(3)<='1'; compt <= "00000000001";-- ARROW DOWN
						when "01110100" => kb_to_volbal_int(2) <= '1'; --ledr(4)<='1'; compt <= "00000000001";-- ARROW RIGHT
						when "01101011" => kb_to_volbal_int(3) <= '1'; --ledr(5)<='1'; compt <= "00000000001";-- ARROW LEFT
						when "00010101" => kb_to_echo_int(1) <= '1' ; --ledr(6)<='1'; compt <= "00000000001";-- Q (+ lenght echo)
						when "00011101" => kb_to_echo_int(0) <= '1' ; --ledr(7)<='1'; compt <= "00000000001";-- W (+ lenght echo)
						 
						when "00111100" => kb_to_volbalecho_int(0) <= '1';-- ledr(8)<='1'; compt <= "00000000001";-- U (echo vol +)
						when "01000011" => kb_to_volbalecho_int(1) <= '1';-- ledr(9)<='1';  compt <= "00000000001";-- I (echo vol -)
						when "01001101" => kb_to_volbalecho_int(2) <= '1'; --ledr(10)<='1'; compt <= "00000000001";-- P (echo bal r)
						when "01000100" => kb_to_volbalecho_int(3) <= '1' ; --ledr(11)<='1'; compt <= "00000000001";-- O (echo bal l) 
						 
						when others => null ; --on fait rien si on a autre chose
					end case ; 
					 
					f0 <= '0' ; 

				else -- f0 = '0'
				
					case shiftreg(8 downto 1) is 
						when "00011100" => kb_to_synth_int(7) <= '1'; -- A
						when "00011011" => kb_to_synth_int(6) <= '1'; -- S
						when "00100011" => kb_to_synth_int(5) <= '1'; -- D
						when "00101011" => kb_to_synth_int(4) <= '1'; -- F
						when "00110100" => kb_to_synth_int(3) <= '1'; -- G
						when "00110011" => kb_to_synth_int(2) <= '1'; -- H
						when "00111011" => kb_to_synth_int(1) <= '1'; -- J
						when "01000010" => kb_to_synth_int(0) <= '1'; -- K
						when others => null ; --code(3 downto 0) <= (others => '0') ; code(9 downto 6) <= (others => '0') ; 
					end case ; 
					 
				end if ; 
				
				shiftreg(9 downto 0) <= (others => '1') ; 
				 
				end if ; 	 
			end if ; 

			kb_to_volbal <= kb_to_volbal_int;
			kb_to_echo <= kb_to_echo_int;
			kb_to_volbalecho <= kb_to_volbalecho_int;
			kb_to_synth <= kb_to_synth_int;
		 end process ; 		
	end architecture ; 	


----------------------------------------------------------------
	