library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;

entity Controller is
    Port ( Clock : in  STD_LOGIC; --clock
           Reset : in  STD_LOGIC; --external reset
			  PedEW : in STD_LOGIC; --synched east west Pedestrain button pressed
			  PedNS : in STD_LOGIC; --synched north south Pedestrain button pressed
			  CarEW : in STD_LOGIC; --synched car east west button
			  CarNS : in STD_LOGIC; --synched car north south button
			  --delays to slow down the system
			  DelayAmber : in STD_LOGIC; --delay for amber light
			  DelayMin : in STD_LOGIC; --delay for new green light minimum time
			  DelayPed : in STD_LOGIC; --delay for pedestrain crossing
			  CountEn : out STD_LOGIC; --only use the counter if it is enabled also clears
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
	type StateType is (NSGreen, NSWalk, NSAmber, EWGreen, EWWalk, EWAmber);
	signal State, Nextstate : Statetype;
	
	--remeber if a pedestrain or car button is pressed
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
				PedEWButtonPressed <= '1';
			end if;
			if PedNS = '1' then
				PedNSButtonPressed <= '1';
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
	process(State, PedNSButtonPressed, PedEWButtonPressed, 
			  CarEW, CarNS, DelayAmber, DelayMin, DelayPed)
	begin
		-- default values for outputs
		LightsEW <= RED;
		LightsNS <= RED;
		Nextstate <= State;
		ClearPedNSButtonPressed <= '0';
		ClearPedEWButtonPressed <= '0';
		CountEn <= '0';
		
		--state machine
		case State is
			--NSGreen
			when NSGreen =>
				LightsNS <= GREEN;
				--wait for input from the other direction
				if PedEWButtonPressed = '1' or CarEW = '1' then 
					CountEn <= '1'; -- enable the counter
					if DelayMin = '1' then --wait for the delay
						NextState <= NSAmber; --go to next state
						CountEn <= '0';
					end if;
				end if;
			--NSwalk
			when NSWalk =>
				LightsNS <= WALK;
				ClearPedNSButtonPressed <= '1'; --clear pedestrain button
				CountEn <= '1'; -- enable the counter
				if DelayPed = '1' then --wait for the delay
					NextState <= NSGreen; --go to next state
					CountEn <= '0';
				end if;
			--NSAmber
			when NSAmber => --swap directions of lights
				LightsNS <= AMBER;
				CountEn <= '1';
				if DelayAmber = '1' then --wait for the delay
					if PedEWButtonPressed = '1' then
						NextState <= EWWalk;
					else
						NextState <= EWGreen;
					end if;
					CountEn <= '0';
				end if;
			--EWGreen
			when EWGreen =>
				LightsEW <= GREEN;
				--wait for input from the other direction
				if PedNSButtonPressed = '1' or CarNS = '1' then 
					CountEn <= '1'; -- enable the counter
					if DelayMin = '1' then --wait for the delay
						NextState <= EWAmber; --go to next state
						CountEn <= '0';
					end if;
				end if;
			--EWWalk
			when EWWalk =>
				LightsEW <= WALK;
				ClearPedEWButtonPressed <= '1'; --clear pedestrain button
				CountEn <= '1'; -- enable the counter
				if DelayPed = '1' then --wait for the delay
					NextState <= EWGreen; --go to next state
					CountEn <= '0';
				end if;
			--EWAMber
			when EWAmber =>
				LightsEW <= AMBER;
				CountEn <= '1'; -- enable the counter
				if DelayAmber = '1' then --wait for the delay
					if PedNSButtonPressed = '1' then
						NextState <= NSWalk;
					else
						NextState <= NSGreen;
					end if;
					CountEn <= '0';
				end if;
		end case;
	end process;
end Behavioral;
