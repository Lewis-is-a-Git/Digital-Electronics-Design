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
	signal delay_1s : STD_LOGIC;
begin
   -- Show reset status on FPGA LED
   debugLed <= Reset; 
   
   -- Threee LEDs for debug 
   LEDs <= "000";
   
	--4 different states
	--timer to extend time on each state
	-- greenNS means redEW so dont need red states
	
	--single point synchronisation of external inputs
			--idea jsut a flip flop process
	
	--input synch to pedestrian mem or state machine (2 proceesses) and need a counter
	-- 2 modules statemachine and counter
	
	-- controls timer(mealey) lights (more)
	
	-- seporate register to remeber paedestrain button presses (just a flip flop)
		--sensitive to state (green light)
		
	--TODO:
	--counter (timer to delay state change)
	--pedestrian lights
	--car presence changes lights (States) starts the counters
	--synchronise inputs / done i think
	
	inputSynch: --synchronise inputs through a flipflop
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
           Clock => Clock 
           );
			  
	Controller:
	Entity work.Controller
   Port Map (
           reset => reset,
           clock => clock,
           
           -- External Inputs
           PedEW => SynchPedEW, 
			  PedNS => SynchPedNS, 
			  CarEW => SynchCarEW, 
			  CarNS => SynchCarNS,
           
           -- External Outputs
           LightsEW => LightsEW,
			  LightsNS => LightsNS,
           
           -- Counter control
			  delay_1s => delay_1s
           );
end;
