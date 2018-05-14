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
	
	--remeber if a pedestrain button is pressed
	signal PedNSButtonPressed, PedEWButtonPressed : std_logic;
	signal ClearPedNSButtonPressed, ClearPedEWButtonPressed : std_logic;
	signal CarNSButtonPressed, CarEWButtonPressed : std_logic;
	signal ClearCarNSButtonPressed, ClearCarEWButtonPressed : std_logic;
begin
   StateProcess:
   process (Reset, Clock, State, ClearPedNSButtonPressed, ClearPedEWButtonPressed, ClearCarNSButtonPressed, ClearCarEWButtonPressed)
   begin
      if (reset = '1') then --external reset
         State <= NSGreen;
			PedNSButtonPressed <= '0';
			PedEWButtonPressed <= '0';
			CarEWButtonPressed <= '0';
			CarNSButtonPressed <= '0';
      elsif rising_edge(clock) then
			--remeber if a button is pressed
			if PedEW = '1' then
				PedEWButtonPressed <= '1';
			elsif PedNS = '1' then
				PedNSButtonPressed <= '1';
			end if;
			if CarEW = '1' then
				CarEWButtonPressed <= '1';
			elsif CarNS = '1' then
				CarNSButtonPressed <= '1';
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
		--cars
		if ClearCarNSButtonPressed = '1' then
			CarNSButtonPressed <= '0';
		end if;
		if ClearCarEWButtonPressed = '1' then
			CarEWButtonPressed <= '0';
		end if;
   end process StateProcess;
   
	CombinationalProcess:
	process(State, PedNSButtonPressed, PedEWButtonPressed, CarEWButtonPressed, CarNSButtonPressed, Delay_1s)
	begin
		-- default values for outputs
		LightsEW <= RED;
		LightsNS <= RED;
		Nextstate <= State;
		ClearPedNSButtonPressed <= '0';
		ClearPedEWButtonPressed <= '0';
		ClearCarNSButtonPressed <= '0';
		ClearCarEWButtonPressed <= '0';
		CountEn <= '0';
		
		--state machine
		case State is
			--NSGreen
			when NSGreen =>
				LightsNS <= GREEN;
				ClearCarNSButtonPressed <= '1';
				if PedEWButtonPressed = '1' or CarEWButtonPressed = '1' then --wait for input from the other direction
					CountEn <= '1'; -- enable the counter
					if Delay_1s = '1' then --wait for the delay
						NextState <= NSAmber; --go to next state
						CountEn <= '0';
					end if;
				end if;
			--NSwalk
			when NSWalk =>
				LightsNS <= WALK;
				ClearCarNSButtonPressed <= '1';
				ClearPedNSButtonPressed <= '1';
				CountEn <= '1'; -- enable the counter
				if Delay_1s = '1' then --wait for the delay
					NextState <= NSGreen; --go to next state
					CountEn <= '0';
				end if;
			--NSAmber
			when NSAmber => --swap directions of lights
				LightsNS <= AMBER;
				CountEn <= '1';
				if Delay_1s = '1' then --wait for the delay
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
				ClearCarEWButtonPressed <= '1';
				if PedNSButtonPressed = '1' or CarNSButtonPressed = '1' then --wait for input from the other direction
					CountEn <= '1'; -- enable the counter
					if Delay_1s = '1' then --wait for the delay
						NextState <= EWAmber; --go to next state
						CountEn <= '0';
					end if;
				end if;
			--EWWalk
			when EWWalk =>
				LightsEW <= WALK;
				ClearPedEWButtonPressed <= '1';
				ClearCarEWButtonPressed <= '1';
				CountEn <= '1'; -- enable the counter
				if Delay_1s = '1' then --wait for the delay
					NextState <= EWGreen; --go to next state
					CountEn <= '0';
				end if;
			--EWAMber
			when EWAmber =>
				LightsEW <= AMBER;
				CountEn <= '1'; -- enable the counter
				if Delay_1s = '1' then --wait for the delay
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
