library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Counter is
    Port ( Reset : in  STD_LOGIC; --external reset
           Clock : in  STD_LOGIC; --clock
			  CountEn : in STD_LOGIC; --enable the counter, also clears
			  --wait for the delay so the lights dont change on clock edge
           Delay_1s : out  STD_LOGIC;
			  Delay_2s : out  STD_LOGIC;
           Delay_3s : out  STD_LOGIC); 			  
end Counter;

architecture Behavioral of Counter is
	constant DELAY : integer := 300; -- 3 seconds
	signal Count : natural range 0 to DELAY; --counter
begin
	Timer:
   process (Reset, Clock)
   begin
      if (Reset = '1') then --asynch reset
         Count <= 0;
      elsif rising_edge(clock) then
			if CountEn = '1' then -- if count is enabled
				if Count < DELAY then
					Count <= Count + 1; -- count
				else
					Count <= 0;
				end if;
			else
				Count <= 0; --else dont
			end if;
      end if;
   end process;
	
	Delay_1s <= '1' when (Count = 100) else '0'; -- 1 second
   Delay_2s <= '1' when (Count = 200) else '0'; -- 2 seconds
	Delay_3s <= '1' when (Count = 300) else '0'; -- 3 seconds
end Behavioral;
