library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Synth is
  port(clk,rstn  : in  std_logic; -- system signals
       -- User Interface signals
       --SW        : in  std_logic_vector(1 to 9) ; --on les utilisera pour tester (avant de recevoir le scancode) le dernier est le mute
       from_kb      : in std_logic_vector(7 downto 0); 
       --LEDR      : out std_logic_vector(0 TO 17) ; --lumieres A COMMENTER --------
       -- SndBus signals
		 --LADC, RADC : in signed(15 downto 0);
		 from_Rolland : in std_logic_vector(7 downto 0) ; 
       lrsel     : in  std_logic; 
       LDAC_Synth,RDAC_Synth : out signed(15 downto 0));
end entity;

architecture rtl of Synth is
  signal lrsel_old, lrsel_change : std_logic := '0';
  signal ildac,irdac : signed(15 downto 0); -- internal version of LDAC,RDAC.
  
  -- sine/noise generation signals:
  signal clk_divider : natural range 0 to 762 := 0; -- 50 MHz / 763 = 65530.8 Hz
  constant freq_C4 : natural := 261; -- C4
  constant freq_D4b : natural := 277 ; --D4b
  constant freq_D4 : natural := 294; -- D4 
  constant freq_E4b : natural := 311; --E4b 
  constant freq_E4 : natural := 330; -- E4 
  constant freq_F4 : natural := 350; -- F4
  constant freq_G4b : natural := 370 ; --G4b
  constant freq_G4 : natural := 391; -- G4
  constant freq_A4b : natural := 415 ; --A4b
  constant freq_A4 : natural := 440; -- A4
  constant freq_B4b : natural := 466 ; --B4b
  constant freq_B4 : natural := 493; -- B4
  constant freq_C5 : natural := 523; -- C5 (one octave more than the first note)

  signal noise : std_logic_vector(15 downto 0) := (others => '1');

  signal x, xC4, xD4, xE4, xF4, xG4, xA4, xB4, xC5, xD4b, xE4b, xG4b, xA4b, xB4b : unsigned(15 downto 0) := (others =>'0'); -- phase accumulator, x=bus to PSAC
  signal a, aC4, aD4, aE4, aF4, aG4, aA4, aB4, aC5, aD4b, aE4b, aG4b, aA4b, aB4b : signed(15 downto 0) := (others =>'0'); -- sine amplitude, a=bus from PSAC
  signal sC4, sD4, sE4, sF4, sG4, sA4, sB4, sC5, sD4b, sE4b, sG4b, sA4b, sB4b : signed(15 downto 0); -- the combined amplitude, possibly muted.

  function asr(slv : signed; n : natural) return signed is begin
    return (slv'left downto slv'left-n+1 => slv(slv'left)) & slv(slv'left downto n);
  end function;
  signal lack, rack : unsigned(39 downto 0) := (others => '0');
  
  component PSAC is -- Phase to Sine Amplitude Converter
    port(clk: in std_logic;
      x  : in unsigned(15 downto 0); -- "111..1" corresponds to 360 deg (almost)
      a  : out signed(15 downto 0)); -- "011..1" = +1 (almost), "100..0" = -1
  end component;

begin
  --== Generate sinusoids and noise ==
  process(clk) begin
    if rising_edge(clk) then -- reset is for noobs
      if clk_divider < 762 then
        clk_divider <= clk_divider + 1;
      else
        clk_divider <= 0;
	xC4 <= xC4 + freq_C4;
	xD4 <= xD4 + freq_D4;
	xE4 <= xE4 + freq_E4;
	xF4 <= xF4 + freq_F4;
	xG4 <= xG4 + freq_G4;
	xA4 <= xA4 + freq_A4;
	xB4 <= xB4 + freq_B4;
	xC5 <= xC5 + freq_C5;
	
	xD4b <= xD4b + freq_D4b;
	xE4b <= xE4b + freq_E4b;
	xG4b <= xG4b + freq_G4b;
	xA4b <= xA4b + freq_A4b;
	xB4b <= xB4b + freq_B4b;
	
      end if;

      case clk_divider is
        when 1 => x <= xC4;
        when 2 => x <= xD4;
        when 3 => x <= xE4; 
        when 4 => aC4 <= a;
        when 5 => aD4 <= a;
        when 6 => aE4 <= a;

		  when 7 => x <= xF4;
        when 8 => x <= xG4;
        when 9 => x <= xA4; 
        when 10 => aF4 <= a;
        when 11 => aG4 <= a;
        when 12 => aA4 <= a;

		  when 13 => x <= xB4;
        when 14 => x <= xC5;
		  when 15 => x <= xD4b ; 
	-- décalage pour avoir un bon pipeline (ça peut poser probleme dans PSAC ???) finalement, j'ai tout mis a zéro et je traite pas la sortie. 
        when 16 => aB4 <= a;
        when 17 => aC5 <= a;
		  when 18 => aD4b <= a ; 
		  
		  when 19 => x <= xE4b;
        when 20 => x <= xG4b;
        when 21 => x <= xA4b; 
        when 22 => aE4b <= a;
        when 23 => aG4b <= a;
        when 24 => aA4b <= a;
		  
		  when 25 => x <= xB4b;
		  when 28 => aB4b <= a;
		  
        when others => null;
      end case;
    end if;
  end process;

--ici ,j'ai toutes mes amplitudes qui sont stockées dans les aXY. Je vais les envoyer en sortie en fonction de la touche (de la FPGA) sur laquelle on appuie. 

  psac_inst : PSAC port map(clk=>clk, x=>x, a=>a);
  
  --== Add sinusoids and noise to the signal, and perform the analysis ==
  -- Merge the two tones per channel, am/32 + al/16
--ICI on peut jouer sur la valeur par laquelle on divise pour pas avoir de trop trop grosses valeur
  sC4 <= asr(aC4,5) when (from_kb(7) = '1' or from_Rolland(7) = '1') else (others => '0'); -- ici, si on met que sur un bit, on peut peut etre faire la somme direct? 
  sD4 <= asr(aD4,5) when (from_kb(6) = '1' or from_Rolland(6) = '1') else (others => '0');
  sE4 <= asr(aE4,5) when (from_kb(5) = '1' or from_Rolland(5) = '1') else (others => '0');
  sF4 <= asr(aF4,5) when (from_kb(4) = '1' or from_Rolland(4) = '1') else (others => '0');
  sG4 <= asr(aG4,5) when (from_kb(3) = '1' or from_Rolland(3) = '1') else (others => '0');
  sA4 <= asr(aA4,5) when (from_kb(2) = '1' or from_Rolland(2) = '1') else (others => '0');
  sB4 <= asr(aB4,5) when (from_kb(1) = '1' or from_Rolland(1) = '1') else (others => '0');
  sC5 <= asr(aC5,5) when (from_kb(0) = '1' or from_Rolland(0) = '1') else (others => '0');

  

  -- Add the the signal, or mute. /!\ on ne peut appuyer que sur une touche en même temps !!! 
  
  ildac <= sC4 + sD4 + sE4 + sF4 + sG4 + sA4 + sB4 + sC5 ;
  irdac <= sC4 + sD4 + sE4 + sF4 + sG4 + sA4 + sB4 + sC5 ;


  process(clk) begin
    if rising_edge(clk) then
      lrsel_old <= lrsel;
      lrsel_change <= lrsel_old xor lrsel;
      
      if lrsel_change = '1' and lrsel = '1' then -- activate left channel
        LDAC_Synth <= ildac; -- put calculation results onto the output.
        --RDAC_Synth <= asr(signed(noise),4); -- put some noise onto the output.
        -- Perform dac*dac, and low pass filter the result, ack = (ack - ack/1024) + result
        lack <= lack - lack(lack'left downto 10) + unsigned(ildac*ildac);
      elsif lrsel_change = '1' and lrsel = '0' then -- activate right channel
        RDAC_Synth <= irdac;
        --LDAC_Synth <= asr(signed(noise),4);
        rack <= rack - rack(rack'left downto 10) + unsigned(irdac*irdac);
      end if;
      
      -- Compress the ack into 9 LEDS, by OR:ing the bits together. This is a REALLY dirty solution =)
--      for i in 0 to 8 loop
--        LEDR(i) <= rack(3*i+10) or rack(3*i+9) or rack(3*i+8);
--        LEDR(17-i) <= lack(3*i+10) or lack(3*i+9) or lack(3*i+8);
--        LEDR(17-i) <= ieee.std_logic_misc.or_reduce(std_logic_vector(lack(3*i+10 downto 3*i+8)));
--      end loop;
    end if;
  end process;
END architecture;


-- ==================== Private modules ============================

-- ===== PSAC =====
-- A sine polynomial approximation function, with 64 first order polynomials per quadrant.
-- N=16, F=8, W=16
-- latency: 2
library ieee; use ieee.std_logic_1164.all; use ieee.numeric_std.all;

entity PSAC is
  port(
    clk: in std_logic;
    x  : in unsigned(15 downto 0);
    a  : out signed(15 downto 0) := (others=>'0'));
end PSAC;

architecture rtl of PSAC is
  signal inv_res : std_logic_vector(0 to 2) := (others => '0'); -- remember if res should be negated.
  signal x2    : unsigned(13 downto 0) := (others=>'0');   -- x(N-3 downto 0) xor x(MSB-1)
  signal xC    : unsigned(5 downto 0) := (others=>'0');   -- x(N-3 downto F) xor x(MSB-1)
  signal xF    : unsigned(7 downto 0) := (others => '0'); -- x(F-1 downto 0) xor x(MSB-1)
   -- signals for iteration 1
  signal xF_1   : unsigned(7 downto 0) := (others => '0');
  signal Res_1  : unsigned(9 downto 0) := (others => '0');
   -- signals for iteration 2
  signal data2_1: unsigned(14 downto 0) := (others => '0');
  signal Res_2  : unsigned(14 downto 0) := (others => '0');
  -- *_K => signals is delayed K clock cycles from it's x input.
  -- dataM = the synchronous ROM output.
  -- Res = (result of iter M=K) = dataM +- xF*(data(M-1) -+ xF*(...)).
  
  function "+"(l : unsigned; r : std_logic) return unsigned is begin
    return unsigned(ieee.std_logic_unsigned."+"(std_logic_vector(l), r));
  end "+";
  component POLY_ROM is
    port(clk  : in  std_logic; addr : in  unsigned(5 downto 0);
      data1: out unsigned(9 downto 0); data2: out unsigned(14 downto 0));
  end component;
begin
  
  -- Initial phase adjustment to quadrant:
  x2 <= unsigned(x(13 downto 0)) when x(14) = '0' else  not unsigned(x(13 downto 0));
  xC <= x2(13 downto 8);
  xF <= x2(7 downto 0);
  inv_res(0) <= x(15);
  
  -- output is delayed one cycle
  rom : POLY_ROM port map(clk => clk, addr => xC, data1 => Res_1, data2 => data2_1);
  
  process(clk)
    variable tmp : unsigned(23 downto 0);
  begin
    if rising_edge(clk) then
      ------ Pipeline stage 1 -------
      xF_1 <= xF;
      ------ Pipeline stage 2 -------
      tmp := (others => '0');
      tmp(17 downto 0) := Res_1 * xF_1;
      Res_2 <= data2_1 + tmp(22 downto 8) + tmp(7);
      
      inv_res(1 to 2) <= inv_res(0 to 1);
    end if;
  end process;
  
  -- final result adjustment to quadrant:
  a <= signed('0' & Res_2) when inv_res(2) = '0' else
       -signed('0' & Res_2);
end architecture;

----- The ROM content -----
library ieee; use ieee.std_logic_1164.all; use ieee.numeric_std.all;

entity POLY_ROM is
  port (
    clk  : in  std_logic; --synchronous ROM
    addr : in  unsigned(5 downto 0);
    data1: out unsigned(9 downto 0) := (others => '0');
    data2: out unsigned(14 downto 0) := (others => '0'));
end POLY_ROM;

architecture rtl of POLY_ROM is
  type romt is array(0 to 63) of unsigned(24 downto 0);
  signal rom_data : romt;
  signal tmp : unsigned(24 downto 0);
begin
  -- Wait with ROM data until all other is done
  process(clk) begin
    if clk'event and clk = '1' then
      data1 <= tmp(24 downto 15);
      data2 <= tmp(14 downto 0);
    end if;
  end process;

  tmp <= rom_data(to_integer(addr));
  -- Here comes the ROM data
  rom_data <= 
   (b"1100100100_000000000011001", b"1100100100_000001100111101", b"1100100011_000011001100001", b"1100100001_000100110000100",
    b"1100011111_000110010100101", b"1100011101_000111111000100", b"1100011010_001001011100001", b"1100010111_001010111111011",
    b"1100010011_001100100010001", b"1100001110_001110000100100", b"1100001010_001111100110010", b"1100000100_010001000111100",
    b"1011111111_010010101000000", b"1011111000_010100000111110", b"1011110010_010101100110111", b"1011101011_010111000101000",
    b"1011100011_011000100010011", b"1011011011_011001111110110", b"1011010011_011011011010001", b"1011001010_011100110100011",
    b"1011000001_011110001101101", b"1010110111_011111100101101", b"1010101101_100000111100011", b"1010100010_100010010010000",
    b"1010010111_100011100110010", b"1010001100_100100111001000", b"1010000000_100110001010100", b"1001110100_100111011010011",
    b"1001100111_101000101000111", b"1001011010_101001110101110", b"1001001101_101011000001000", b"1001000000_101100001010101",
    b"1000110010_101101010010100", b"1000100011_101110011000101", b"1000010101_101111011101000", b"1000000110_110000011111100",
    b"0111110111_110001100000010", b"0111100111_110010011111000", b"0111010111_110011011011110", b"0111000111_110100010110101",
    b"0110110111_110101001111011", b"0110100110_110110000110001", b"0110010101_110110111010111", b"0110000100_110111101101011",
    b"0101110010_111000011101110", b"0101100001_111001001100000", b"0101001111_111001111000000", b"0100111101_111010100001111",
    b"0100101011_111011001001011", b"0100011000_111011101110101", b"0100000110_111100010001101", b"0011110011_111100110010010",
    b"0011100000_111101010000100", b"0011001101_111101101100011", b"0010111010_111110000110000", b"0010100111_111110011101001",
    b"0010010011_111110110001111", b"0010000000_111111000100001", b"0001101100_111111010100001", b"0001011001_111111100001100",
    b"0001000101_111111101100100", b"0000110001_111111110101001", b"0000011110_111111111011001", b"0000001010_111111111110110");
    
end architecture;

