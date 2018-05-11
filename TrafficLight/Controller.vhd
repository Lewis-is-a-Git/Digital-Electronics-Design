library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;

entity Controller is
    Port ( Clock : in  STD_LOGIC; --clock
           Reset : in  STD_LOGIC; --external reset
			  PedEW : in STD_LOGIC; --synched east west Pedestrain button pressed
			  PedNS : in STD_LOGIC; --synched north south Pedestrain button pressed
			  CarEW : in STD_LOGIC; --car east west button
			  CarNS : in STD_LOGIC; -- car north south button
			  Delay_1s : in STD_LOGIC; --delay to slow down the system
			  Clear : out STD_LOGIC; --internal signal to communicate between controller and counter to rest count
			  CountEn : out STD_LOGIC; --only use the counter if it is enabled
			  LightsEW : out STD_LOGIC_VECTOR(1 downto 0); --light output east west
			  LightsNS : out STD_LOGIC_VECTOR(1 downto 0) --light output north south
			  );
end Controller;

architecture Behavioral of Controller is
	-- Encoding for lights
	constant RED   : std_logic_vector(1 downto 0) := "00";
	constant AMBER : std_logic_vector(1 downto 0) := "01";
	constant GREEN : std_logic_vector(1 downto 0) := "10";
	constant WALK  : std_logic_vector(1 downto 0) := "11";
	
	--state machine types
	type StateType is (NSGreen, NSAmber, EWGreen, EWAmber);
	signal State, Nextstate : Statetype;
	
	--remeber if a pedestrain button is pressed
	signal PedNSButtonPressed, PedEWButtonPressed : std_logic;
	signal ClearPedNSButtonPressed, ClearPedEWButtonPressed : std_logic;
begin
   StateProcess:
   process (Reset, Clock, State, ClearPedNSButtonPressed, ClearPedEWButtonPressed)
   begin
      if (reset = '1') then --external reset
         State <= NSGreen;
			PedNSButtonPressed <= '0';
			PedEWButtonPressed <= '0';
      elsif rising_edge(clock) then
			--remeber if a button is pressed
			if PedEW = '1' then
				PedNSButtonPressed <= '1';
			elsif PedNS = '1' then
				PedEWButtonPressed <= '1';
			end if;
			--go to next state
			State <= NextState;
      end if;
		--rest the flipflops after they have been used
		if ClearPedNSButtonPressed = '1' then
			PedNSButtonPressed <= '0';
		end if;
		if ClearPedEWButtonPressed = '1' then
			PedEWButtonPressed <= '0';
		end if;
   end process StateProcess;
   
	CombinationalProcess:
	process(State, PedNSButtonPressed, PedEWButtonPressed, CarEW, CarNS, Delay_1s)
	begin
		-- default values for outputs
		LightsEW <= RED;
		LightsNS <= RED;
		Nextstate <= State;
		ClearPedNSButtonPressed <= '0';
		ClearPedEWButtonPressed <= '0';
		CountEn <= '0';
		Clear <= '0';
		
		--state machine
		case State is
			when NSGreen =>
				if PedNSButtonPressed = '1' then
					LightsNS <= WALK;
					ClearPedNSButtonPressed <= '1';
				else
					LightsNS <= GREEN;
				end if;
				if PedEWButtonPressed = '1' or CarEW = '1' then --wait for input from the other direction
					Clear <= '1'; --reset the counter
					CountEn <= '1'; -- enable the counter
					if Delay_1s = '1' then --wait for the delay
						NextState <= NSAmber; --go to next state
					end if;
				end if;
			when NSAmber => --swap directions of lights
				LightsNS <= AMBER;
				NextState <= EWGreen;
			when EWGreen =>
				if PedEWButtonPressed = '1' then
					LightsEW <= WALK;	
					ClearPedEWButtonPressed <= '1';
				else
					LightsEW <= GREEN;
				end if;
				if PedNSButtonPressed = '1' or CarNS = '1' then
					Clear <= '1';
					CountEn <= '1';
					if Delay_1s = '1' then
						NextState <= EWAmber;
					end if;
				end if;
			when EWAmber =>
				LightsEW <= AMBER;
				NextState <= NSGreen;
		end case;
	end process;

end Behavioral;

