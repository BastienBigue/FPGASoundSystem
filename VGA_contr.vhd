-- Copyright (C) 1991-2012 Altera Corporation
-- Your use of Altera Corporation's design tools, logic functions 
-- and other software and tools, and its AMPP partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Altera Program License 
-- Subscription Agreement, Altera MegaCore Function License 
-- Agreement, or other applicable license agreement, including, 
-- without limitation, that your use is for the sole purpose of 
-- programming logic devices manufactured by Altera and sold by 
-- Altera or its authorized distributors.  Please refer to the 
-- applicable agreement for further details.

-- PROGRAM		"Quartus II 64-Bit"
-- VERSION		"Version 12.1 Build 243 01/31/2013 Service Pack 1.33 SJ Full Version"
-- CREATED		"Sat Nov 07 17:24:55 2015"

LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all; 

LIBRARY work;

ENTITY VGA_contr IS 
	PORT
	(
		fpga_clk :  IN  STD_LOGIC;
		KEY0 :  IN  STD_LOGIC;
		mute :  IN  STD_LOGIC;
		echo_activated :  IN  STD_LOGIC;
		echo_bal :  IN  signed(4 DOWNTO 0);
		echo_length :  IN  unsigned(1 DOWNTO 0);
		echo_vol :  IN  unsigned(3 DOWNTO 0);
		main_bal :  IN  signed(4 DOWNTO 0);
		main_vol :  IN  unsigned(3 DOWNTO 0);
		hsync :  OUT  STD_LOGIC;
		vsync :  OUT  STD_LOGIC;
		vga_clk :  OUT  STD_LOGIC;
		vga_blank :  OUT  STD_LOGIC;
		vga_sync :  OUT  STD_LOGIC;
		vga_b :  OUT  unsigned(9 DOWNTO 0);
		vga_g :  OUT  unsigned(9 DOWNTO 0);
		vga_r :  OUT  unsigned(9 DOWNTO 0)
	);
END VGA_contr;

ARCHITECTURE bdf_type OF VGA_contr IS 

COMPONENT linecounter
	PORT(clk : IN STD_LOGIC;
		 rstn : IN STD_LOGIC;
		 hcnt : IN unsigned(9 DOWNTO 0);
		 vcnt : OUT unsigned(9 DOWNTO 0)
	);
END COMPONENT;

COMPONENT blank_syncr
	PORT(clk : IN STD_LOGIC;
		 rstn : IN STD_LOGIC;
		 blank1 : IN STD_LOGIC;
		 blank2 : OUT STD_LOGIC
	);
END COMPONENT;

COMPONENT hsyncr
	PORT(clk : IN STD_LOGIC;
		 rstn : IN STD_LOGIC;
		 hcnt : IN unsigned(9 DOWNTO 0);
		 hsync : OUT STD_LOGIC
	);
END COMPONENT;

COMPONENT vsyncr
	PORT(clk : IN STD_LOGIC;
		 rstn : IN STD_LOGIC;
		 vcnt : IN unsigned(9 DOWNTO 0);
		 vsync : OUT STD_LOGIC
	);
END COMPONENT;

COMPONENT blank_video
	PORT(hcnt : IN unsigned(9 DOWNTO 0);
		 vcnt : IN unsigned(9 DOWNTO 0);
		 blank : OUT STD_LOGIC
	);
END COMPONENT;

COMPONENT gen_pixel
	PORT(clk : IN STD_LOGIC;
		 rstn : IN STD_LOGIC;
		 mute : IN STD_LOGIC;
		 echo_activated : IN STD_LOGIC;
		 echo_Balance : IN signed(4 DOWNTO 0);
		 echo_length : IN unsigned(1 DOWNTO 0);
		 echo_Volume : IN unsigned(3 DOWNTO 0);
		 hcnt : IN unsigned(9 DOWNTO 0);
		 main_Balance : IN signed(4 DOWNTO 0);
		 main_Volume : IN unsigned(3 DOWNTO 0);
		 vcnt : IN unsigned(9 DOWNTO 0);
		 color_code : OUT unsigned(1 DOWNTO 0)
	);
END COMPONENT;

COMPONENT clock_gen
	PORT(fpga_clk : IN STD_LOGIC;
		 vga_clk : OUT STD_LOGIC
	);
END COMPONENT;

COMPONENT pixelcounter
	PORT(clk : IN STD_LOGIC;
		 rstn : IN STD_LOGIC;
		 hcnt : OUT unsigned(9 DOWNTO 0)
	);
END COMPONENT;

COMPONENT vga_gen
	PORT(clk : IN STD_LOGIC;
		 rstn : IN STD_LOGIC;
		 blank1 : IN STD_LOGIC;
		 color_code : IN unsigned(1 DOWNTO 0);
		 vga_blank : OUT STD_LOGIC;
		 vga_sync : OUT STD_LOGIC;
		 vga_b : OUT unsigned(9 DOWNTO 0);
		 vga_g : OUT unsigned(9 DOWNTO 0);
		 vga_r : OUT unsigned(9 DOWNTO 0)
	);
END COMPONENT;

SIGNAL	clk :  STD_LOGIC;
SIGNAL	hcnt :  unsigned(9 DOWNTO 0);
SIGNAL	rstn :  STD_LOGIC;
SIGNAL	vcnt :  unsigned(9 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_0 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_1 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_2 :  unsigned(1 DOWNTO 0);


BEGIN 



b2v_inst : linecounter
PORT MAP(clk => clk,
		 rstn => rstn,
		 hcnt => hcnt,
		 vcnt => vcnt);


b2v_inst1 : blank_syncr
PORT MAP(clk => clk,
		 rstn => rstn,
		 blank1 => SYNTHESIZED_WIRE_0,
		 blank2 => SYNTHESIZED_WIRE_1);


b2v_inst12 : hsyncr
PORT MAP(clk => clk,
		 rstn => rstn,
		 hcnt => hcnt,
		 hsync => hsync);


b2v_inst13 : vsyncr
PORT MAP(clk => clk,
		 rstn => rstn,
		 vcnt => vcnt,
		 vsync => vsync);


b2v_inst17 : blank_video
PORT MAP(hcnt => hcnt,
		 vcnt => vcnt,
		 blank => SYNTHESIZED_WIRE_0);


b2v_inst2 : gen_pixel
PORT MAP(clk => clk,
		 rstn => rstn,
		 mute => mute,
		 echo_activated => echo_activated,
		 echo_Balance => echo_bal,
		 echo_length => echo_length,
		 echo_Volume => echo_vol,
		 hcnt => hcnt,
		 main_Balance => main_bal,
		 main_Volume => main_vol,
		 vcnt => vcnt,
		 color_code => SYNTHESIZED_WIRE_2);

b2v_inst3 : clock_gen
PORT MAP(fpga_clk => fpga_clk,
		 vga_clk => clk);


b2v_inst6 : pixelcounter
PORT MAP(clk => clk,
		 rstn => rstn,
		 hcnt => hcnt);


b2v_inst9 : vga_gen
PORT MAP(clk => clk,
		 rstn => rstn,
		 blank1 => SYNTHESIZED_WIRE_1,
		 color_code => SYNTHESIZED_WIRE_2,
		 vga_blank => vga_blank,
		 vga_sync => vga_sync,
		 vga_b => vga_b,
		 vga_g => vga_g,
		 vga_r => vga_r);

rstn <= KEY0;
vga_clk <= clk;

END bdf_type;