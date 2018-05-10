library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;

entity Controller is
    Port ( clock : in  STD_LOGIC;
           reset : in  STD_LOGIC;
			  PedEW : in STD_LOGIC;
			  PedNS : in STD_LOGIC;
			  CarEW : in STD_LOGIC;
			  CarNS : in STD_LOGIC;
			  delay_1s : in STD_LOGIC;
			  LightsEW : out STD_LOGIC_VECTOR(1 downto 0);
			  LightsNS : out STD_LOGIC_VECTOR(1 downto 0)
			  );
end Controller;

architecture Behavioral of Controller is
	-- Encoding for lights
	constant RED   : std_logic_vector(1 downto 0) := "00";
	constant AMBER : std_logic_vector(1 downto 0) := "01";
	constant GREEN : std_logic_vector(1 downto 0) := "10";
	constant WALK  : std_logic_vector(1 downto 0) := "11";
	
	--states
	type StateType is (NSGreen, NSAmber, EWGreen, EWAmber);
	signal State, Nextstate : Statetype;
	
	--remeber if a pedestrain button is pressed
	signal PedNSButtonPressed, PedEWButtonPressed : std_logic;
begin
   StateProcess:
   process (Reset, Clock, State)
   begin
      if (reset = '1') then
         State <= NSGreen;
      elsif rising_edge(clock) then
			if PedEW = '1' then
				PedNSButtonPressed <= '1';
			elsif PedNS = '1' then
				PedEWButtonPressed <= '1';
			end if;
			State <= NextState;
      end if;
	      --there is two way communication so need 2 signals
	      -- the signal coming back from the combinational peocess resets the button remeber signal
		if State = NSGreen then
			PedNSButtonPressed <= '0';
		end if;
		if State = EWGreen then
			PedEWButtonPressed <= '0';
		end if;
			
   end process StateProcess;
   
	CombinationalProcess:
	process(State, PedNSButtonPressed, PedEWButtonPressed)
	begin
		-- default values for outputs
		LightsEW <= RED;
		LightsNS <= RED;
		Nextstate <= State;
		
		case State is
			when NSGreen =>
				if PedNSButtonPressed = '1' then
					LightsNS <= WALK;
				else
					LightsNS <= GREEN;
				end if;
				NextState <= NSAmber;
			when NSAmber =>
				LightsNS <= AMBER;
				NextState <= EWGreen;
			when EWGreen =>
				if PedEWButtonPressed = '1' then
					LightsEW <= WALK;	
				else
					LightsEW <= GREEN;
				end if;
				NextState <= EWAmber;
			when EWAmber =>
				LightsEW <= AMBER;
				NextState <= NSGreen;
		end case;
	end process;

end Behavioral;
