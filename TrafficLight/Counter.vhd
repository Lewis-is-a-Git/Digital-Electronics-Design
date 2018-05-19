library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Counter is
    Port ( Reset : in  STD_LOGIC; --external reset
           Clock : in  STD_LOGIC; --clock
			  CountEn : in STD_LOGIC; --enable the counter, also clears
			  --wait for the delay so the lights dont change on clock edge
           DelayAmber : out  STD_LOGIC; --delay for amber light
			  DelayMin : out  STD_LOGIC; --delay for minimum wait time
           DelayPed : out  STD_LOGIC); --delay for pedestrain crossing			  
end Counter;

architecture Behavioral of Counter is
	constant MAX : integer := 300; -- 3 seconds
	signal Count : natural range 0 to MAX; --counter
begin
	Timer:
   process (Reset, Clock)
   begin
      if (Reset = '1') then --asynch reset
         Count <= 0;
      elsif rising_edge(clock) then
			if CountEn = '1' then -- if count is enabled
				if Count < MAX then
					Count <= Count + 1; -- count
				else
					Count <= 0;
				end if;
			else
				Count <= 0; --else dont
			end if;
      end if;
   end process;
	
	DelayAmber <= '1' when (Count = 100) else '0'; -- 1 second
   DelayMin <= '1' when (Count = 200) else '0'; -- 2 seconds
	DelayPed <= '1' when (Count = 300) else '0'; -- 3 seconds
end Behavioral;
