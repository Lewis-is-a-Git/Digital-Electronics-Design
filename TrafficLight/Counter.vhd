library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Counter is
    Port ( Reset : in  STD_LOGIC; --external reset
           Clock : in  STD_LOGIC; --clock
			  Clear : in STD_LOGIC; --internal reset
			  CountEn : in STD_LOGIC; --enable the counter
           Delay_1s : out  STD_LOGIC); --wait for the delay so the lights dont change instantly
end Counter;

architecture Behavioral of Counter is
	constant DELAY : integer := 100; -- 1 second
	signal Count : natural range 0 to DELAY; --counter
begin
	Timer:
   process (Reset, Clock)
   begin
      if (Reset = '1') then --asynch reset
         Count <= 1;
			Delay_1s <= '0';
      elsif rising_edge(clock) then
			if Clear = '1' then --synch clear to rest flip flops
				Count <= 0;
				Delay_1s <= '0';
			else
				if CountEn = '1' then -- if count is enabled
					if Count < DELAY then
						Count <= Count + 1; -- count
					else
						Count <= 0;
					end if;
				else
					Count <= 0; --else dont
				end if;
				if Count = DELAY then
					Delay_1s <= '1'; --after a delay set this velue high
				end if;
			end if;
      end if;
   end process;

end Behavioral;
