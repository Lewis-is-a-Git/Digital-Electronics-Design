----------------------------------------------------------------------------------
--  Traffic.vhd
--
-- Traffic light system to control an intersection
--
-- Accepts inputs from two car sensors and two pedestrian call buttons
-- Controls two sets of lights consisting of Red, Amber and Green traffic lights and
-- a pedestrian walk light.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Traffic is
    Port ( Reset      : in   STD_LOGIC;
           Clock      : in   STD_LOGIC;
           
           -- for debug
           debugLED   : out  std_logic;
           LEDs       : out  std_logic_vector(2 downto 0);

           -- Car and pedestrian buttons
           CarEW      : in   STD_LOGIC; -- Car on EW road
           CarNS      : in   STD_LOGIC; -- Car on NS road
           PedEW      : in   STD_LOGIC; -- Pedestrian moving EW (crossing NS road)
           PedNS      : in   STD_LOGIC; -- Pedestrian moving NS (crossing EW road)
           
           -- Light control
           LightsEW   : out STD_LOGIC_VECTOR (1 downto 0); -- controls EW lights
           LightsNS   : out STD_LOGIC_VECTOR (1 downto 0)  -- controls NS lights
           );
end Traffic;

architecture Behavioral of Traffic is
	--synched inputs
	signal SynchPedEW, SynchPedNS, SynchCarEW, SynchCarNS : std_logic;
	--delay values
	signal Delay_1s : STD_LOGIC;
	signal Delay_2s : STD_LOGIC;
	signal Delay_3s : STD_LOGIC;
	--clock controls
	signal CountEn : STD_LOGIC;
begin
   -- Show reset status on FPGA LED
   debugLed <= Reset;
	LEDs <= "000";
	
	InputSynch: --synchronise inputs through a flipflop
	process(clock, reset, CarEW, CarNS, PedEW, PedNS)
	begin
		if reset = '1' then
			SynchCarEW <= '0';
			SynchCarNS <= '0';
			SynchPedEW <= '0';
			SynchPedNS <= '0';
		elsif rising_edge(clock) then
			SynchCarEW <= CarEW;
			SynchCarNS <= CarNS;
			SynchPedEW <= PedEW;
			SynchPedNS <= PedNS;
		end if;
	end process;
	
	Counter:
	Entity work.Counter
   Port Map (
           Reset => Reset,
           Clock => Clock,
			  CountEn => CountEn,
			  Delay_1s => delay_1s,
			  Delay_2s => delay_2s,
			  Delay_3s => delay_3s
           );
			  
	Controller:
	Entity work.Controller
   Port Map (
           Reset => Reset,
           Clock => Clock,
           
           -- External Inputs
           PedEW => SynchPedEW, 
			  PedNS => SynchPedNS, 
			  CarEW => SynchCarEW, 
			  CarNS => SynchCarNS,
           
           -- External Outputs
           LightsEW => LightsEW,
			  LightsNS => LightsNS,
           
           -- Counter control
			  CountEn => CountEn,
			  Delay_1s => delay_1s,
			  Delay_2s => delay_2s,
			  Delay_3s => delay_3s
           );
end;
