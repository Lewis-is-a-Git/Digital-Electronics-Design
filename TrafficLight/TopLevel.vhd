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

-- Encoding for lights
constant RED   : std_logic_vector(1 downto 0) := "00";
constant AMBER : std_logic_vector(1 downto 0) := "01";
constant GREEN : std_logic_vector(1 downto 0) := "10";
constant WALK  : std_logic_vector(1 downto 0) := "11";

type StateType is (NSGreen, NSAmber, EWGreen, EWAmber);
signal State, Nextstate : Statetype;

signal PEW, PNS : std_logic;

begin
   -- Show reset status on FPGA LED
   debugLed <= Reset; 
   
   -- Threee LEDs for debug 
   LEDs     <= "000";
   
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
	--synchronise inputs
	
	synchronous:
	process(clock, reset)
	begin
		PNS <= '0';
		PEW <= '0';
		if reset = '1' then --asynchronous reset to reset all synchnous circuits
			state <= EWGreen;		-- not used to reset timer
		elsif rising_edge(Clock) then
			state <= Nextstate;
			if PedEW = '1' then
				PEW <= '1';
			end if;
			if PedNS = '1' then
				PNS <= '1';
			end if;
		end if;
	end process;
	
	combinational:
	process(state, PNS, PEW)
	begin

   LightsEW <= RED;
   LightsNS <= RED;
	Nextstate <= State;
	
	case state is
		when NSGreen =>
			if PNS = '1' then
				LightsNS <= WALK;
				PNS <= '0';
			else
				LightsNS <= GREEN;
			end if;
			Nextstate <= NSAmber;
			
		when NSAmber =>
			LightsNS <= AMBER;
			Nextstate <= EWGreen;
		when EWGreen =>
			if PEW = '1' then
				LightsEW <= WALK;
				PEW <= '0';
			else
				LightsEW <= GREEN;
			end if;
			Nextstate <= EWAmber;
			
		when EWAmber =>
			LightsEW <= AMBER;
			Nextstate <= NSGreen;
	end case;
	end process;
end;

--library IEEE;
--use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.STD_LOGIC_ARITH.ALL;
--use IEEE.STD_LOGIC_UNSIGNED.ALL;
--entity counter is 
	--Port (delay1 : in unsigned,
	--		delay2 : in unigned); 
--end counter;

--architecture bah of Counter is
--begin
--synchrnous:
--process(delay1)
--begin
	--if rising_edge(delay1) then
		--clear input to start time interval
	--end if;

--end process;

--end bah;
