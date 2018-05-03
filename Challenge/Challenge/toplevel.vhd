library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity PulseWidthMod is
    Port ( clock : in  STD_LOGIC;
           Reset : in  STD_LOGIC;
           width : in  STD_LOGIC_VECTOR (7 downto 0);
           pwm   : out  STD_LOGIC);
end PulseWidthMod;

architecture Beh of PulseWidthMod is
begin
	process (clock, Reset)
		variable count : integer range 0 to 255;
		variable pulseHigh : integer range 0 to 255;
	begin
		if Reset = '1' then -- mealey reset
			pwm <= '0'; -- set the output to 0
			count := 0; --reset the counter
		elsif rising_edge(clock) then
			if count < 256 then 
				count := count + 1; --count on each clock edge
			else
				count := 0; -- rollover when 256
			end if;
		end if;

		pulseHigh := to_integer(unsigned(width)); --typecast vector to integer
		if count < pulseHigh then -- while the count is less than the input width vector
				pwm <= '1';
			else
				pwm <= '0'; 
			end if;
	end process;
end Beh;

