library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity multip is
  port(daclrc : in std_logic;
       dacdatleft : in std_logic;
		 dacdatright : in std_logic;
		 dacdat : out std_logic);
end entity;

architecture multipour of multip is
 
begin
	dacdat <= dacdatleft when daclrc='1' else 
		dacdatright;
end multipour;